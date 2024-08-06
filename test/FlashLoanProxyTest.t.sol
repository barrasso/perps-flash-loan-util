// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../contracts/FlashLoanProxy.sol";
import "../contracts/PerpsV3FlashLoanUtil.sol";

contract FlashLoanProxyTest is Test {
    FlashLoanProxy proxy;
    PerpsV3FlashLoanUtil flashLoanImplementation;

    function getAddress(string memory name) internal returns (address) {
        // Placeholder logic to get address dynamically; replace with actual logic as needed
        return address(uint160(uint(keccak256(abi.encodePacked(name)))));
    }

    function setUp() public {
        address addressProvider = getAddress("AavePoolAddressesProvider");
        address synthetixCore = getAddress("SynthetixCore");
        address spotMarketProxy = getAddress("SpotMarketProxy");
        address perpsMarketProxy = getAddress("PerpsMarketProxy");
        address quoter = getAddress("Quoter");
        address router = getAddress("Router");
        address assetToFlash = getAddress("AssetToFlash");
        address snxUSD = getAddress("SnxUSD");
        uint256 feePercentage = 100; // 1%

        flashLoanImplementation = new PerpsV3FlashLoanUtil(
            addressProvider,
            synthetixCore,
            spotMarketProxy,
            perpsMarketProxy,
            quoter,
            router,
            assetToFlash,
            snxUSD,
            feePercentage
        );

        proxy = new FlashLoanProxy(address(flashLoanImplementation), "");
    }

    function testUpgradeImplementation() public {
        PerpsV3FlashLoanUtil newImplementation = new PerpsV3FlashLoanUtil(
            getAddress("AavePoolAddressesProvider"),
            getAddress("SynthetixCore"),
            getAddress("SpotMarketProxy"),
            getAddress("PerpsMarketProxy"),
            getAddress("Quoter"),
            getAddress("Router"),
            getAddress("AssetToFlash"),
            getAddress("SnxUSD"),
            200 // 2%
        );

        proxy.upgradeTo(address(newImplementation));
        assertEq(proxy.implementation(), address(newImplementation));
    }
}
