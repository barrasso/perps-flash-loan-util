async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const PerpsV3FlashLoanUtil = await ethers.getContractFactory(
    "PerpsV3FlashLoanUtil"
  );
  const perpsV3FlashLoanUtil = await PerpsV3FlashLoanUtil.deploy(
    "0xYourAavePoolAddressesProviderAddress",
    "0xYourSynthetixCoreAddress",
    "0xYourSpotMarketProxyAddress",
    "0xYourPerpsMarketProxyAddress",
    "0xYourQuoterAddress",
    "0xYourRouterAddress",
    "0xYourAssetToFlashAddress",
    "0xYourSnxUsdAddress",
    100 // 1%
  );

  console.log(
    "PerpsV3FlashLoanUtil deployed to:",
    perpsV3FlashLoanUtil.address
  );

  const FlashLoanProxy = await ethers.getContractFactory("FlashLoanProxy");
  const flashLoanProxy = await FlashLoanProxy.deploy(
    perpsV3FlashLoanUtil.address,
    "0x"
  );

  console.log("FlashLoanProxy deployed to:", flashLoanProxy.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
