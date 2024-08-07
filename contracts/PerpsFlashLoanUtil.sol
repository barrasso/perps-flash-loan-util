// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@aave-v3-core/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import "@uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap-v3-periphery/contracts/interfaces/IQuoter.sol";
import "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ISynthetixCore} from "./interfaces/ISynthetixCore.sol";
import {ISpotMarketProxy} from "./interfaces/ISpotMarketProxy.sol";
import {IPerpsMarketProxy} from "./interfaces/IPerpsMarketProxy.sol";

/// @title PerpsFlashLoanUtil
/// @notice A tool used for flashing out of Synthetix V3 Perps positions.
/// @author meb (@barrasso)
contract PerpsFlashLoanUtil is FlashLoanSimpleReceiverBase {
    ISynthetixCore public synthetixCore;
    ISpotMarketProxy public spotMarketProxy;
    IPerpsMarketProxy public perpsMarketProxy;
    IQuoter public quoter;
    ISwapRouter public router;
    address public usdcToken;
    address public snxUSDToken;

    /// @notice Constructs the PerpsFlashLoanUtil contract
    /// @param _addressProvider Address of the Aave Pool Addresses Provider
    /// @param _synthetixCore Address of the Synthetix Core contract
    /// @param _spotMarketProxy Address of the Spot Market Proxy contract
    /// @param _perpsMarketProxy Address of the Perps Market Proxy contract
    /// @param _quoter Address of the Uniswap V3 Quoter contract
    /// @param _router Address of the Uniswap V3 Router contract
    /// @param _usdcToken Address of the asset to be used for flash loans (e.g. USDC)
    /// @param _snxUSDToken Address of the snxUSD token
    constructor(
        address _addressProvider,
        address _synthetixCore,
        address _spotMarketProxy,
        address _perpsMarketProxy,
        address _quoter,
        address _router,
        address _usdcToken,
        address _snxUSDToken
    ) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {
        synthetixCore = ISynthetixCore(_synthetixCore);
        spotMarketProxy = ISpotMarketProxy(_spotMarketProxy);
        perpsMarketProxy = IPerpsMarketProxy(_perpsMarketProxy);
        quoter = IQuoter(_quoter);
        router = ISwapRouter(_router);
        usdcToken = _usdcToken;
        snxUSDToken = _snxUSDToken;
    }

    /// @notice Requests a flash loan to unwind a perps position with its collateral
    /// @param _amount Amount of the asset to flash loan
    /// @param _collateralType Type of the collateral
    /// @param _marketId ID of the market
    /// @param _accountId ID of the account
    function requestFlashLoan(
        uint256 _amount,
        address _collateralType,
        uint128 _marketId,
        uint128 _accountId
    ) external {
        address receiverAddress = address(this);
        address asset = usdcToken;
        uint256 amount = _amount;
        bytes memory params = abi.encode(
            msg.sender,
            _collateralType,
            _marketId,
            _accountId
        );
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    /// @notice Executes the unwinding after receiving the flash loan
    /// @param asset The address of the asset to be flashed
    /// @param amount The amount to be flashed
    /// @param premium The fee charged by Aave for the flash loan
    /// @param initiator The initiator of the flash loan
    /// @param params Additional parameters passed during the flash loan
    /// @return True if the operation succeeds, false otherwise
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        require(initiator == address(this), "Invalid initiator");

        // Decode the params from the flash request
        (
            address sender,
            address collateralType,
            uint128 marketId,
            uint128 accountId
        ) = abi.decode(params, (address, address, uint128, uint128));

        // Wrap to snxUSD
        IERC20(asset).approve(address(spotMarketProxy), amount);
        spotMarketProxy.wrap(marketId, amount, 0);

        // Repay debt
        synthetixCore.burnUsd(
            accountId,
            synthetixCore.getPreferredPool(),
            snxUSDToken,
            amount
        );

        // Reduce the perps position collateral by the appropriate amount.
        perpsMarketProxy.modifyCollateral(accountId, marketId, -int256(amount));

        // Unwrap the collateral back to its underlying token.
        IERC20(collateralType).approve(address(spotMarketProxy), amount);
        (uint256 unwrappedAmount, ) = spotMarketProxy.unwrap(
            marketId,
            amount,
            0
        );

        // Swap the collateral to USDC if necessary
        if (collateralType != usdcToken) {
            IERC20(collateralType).approve(address(router), unwrappedAmount);

            uint256 amountOutMinimum = quoter.quoteExactInput(
                abi.encodePacked(collateralType, unwrappedAmount, asset),
                unwrappedAmount
            );

            ISwapRouter.ExactInputParams memory swapParams = ISwapRouter
                .ExactInputParams({
                    path: abi.encodePacked(
                        collateralType,
                        unwrappedAmount,
                        asset
                    ),
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: unwrappedAmount,
                    amountOutMinimum: amountOutMinimum
                });
            unwrappedAmount = router.exactInput(swapParams);
        }

        // Calculate amount to pay back
        uint256 totalDebt = amount + premium;
        require(unwrappedAmount >= totalDebt, "Not enough to repay loan");

        // Transfer the remaining tokens back to the original sender and pay off the flash loan.
        uint256 remaining = unwrappedAmount - totalDebt;
        IERC20(asset).transfer(sender, remaining);
        IERC20(asset).approve(address(POOL), totalDebt);

        return true;
    }

    /// @notice Fallback function
    receive() external payable {}
}
