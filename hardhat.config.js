require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [{value: "0.8.19"}, {value: "0.8.20"}],
  },
  networks: {
    mumbai:{
      url: process.env.RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    }
  }
};
