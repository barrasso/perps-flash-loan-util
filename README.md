# PerpsV3FlashLoanUtil

PerpsV3FlashLoanUtil provides users with the ability to flash loan and close out a Synthetix V3 perpetual position.

## Prerequisites

- Foundry: Install Foundry by following the instructions at [Foundry GitHub](https://github.com/gakonst/foundry).

## Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/barrasso/perps-flash-loan-util.git
   cd perps-v3-flash-loan-util
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

## License

This project is licensed under the MIT License.
