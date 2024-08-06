# FlashLoanFactory

FlashLoanFactory utilizes flash loans to execute DeFi operations in a single transaction. This project implements a flexible flash loan factory system that can handle various use cases for Synthetix and other protocols. The system is built using Solidity and the Foundry framework.

## Prerequisites

- Foundry: Install Foundry by following the instructions at [Foundry GitHub](https://github.com/gakonst/foundry).

## Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/barrasso/flash-loan-factory.git
   cd flash-loan-factory
   ```

2. Install dependencies:

   ```bash
   forge install
   npm install
   ```

3. Compile the contracts:
   ```bash
   forge build
   ```

## Testing

Run the tests using Foundry:

```bash
forge test
```

## Deployment

Configure your environment variables in a `.env` file (e.g., private key, network endpoint).

Deploy the contracts:

```bash
forge script scripts/deploy.js --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast
```

Use the factory contract to deploy specific handlers:

```bash
// Example using ethers.js or hardhat scripts
const FlashLoanFactory = await ethers.getContractFactory("FlashLoanFactory");
const factory = await FlashLoanFactory.attach("<DEPLOYED_FACTORY_ADDRESS>");
const handlerAddress = await factory.createSynthetixV3PerpsFlashLoanHandler(
    "<SYNTETHIX_CORE_ADDRESS>",
    "<SPOT_MARKET_PROXY_ADDRESS>",
    "<PERPS_MARKET_PROXY_ADDRESS>",
    "<ASSET_TO_FLASH>",
    "<SNXUSD_ADDRESS>"
);
```
