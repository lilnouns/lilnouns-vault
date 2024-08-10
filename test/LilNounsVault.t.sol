// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";
import { LilNounsVault } from "../src/LilNounsVault.sol";
import { ERC20Mock } from "../src/mocks/ERC20Mock.sol";
import { ERC721Mock } from "../src/mocks/ERC721Mock.sol";
import { UUPSUpgradeableMock } from "../src/mocks/UUPSUpgradeableMock.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol"; // Import the UUPS proxy
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract LilNounsVaultTest is Test, IERC721Receiver {
  LilNounsVault public lilNounsVault;
  ERC20Mock public erc20;
  ERC721Mock public erc721;
  UUPSUpgradeableMock public newImplementation;
  address public owner;
  address public addr1;
  address public addr2;

  // Setup function to deploy contracts before each test
  function setUp() public {
    owner = address(this);
    addr1 = vm.addr(1);
    addr2 = vm.addr(2);

    // Deploy the ERC20 token
    erc20 = new ERC20Mock("TestToken", "TTK", owner, 1000);

    // Deploy the ERC721 token
    erc721 = new ERC721Mock("TestNFT", "TNFT");

    // Deploy the LilNounsVault contract and initialize it via the proxy
    LilNounsVault implementation = new LilNounsVault();
    ERC1967Proxy proxy = new ERC1967Proxy(
      address(implementation),
      abi.encodeWithSelector(LilNounsVault.initialize.selector)
    );

    lilNounsVault = LilNounsVault(payable(address(proxy))); // Cast proxy to LilNounsVault using payable conversion

    // Deploy a new implementation mock for upgrade testing
    newImplementation = new UUPSUpgradeableMock();
    newImplementation.initialize(); // Initialize the new mock implementation
  }

  // Implement the IERC721Receiver interface
  function onERC721Received(
    address, // operator
    address, // from
    uint256, // tokenId
    bytes calldata // data
  ) external pure override returns (bytes4) {
    return this.onERC721Received.selector;
  }

  // Test for deployment and initialization
  function testDeploymentAndInitialization() public view {
    assertEq(lilNounsVault.owner(), owner);
  }

  // Test for receiving ETH
  function testETHReception() public {
    uint256 initialBalance = address(lilNounsVault).balance;

    // Send 1 ETH to the contract
    vm.deal(addr1, 1 ether);
    vm.prank(addr1);
    (bool success, ) = address(lilNounsVault).call{ value: 1 ether }("");
    require(success, "ETH transfer failed");

    uint256 finalBalance = address(lilNounsVault).balance;
    assertEq(finalBalance - initialBalance, 1 ether);
  }

  // Test for receiving ERC-20 tokens
  function testERC20Reception() public {
    // Transfer 100 tokens to the contract
    erc20.transfer(address(lilNounsVault), 100);

    uint256 contractBalance = erc20.balanceOf(address(lilNounsVault));
    assertEq(contractBalance, 100);
  }

  // Test for receiving ERC-721 tokens
  function testERC721Reception() public {
    // Mint a new NFT and transfer it to the contract
    erc721.mint(addr1, 1);

    vm.prank(addr1);
    erc721.safeTransferFrom(addr1, address(lilNounsVault), 1);

    address ownerOfToken = erc721.ownerOf(1);
    assertEq(ownerOfToken, address(lilNounsVault));
  }

  // Test for pausing the contract with block numbers
  function testPauseWithBlockNumbers() public {
    uint256 startBlock = block.number + 5;
    uint256 endBlock = block.number + 10;

    lilNounsVault.pause(startBlock, endBlock);

    // Fast-forward to the start block
    vm.roll(startBlock);
    assertTrue(lilNounsVault.paused(), "Contract should be paused");

    // Attempt to unpause during the pause period (should fail)
    vm.expectRevert(LilNounsVault.UnpauseRestricted.selector);
    lilNounsVault.unpause();

    // Fast-forward to the end block
    vm.roll(endBlock + 1);
    lilNounsVault.unpause();
    assertFalse(lilNounsVault.paused(), "Contract should be unpaused");
  }

  // Test that upgrading is blocked during pause period
  function testUpgradeBlockedDuringPause() public {
    uint256 startBlock = block.number + 5;
    uint256 endBlock = block.number + 10;

    lilNounsVault.pause(startBlock, endBlock);

    // Fast-forward to the start block
    vm.roll(startBlock);

    // Attempt to upgrade during the pause period (should fail)
    vm.expectRevert(LilNounsVault.ContractPausedDuringUpgrade.selector);
    LilNounsVault(payable(address(lilNounsVault))).upgradeToAndCall(
      address(newImplementation),
      ""
    );
  }

  // Test for invalid pause period
  function testInvalidPausePeriod() public {
    // Pause end block is less than start block
    vm.expectRevert(LilNounsVault.InvalidPausePeriod.selector);
    lilNounsVault.pause(block.number + 10, block.number + 5);

    // Pause start block is in the past
    vm.expectRevert(LilNounsVault.InvalidPausePeriod.selector);
    lilNounsVault.pause(block.number - 1, block.number + 10);
  }

  // Test for withdrawing ERC721 tokens
  function testWithdrawERC721() public {
    // Mint the NFT to addr1
    erc721.mint(addr1, 1);

    // Transfer the NFT to the LilNounsVault contract
    vm.prank(addr1);
    erc721.safeTransferFrom(addr1, address(lilNounsVault), 1);

    // Verify the contract received the NFT
    assertEq(erc721.ownerOf(1), address(lilNounsVault));

    // Withdraw the NFT from the vault to the owner
    lilNounsVault.withdraw(erc721, 1);

    // Verify the owner received the NFT
    assertEq(erc721.ownerOf(1), owner);
  }
}
