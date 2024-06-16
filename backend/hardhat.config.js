require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks:{
    mumbai:{
      url: "",
      accounts: [""]
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/06FpnU4zuFmBgqTE-ziJPggMOEGlQ6mw",
      accounts: [""] 
    }
  },
  etherscan:{
    apiKey: ""
  }
};
