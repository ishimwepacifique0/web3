async function main() {
  const IshiCoin = await ethers.getContractFactory("IshiCoin");
  const ishi = await IshiCoin.deploy();
  console.log("Contract deployed to:", ishi.target);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
