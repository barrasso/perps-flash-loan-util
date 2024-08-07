// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {PerpsFlashLoanUtil} from "../contracts/PerpsFlashLoanUtil.sol";
import {Base} from "./config/Base.sol";
import {BaseSepolia} from "./config/BaseSepolia.sol";
import {Script} from "lib/forge-std/src/Script.sol";

contract DeployPerpsFlashLoanUtil is Script {
    modifier broadcast() {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        _;
        vm.stopBroadcast();
    }

    function deploy(
        address aave,
        address core,
        address spot,
        address perps,
        address quoter,
        address router,
        address usdc,
        address snxUSD
    ) public returns (address) {
        PerpsFlashLoanUtil c = new PerpsFlashLoanUtil({
            _aave: aave,
            _core: core,
            _spot: spot,
            _perps: perps,
            _quoter: quoter,
            _router: router,
            _usdc: usdc,
            _snxUSD: snxUSD
        });

        return address(c);
    }
}

/// @dev steps to deploy and verify on Base:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script
/// script/PerpsFlashLoanUtil.s.sol:DeployPerpsFlashLoanUtilBase --rpc-url
/// $BASE_RPC_URL --etherscan-api-key $BASESCAN_API_KEY --broadcast --verify
/// -vvvv`
contract DeployPerpsFlashLoanUtilBase is DeployPerpsFlashLoanUtil, Base {
    function run() public broadcast returns (address c) {
        c = deploy(
            AAVE_PROVIDER,
            SYNTHETIX_CORE,
            SYNTHETIX_SPOT_MARKET,
            SYNTHETIX_PERPS_MARKET,
            UNISWAP_QUOTER,
            UNISWAP_ROUTER,
            USDC,
            snxUSD
        );
    }
}

/// @dev steps to deploy and verify on BaseSepolia:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script
/// script/PerpsFlashLoanUtil.s.sol:DeployPerpsFlashLoanUtilBaseSepolia --rpc-url
/// $BASE_SEPOLIA_RPC_URL --etherscan-api-key $BASESCAN_API_KEY --broadcast
/// --verify -vvvv`
contract DeployPerpsFlashLoanUtilBaseSepolia is
    DeployPerpsFlashLoanUtil,
    BaseSepolia
{
    function run() public broadcast returns (address c) {
        c = deploy(
            AAVE_PROVIDER,
            SYNTHETIX_CORE,
            SYNTHETIX_SPOT_MARKET,
            SYNTHETIX_PERPS_MARKET,
            UNISWAP_QUOTER,
            UNISWAP_ROUTER,
            USDC,
            snxUSD
        );
    }
}
