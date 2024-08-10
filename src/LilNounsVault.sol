// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

// Importing OpenZeppelin's modules
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title LilNounsVault
 * @dev This contract serves as a vault, upgradeable via UUPS pattern.
 * It includes pausable functionality to allow for emergency stops and can receive ETH and NFTs.
 */
contract LilNounsVault is
  Initializable,
  UUPSUpgradeable,
  OwnableUpgradeable,
  PausableUpgradeable,
  IERC721Receiver
{
  /// @notice Custom error for paused contract during upgrade attempt
  error ContractPausedDuringUpgrade();

  /// @notice Error for when attempting to unpause during the restricted period
  error UnpauseRestricted();

  /// @notice Error for invalid pause period
  error InvalidPausePeriod();

  uint256 public pauseStart;
  uint256 public pauseEnd;

  /// @notice Initializer function to replace the constructor for upgradeable contracts
  function initialize() public initializer {
    __Ownable_init(msg.sender);
    __UUPSUpgradeable_init();
    __Pausable_init();
  }

  /**
   * @notice Pauses the contract for a specific period.
   * @dev Only the owner can pause the contract. The pause start and end times are set as timestamps.
   * @param _pauseStart The timestamp when the pause period begins.
   * @param _pauseEnd The timestamp when the pause period ends.
   */
  function pause(uint256 _pauseStart, uint256 _pauseEnd) external onlyOwner {
    if (_pauseEnd <= _pauseStart) {
      revert InvalidPausePeriod();
    }
    if (_pauseStart < block.timestamp) {
      revert InvalidPausePeriod();
    }

    pauseStart = _pauseStart;
    pauseEnd = _pauseEnd;
    _pause();
  }

  /**
   * @notice Unpauses the contract, resuming all state-changing operations.
   * @dev Only the owner can unpause the contract. Cannot unpause during the restricted period.
   */
  function unpause() external onlyOwner {
    if (block.timestamp >= pauseStart && block.timestamp <= pauseEnd) {
      revert UnpauseRestricted();
    }
    _unpause();
  }

  /**
   * @notice Internal function that authorizes upgrades
   * @dev Only the owner of the contract can authorize an upgrade, and the contract must not be paused.
   * @param newImplementation The address of the new implementation contract
   */
  function _authorizeUpgrade(
    address newImplementation
  ) internal view override onlyOwner {
    if (
      paused() && (block.timestamp >= pauseStart && block.timestamp <= pauseEnd)
    ) {
      revert ContractPausedDuringUpgrade();
    }

    // Suppress unused variable warning
    (newImplementation);
  }

  /**
   * @notice Function to receive ETH
   * @dev This function enables the contract to accept ETH deposits.
   */
  receive() external payable {}

  /**
   * @notice Function to handle receiving NFTs
   * @dev This function is called when an NFT is transferred to this contract.
   * @return bytes4 This function must return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   */
  function onERC721Received(
    address, // operator
    address, // from
    uint256, // tokenId
    bytes calldata // data
  ) external pure override returns (bytes4) {
    return this.onERC721Received.selector;
  }
}
