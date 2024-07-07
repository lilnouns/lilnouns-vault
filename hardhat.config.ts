import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import "@nomiclabs/hardhat-solhint";

const config: HardhatUserConfig = {
  solidity: "0.8.26",
};

export default config;
