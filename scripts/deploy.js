async function main() {
  const HelloCore = await ethers.getContractFactory("RandaCore");
  const hello = await HelloCore.deploy();
  console.log("Contract deployed to:", hello.target);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
