// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

// Importing OpenZeppelin's modules
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

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
  ReentrancyGuardUpgradeable,
  IERC721Receiver
{
  using SafeERC20 for IERC20;

  /// @notice Custom error for paused contract during upgrade attempt
  error ContractPausedDuringUpgrade();

  /// @notice Error for when attempting to unpause during the restricted period
  error UnpauseRestricted();

  /// @notice Error for invalid pause period
  error InvalidPausePeriod();

  uint256 public pauseStartBlock;
  uint256 public pauseEndBlock;

  /// @notice Initializer function to replace the constructor for upgradeable contracts
  function initialize() public initializer {
    __Ownable_init(msg.sender);
    __UUPSUpgradeable_init();
    __Pausable_init();
    __ReentrancyGuard_init();
  }

  /**
   * @notice Pauses the contract for a specific period based on block numbers.
   * @dev Only the owner can pause the contract. The pause start and end times are set as block numbers.
   * @param pauseStartBlock_ The block number when the pause period begins.
   * @param pauseEndBlock_ The block number when the pause period ends.
   */
  function pause(
    uint256 pauseStartBlock_,
    uint256 pauseEndBlock_
  ) external onlyOwner {
    if (pauseEndBlock_ <= pauseStartBlock_) {
      revert InvalidPausePeriod();
    }
    if (pauseStartBlock_ < block.number) {
      revert InvalidPausePeriod();
    }

    pauseStartBlock = pauseStartBlock_;
    pauseEndBlock = pauseEndBlock_;
    _pause();
  }

  /**
   * @notice Unpauses the contract.
   * @dev Only the owner can call this function. It cannot be called during the restricted pause period.
   */
  function unpause() external onlyOwner {
    if (block.number >= pauseStartBlock && block.number <= pauseEndBlock) {
      revert UnpauseRestricted();
    }
    _unpause();
  }

  /**
   * @notice Transfers ownership of the contract to a new account (`newOwner`).
   * @dev Only the current owner can call this function. The contract must not be paused to transfer ownership.
   * @param newOwner The address of the new owner.
   */
  function transferOwnership(
    address newOwner
  ) public override onlyOwner whenNotPaused {
    require(newOwner != address(0), "New owner is the zero address");
    _transferOwnership(newOwner);
  }

  /**
   * @notice Authorizes an upgrade to a new implementation contract.
   * @dev This function ensures that upgrades can only be authorized by the owner and when the contract is not paused.
   * @param newImplementation The address of the new implementation contract.
   */
  function _authorizeUpgrade(
    address newImplementation
  ) internal view override onlyOwner {
    if (
      paused() &&
      (block.number >= pauseStartBlock && block.number <= pauseEndBlock)
    ) {
      revert ContractPausedDuringUpgrade();
    }

    // Suppress unused variable warning
    (newImplementation);
  }

  /**
   * @notice Withdraws all ETH from the contract to the owner's address.
   * @dev Only the owner can call this function. It is protected by non-reentrancy and can only be called when the contract is not paused.
   */
  function withdraw() external onlyOwner whenNotPaused nonReentrant {
    uint256 amount = address(this).balance;
    Address.sendValue(payable(msg.sender), amount);
  }

  /**
   * @notice Withdraws a specific ERC20 token from the contract to the owner's address.
   * @dev Only the owner can call this function. It is protected by non-reentrancy and can only be called when the contract is not paused.
   * @param token The address of the ERC20 token contract.
   */
  function withdraw(
    IERC20 token
  ) external onlyOwner whenNotPaused nonReentrant {
    uint256 balance = token.balanceOf(address(this));
    token.safeTransfer(owner(), balance);
  }

  /**
   * @notice Withdraws a specific ERC721 token from the contract to the owner's address.
   * @dev Only the owner can call this function. It is protected by non-reentrancy and can only be called when the contract is not paused.
   * @param nft The address of the ERC721 NFT contract.
   * @param tokenId The ID of the NFT to withdraw.
   */
  function withdraw(
    IERC721 nft,
    uint256 tokenId
  ) external onlyOwner whenNotPaused nonReentrant {
    nft.safeTransferFrom(address(this), owner(), tokenId);
  }

  /**
   * @notice Function to receive ETH
   * @dev This function enables the contract to accept ETH deposits.
   */
  receive() external payable {}

  /**
   * @notice Handles the receipt of ERC721 NFTs.
   * @dev This function is called when an ERC721 token is transferred to this contract.
   * @return bytes4 The selector of the `onERC721Received` function.
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
