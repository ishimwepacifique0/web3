async function main() {
  const RandaCore = await ethers.getContractFactory("RandaCore");
  const randa = await RandaCore.deploy();
  console.log("Contract deployed to:", randa.target);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
