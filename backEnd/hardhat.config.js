require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();
// require("hardhat-contract-sizer");
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100,
      },
    },
  },
  // contractSizer: {
  //   runOnCompile: true, // Automatically run after compilation
  //   only: [], // Optionally specify contracts to include
  // },  
  networks: {
    // hardhat: {
    //   allowUnlimitedContractSize: true
    // },
    // sepolia: {
    //   url: process.env.SEPOLIA_RPC_URL,
    //   accounts: [process.env.PRIVATE_KEY]
    // }    
  }
};
