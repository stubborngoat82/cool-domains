require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();




/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.10",
  networks: {
    mumbai: {
      url: process.env.MUMBAI_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    }
  }
};