// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

// Importing OpenZeppelin's Initializable and UUPSUpgradeable contracts
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title LilNounsVault
 * @dev This contract serves as a vault, upgradeable via UUPS pattern.
 * It is designed to be a base template, with additional logic to be added as needed.
 */
contract LilNounsVault is Initializable, UUPSUpgradeable, OwnableUpgradeable {
  /// @notice Initializer function to replace the constructor for upgradeable contracts
  function initialize() public initializer {
    __Ownable_init();
    __UUPSUpgradeable_init();
  }

  /**
   * @notice Internal function that authorizes upgrades
   * @dev Only the owner of the contract can authorize an upgrade
   * @param newImplementation The address of the new implementation contract
   */
  function _authorizeUpgrade(
    address newImplementation
  ) internal override onlyOwner {}
}
