require("@nomiclabs/hardhat-ethers"); 
require("dotenv").config();

module.exports = {
  solidity: "0.8.20", // Match the Solidity version in your contract
  networks: {
    hardhat: {}, // Local development network
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY_SEPOLIA}`, // Use Alchemy's Sepolia URL
      accounts: [`0x${process.env.WALLET_PRIVATE_KEY}`], // Your wallet private key
    },
  },
  paths: {
    artifacts: "./artifacts",
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
  },
};
