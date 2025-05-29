require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  defaultNetwork: "mainnet",
  networks: {
    mainnet: {
      url: "https://bsc-dataseed.binance.org",
      accounts: ["1881a4b684ac74b046a2d87c87e07d50e68eb8674d2700be235e3cda782ddd47"]
    },
    testnet: {
      url: "https://data-seed-prebsc-2-s2.binance.org:8545",
      accounts: ["1881a4b684ac74b046a2d87c87e07d50e68eb8674d2700be235e3cda782ddd47"]
    } 
  }
};
