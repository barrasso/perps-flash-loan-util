# Perps Flash Loan Util

This tool provides users with the ability to request a flash loan to unwind a Synthetix V3 Perps multi-collateral position in a single transaction.

What this contract does:

- Flash loans USDC
- Wraps to snxUSD
- Repays debt by burning snxUSD
- Withdraws margin (e.g. snxETH)
- Unwraps to WETH
- Swaps to USDC
- Repays Flash loan + fee
- Sends user remaining margin

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

   Dependencies: aave, uniswap, openzeppelin, synthetix.

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

See `PerpsFlashLoanUtil.s.sol` for instructions on how to deploy the contract.

## Considerations

- MEV attack vectors / frontrunning

- Granting / revoking account permissions

## License

This project is licensed under the MIT License.
