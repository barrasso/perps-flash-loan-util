// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../contracts/PerpsV3FlashLoanUtil.sol";

contract PerpsV3FlashLoanUtilTest is Test {
    PerpsV3FlashLoanUtil flashLoan;

    function getAddress(string memory name) internal returns (address) {
        // Placeholder logic to get address dynamically; replace with actual logic as needed
        return address(uint160(uint(keccak256(abi.encodePacked(name)))));
    }

    function setUp() public {
        flashLoan = new PerpsV3FlashLoanUtil(
            getAddress("AavePoolAddressesProvider"),
            getAddress("SynthetixCore"),
            getAddress("SpotMarketProxy"),
            getAddress("PerpsMarketProxy"),
            getAddress("Quoter"),
            getAddress("Router"),
            getAddress("AssetToFlash"),
            getAddress("SnxUSD"),
            100 // 1%
        );
    }

    function testSetFeePercentage() public {
        flashLoan.setFeePercentage(200); // 2%
        assertEq(flashLoan.feePercentage(), 200);
    }

    function testWithdrawTokens() public {
        // Add test logic for withdrawing tokens
    }

    function testWithdrawETH() public {
        // Add test logic for withdrawing ETH
    }
}
