import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import * as dotenv from "dotenv";
dotenv.config();

require("./tasks");
const deployerPrivateKey = process.env.DEPLOYER_PRIVATE_KEY ?? "";
const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: "https://goerli.infura.io/v3/00a46a4fb2a1486e9c1b4534a265a47c",
      accounts: [deployerPrivateKey],
    },
    polygon: {
      url: "https://polygon-rpc.com",
      accounts: [deployerPrivateKey],
    },
    polygonMumbai: {
      url: `https://rpc.ankr.com/polygon_mumbai`,
      accounts: [deployerPrivateKey],
    },
    sepolia: {
      url: "https://rpc.sepolia.org",
      accounts: [deployerPrivateKey]
    }
  },
  etherscan: {
    apiKey: {
      goerli: process.env.ETHERSCAN_API_KEY ?? "",
      sepolia: process.env.ETHERSCAN_API_KEY ?? "",
      polygon: process.env.POLYGONSCAN_API_KEY ?? "",
      polygonMumbai: process.env.POLYGONSCAN_API_KEY ?? ""
    },
  },
};


export default config;
