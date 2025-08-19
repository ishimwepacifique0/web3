const { ethers } = require("hardhat");
require("dotenv").config();
async function main() {
  const contractAddress = process.env.ISHI_CONTRACT_ADDRESS;
  const IshiCoin = await ethers.getContractAt("IshiCoin", contractAddress);
  console.log("Message:", await IshiCoin.message());
  const tx = await IshiCoin.setMessage("Core is awesome!");
  await tx.wait();
  console.log("Updated message:", await RandaCore.message());
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
