require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    coretestnet: {
      url: "https://rpc.test2.btcs.network",
      chainId: 1114,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
