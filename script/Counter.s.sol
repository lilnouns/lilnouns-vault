// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

import { Script, console } from "forge-std/Script.sol";

contract CounterScript is Script {
  function setUp() public {}

  function run() public {
    vm.broadcast();
  }
}
