// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

// Importing OpenZeppelin's modules
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

/**
 * @title LilNounsVault
 * @dev This contract serves as a vault, upgradeable via UUPS pattern.
 * It includes pausable functionality to allow for emergency stops.
 */
contract LilNounsVault is
  Initializable,
  UUPSUpgradeable,
  OwnableUpgradeable,
  PausableUpgradeable
{
  /// @notice Initializer function to replace the constructor for upgradeable contracts
  function initialize() public initializer {
    __Ownable_init(msg.sender);
    __UUPSUpgradeable_init();
    __Pausable_init();
  }

  /**
   * @notice Internal function that authorizes upgrades
   * @dev Only the owner of the contract can authorize an upgrade
   * @param newImplementation The address of the new implementation contract
   */
  function _authorizeUpgrade(
    address newImplementation
  ) internal override onlyOwner {}

  /**
   * @notice Pauses the contract, preventing all state-changing operations
   * @dev Only the owner can pause the contract
   */
  function pause() external onlyOwner {
    _pause();
  }

  /**
   * @notice Unpauses the contract, resuming all state-changing operations
   * @dev Only the owner can unpause the contract
   */
  function unpause() external onlyOwner {
    _unpause();
  }
}
