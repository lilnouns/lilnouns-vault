// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

import { Script, console } from "forge-std/Script.sol";
import { LilNounsVault } from "../src/LilNounsVault.sol";

contract LilNounsVaultScript is Script {
  function setUp() public {}

  function run() public {
    vm.startBroadcast();

    // Deploy the contract
    LilNounsVault vault = new LilNounsVault();

    console.log("LilNounsVault deployed at:", address(vault));

    vm.stopBroadcast();
  }
}
