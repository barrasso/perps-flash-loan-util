// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.7;

import {PerpsFlashLoanUtil} from "../contracts/PerpsFlashLoanUtil.sol";
import {MockToken} from "./mocks/MockToken.sol";
import {Test} from "forge-std/Test.sol";

contract FlashLoanTest is Test {
    MockToken _token;
    PerpsFlashLoanUtil _util;

    function setUp() public {
        _token = new MockToken();

        // TODO: setup util contract
        // _util = new PerpsFlashLoanUtil(address(0));
    }

    function testFlashLoan() public {
        // TODO: setup perps position
        // mint and approve tokens for deposit
        // _token.mint(address(this), 100 ether);
        // _token.approve(address(_util), 100 ether);
        // TODO: grant permission to modify perps account
        // TODO: request the flash loan
        // TODO: check that the position has been zeroed out and margin returned
    }
}
