// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@aave-v3-core/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import "@uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap-v3-periphery/contracts/interfaces/IQuoter.sol";
import "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {ISynthetixCore} from "./interfaces/ISynthetixCore.sol";
import {ISpotMarketProxy} from "./interfaces/ISpotMarketProxy.sol";
import {IPerpsMarketProxy} from "./interfaces/IPerpsMarketProxy.sol";

contract PerpsV3FlashLoanUtil is FlashLoanSimpleReceiverBase, Ownable {
    ISynthetixCore public synthetixCore;
    ISpotMarketProxy public spotMarketProxy;
    IPerpsMarketProxy public perpsMarketProxy;
    IQuoter public quoter;
    ISwapRouter public router;
    address public assetToFlash;
    address public snxUSD;
    uint256 public feePercentage; // Fee percentage (e.g., 100 = 1%)

    constructor(
        address _addressProvider,
        address _synthetixCore,
        address _spotMarketProxy,
        address _perpsMarketProxy,
        address _quoter,
        address _router,
        address _assetToFlash,
        address _snxUSD,
        uint256 _feePercentage
    ) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {
        synthetixCore = ISynthetixCore(_synthetixCore);
        spotMarketProxy = ISpotMarketProxy(_spotMarketProxy);
        perpsMarketProxy = IPerpsMarketProxy(_perpsMarketProxy);
        quoter = IQuoter(_quoter);
        router = ISwapRouter(_router);
        assetToFlash = _assetToFlash;
        snxUSD = _snxUSD;
        feePercentage = _feePercentage;
    }

    function requestFlashLoan(
        uint256 _amount,
        address _collateralType,
        uint128 _marketId,
        uint128 _accountId
    ) external {
        address receiverAddress = address(this);
        address asset = assetToFlash;
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

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        (
            address sender,
            address collateralType,
            uint128 marketId,
            uint128 accountId
        ) = abi.decode(params, (address, address, uint128, uint128));

        IERC20(assetToFlash).approve(address(spotMarketProxy), amount);
        spotMarketProxy.wrap(marketId, amount, 0);

        synthetixCore.burnUsd(
            accountId,
            synthetixCore.getPreferredPool(),
            snxUSD,
            amount
        );

        perpsMarketProxy.modifyCollateral(accountId, marketId, -int256(amount));

        IERC20(collateralType).approve(address(spotMarketProxy), amount);
        (uint256 unwrappedAmount, ) = spotMarketProxy.unwrap(
            marketId,
            amount,
            0
        );

        if (collateralType != assetToFlash) {
            IERC20(collateralType).approve(address(router), unwrappedAmount);

            uint256 amountOutMinimum = quoter.quoteExactInput(
                abi.encodePacked(collateralType, unwrappedAmount, assetToFlash),
                unwrappedAmount
            );

            ISwapRouter.ExactInputParams memory swapParams = ISwapRouter
                .ExactInputParams({
                    path: abi.encodePacked(
                        collateralType,
                        unwrappedAmount,
                        assetToFlash
                    ),
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: unwrappedAmount,
                    amountOutMinimum: amountOutMinimum
                });
            unwrappedAmount = router.exactInput(swapParams);
        }

        uint256 totalDebt = amount + premium;
        uint256 fee = (totalDebt * feePercentage) / 10000;
        require(unwrappedAmount >= totalDebt + fee, "Not enough to repay loan");

        IERC20(assetToFlash).transfer(owner(), fee);
        IERC20(assetToFlash).approve(address(POOL), totalDebt);
        IERC20(assetToFlash).transfer(
            sender,
            unwrappedAmount - totalDebt - fee
        );

        return true;
    }

    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        feePercentage = _feePercentage;
    }

    function withdrawTokens(address token) external onlyOwner {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
    }

    function withdrawETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}
}
