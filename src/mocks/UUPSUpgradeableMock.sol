// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

// Import specific components from the OpenZeppelin modules
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract UUPSUpgradeableMock is Initializable, UUPSUpgradeable {
  // Initializer to replace the constructor
  function initialize() public initializer {
    // Initialization logic, if any
  }

  // Required by the UUPSUpgradeable contract
  function _authorizeUpgrade(address newImplementation) internal override {
    // Empty block intentionally left blank for the mock contract
  }
}
