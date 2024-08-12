// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

import { Script, console } from "forge-std/Script.sol";
import { LilNounsVault } from "../src/LilNounsVault.sol";
import { Upgrades } from "@openzeppelin/foundry-upgrades/Upgrades.sol";

contract LilNounsVaultScript is Script {
  function setUp() public {}

  function run() public {
    // Start the broadcast, which allows writing transactions to the blockchain
    vm.startBroadcast();

    // Deploy the proxy using the Upgrades library
    address proxy = Upgrades.deployUUPSProxy(
      "LilNounsVault.sol",
      abi.encodeCall(LilNounsVault.initialize, ())
    );

    // Stop the broadcast, ending the transaction
    vm.stopBroadcast();

    // Log the proxy address for reference
    console.log("LilNounsVault Proxy deployed at:", proxy);
  }
}
