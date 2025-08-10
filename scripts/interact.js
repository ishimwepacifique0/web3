const { ethers } = require("hardhat");
require("dotenv").config();
async function main() {
  const contractAddress = process.env.RANDA_CONTRACT_ADDRESS;
  const RandaCore = await ethers.getContractAt("RandaCore", contractAddress);
  console.log("Message:", await RandaCore.message());
  const tx = await RandaCore.setMessage("Core is awesome!");
  await tx.wait();
  console.log("Updated message:", await RandaCore.message());
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
