async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Upgrading contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const FlashLoanProxy = await ethers.getContractAt(
    "FlashLoanProxy",
    "0xYourProxyAddress"
  );

  const PerpsV3FlashLoanUtil = await ethers.getContractFactory(
    "PerpsV3FlashLoanUtil"
  );
  const newPerpsV3FlashLoanUtil = await PerpsV3FlashLoanUtil.deploy(
    "0xYourAavePoolAddressesProviderAddress",
    "0xYourSynthetixCoreAddress",
    "0xYourSpotMarketProxyAddress",
    "0xYourPerpsMarketProxyAddress",
    "0xYourQuoterAddress",
    "0xYourRouterAddress",
    "0xYourAssetToFlashAddress",
    "0xYourSnxUsdAddress",
    200 // 2%
  );

  await FlashLoanProxy.upgradeTo(newPerpsV3FlashLoanUtil.address);

  console.log(
    "FlashLoanProxy upgraded to new implementation at:",
    newPerpsV3FlashLoanUtil.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
