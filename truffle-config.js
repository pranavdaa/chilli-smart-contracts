const HDWalletProvider = require("truffle-hdwallet-provider");

require('dotenv').config();  // Store environment-specific variable from '.env' to process.env

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gasPrice: 10000000000,
      gas: 10000000
    },
    mumbai: {
      provider: () => new HDWalletProvider(process.env.PK, `https://rpc-mumbai.matic.today`),
      network_id: 80001,
      gasPrice: 10000000000,
      gas: 18000000,
      confirmations: 1,
      timeoutBlocks: 20000,
      skipDryRun: true
    },
    matic: {
      provider: () => new HDWalletProvider(process.env.PK, `https://rpc-mainnet.matic.network`),
      network_id: 137,
      gasPrice: 1000000000,
      gas: 18000000,
      confirmations: 1,
      timeoutBlocks: 20000,
      skipDryRun: true
    }
  },
  compilers: {
    solc: {
      version: "0.7.5",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200   // Optimize for how many times you intend to run the code
        }
      }
    }    
  }
};