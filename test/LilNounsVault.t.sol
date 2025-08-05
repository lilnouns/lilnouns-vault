// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

import { Test } from "forge-std/Test.sol";
import { LilNounsVault } from "../src/LilNounsVault.sol";
import { ERC20Mock } from "../src/mocks/ERC20Mock.sol";
import { ERC721Mock } from "../src/mocks/ERC721Mock.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol"; // Import the UUPS proxy
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract LilNounsVaultTest is Test, IERC721Receiver {
  LilNounsVault public vault;
  ERC20Mock public erc20;
  ERC721Mock public erc721;
  LilNounsVault public newImplementation;
  address public owner;
  address public addr1;
  address public addr2;
  address public addr3;

  // Setup function to deploy contracts before each test
  function setUp() public {
    owner = address(this);
    addr1 = vm.addr(1);
    addr2 = vm.addr(2);
    addr3 = vm.addr(3);

    // Deploy the LilNounsVault contract and initialize it via the proxy
    LilNounsVault implementation = new LilNounsVault();
    ERC1967Proxy proxy = new ERC1967Proxy(
      address(implementation),
      abi.encodeWithSelector(LilNounsVault.initialize.selector)
    );

    vault = LilNounsVault(payable(address(proxy))); // Cast proxy to LilNounsVault using payable conversion

    // Deploy the ERC20 token
    erc20 = new ERC20Mock("TestToken", "TTK");
    erc20.mint(address(owner), 1000);

    // Deploy the ERC721 token
    erc721 = new ERC721Mock("TestNFT", "TNFT");

    // Deploy a new implementation mock for upgrade testing
    newImplementation = new LilNounsVault();
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

  // Add a receive function to accept ETH
  receive() external payable {}

  // Test for deployment and initialization
  function testDeploymentAndInitialization() public view {
    assertEq(vault.owner(), owner);
  }

  // Test for receiving ETH
  function testETHReception() public {
    uint256 initialBalance = address(vault).balance;

    // Send 1 ETH to the contract
    vm.deal(addr1, 1 ether);
    vm.prank(addr1);
    (bool success, ) = address(vault).call{ value: 1 ether }("");
    require(success, "ETH transfer failed");

    uint256 finalBalance = address(vault).balance;
    assertEq(finalBalance - initialBalance, 1 ether);
  }

  // Test for receiving ERC-20 tokens
  function testERC20Reception() public {
    // Transfer 100 tokens to the contract
    erc20.transfer(address(vault), 100);

    uint256 contractBalance = erc20.balanceOf(address(vault));
    assertEq(contractBalance, 100);
  }

  // Test for receiving ERC-721 tokens
  function testERC721Reception() public {
    // Mint a new NFT and transfer it to the contract
    erc721.mint(addr1, 1);

    vm.prank(addr1);
    erc721.safeTransferFrom(addr1, address(vault), 1);

    address ownerOfToken = erc721.ownerOf(1);
    assertEq(ownerOfToken, address(vault));
  }

  // Test for pausing the contract with block numbers
  function testPauseWithTimestamps() public {
    uint256 startTimestamp = block.timestamp + 5;
    uint256 endTimestamp = block.timestamp + 10;

    vault.pause(startTimestamp, endTimestamp);

    // Fast-forward to the start timestamp
    vm.warp(startTimestamp);
    assertTrue(vault.paused(), "Contract should be paused");

    // Attempt to unpause during the pause period (should fail)
    vm.expectRevert(LilNounsVault.EnforcedPausePeriod.selector);
    vault.unpause();

    // Fast-forward to the end timestamp
    vm.warp(endTimestamp + 1);
    vault.unpause();
    assertFalse(vault.paused(), "Contract should be unpaused");
  }

  // Test that upgrading is blocked during pause period
  function testUpgradeBlockedDuringPause() public {
    uint256 startTimestamp = block.timestamp + 5;
    uint256 endTimestamp = block.timestamp + 10;

    vault.pause(startTimestamp, endTimestamp);

    // Fast-forward to the start timestamp
    vm.warp(startTimestamp);

    // Attempt to upgrade during the pause period (should fail)
    vm.expectRevert(LilNounsVault.EnforcedPausePeriod.selector);
    vault.upgradeToAndCall(address(newImplementation), "");
  }

  // Test for invalid pause period
  function testInvalidPausePeriod() public {
    // Pause end timestamp is less than start timestamp
    vm.expectRevert(LilNounsVault.InvalidPausePeriod.selector);
    vault.pause(block.timestamp + 10, block.timestamp + 5);

    // Pause start timestamp is in the past
    vm.expectRevert(LilNounsVault.InvalidPausePeriod.selector);
    vault.pause(block.timestamp - 1, block.timestamp + 10);
  }

  // Test for withdrawing ERC721 tokens
  function testWithdrawERC721() public {
    // Mint the NFT to addr1
    erc721.mint(addr1, 1);

    // Transfer the NFT to the LilNounsVault contract
    vm.prank(addr1);
    erc721.safeTransferFrom(addr1, address(vault), 1);

    // Verify the contract received the NFT
    assertEq(erc721.ownerOf(1), address(vault));

    // Withdraw the NFT from the vault to the owner
    vault.withdraw(erc721, 1);

    // Verify the owner received the NFT
    assertEq(erc721.ownerOf(1), owner);
  }

  // Test for withdrawing ETH
  function testWithdrawETH() public {
    // Send 1 ETH to the contract
    vm.deal(addr1, 1 ether);
    vm.prank(addr1);
    (bool success, ) = address(vault).call{ value: 1 ether }("");
    require(success, "ETH transfer failed");

    // Check the balance of the contract
    uint256 contractBalance = address(vault).balance;
    assertEq(contractBalance, 1 ether, "Contract did not receive the ETH");

    // Withdraw the ETH
    uint256 initialOwnerBalance = owner.balance;
    vault.withdraw();

    assertEq(
      owner.balance,
      initialOwnerBalance + 1 ether,
      "ETH withdrawal failed"
    );
  }

  // Test for withdrawing ERC20 tokens
  function testWithdrawERC20() public {
    // Transfer 100 tokens to the contract
    erc20.transfer(address(vault), 100);

    // Withdraw the tokens
    uint256 initialOwnerBalance = erc20.balanceOf(owner);
    vault.withdraw(erc20);

    assertEq(erc20.balanceOf(owner), initialOwnerBalance + 100);
  }

  function testDelegateERC20Votes() public {
    vm.prank(owner); // Set msg.sender to owner
    vault.delegate(address(erc20), addr3);

    assertEq(
      erc20.delegates(address(vault)),
      addr3,
      "Delegation of ERC20Votes failed"
    );
  }

  function testDelegateERC721Votes() public {
    vm.prank(owner); // Set msg.sender to owner
    vault.delegate(address(erc721), addr3);

    assertEq(
      erc721.delegates(address(vault)),
      addr3,
      "Delegation of ERC721Votes failed"
    );
  }

  function testDelegateRevertsOnZeroAddress() public {
    vm.prank(owner); // Set msg.sender to owner
    vm.expectRevert(
      abi.encodeWithSelector(LilNounsVault.ZeroAddressError.selector)
    );
    vault.delegate(address(erc20), address(0));
  }
}
