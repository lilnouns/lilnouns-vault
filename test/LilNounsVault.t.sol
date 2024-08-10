// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LilNounsVault.sol";
import "../src/mocks/ERC20Mock.sol";
import "../src/mocks/ERC721Mock.sol";

contract LilNounsVaultTest is Test {
  LilNounsVault public lilNounsVault;
  ERC20Mock public erc20;
  ERC721Mock public erc721;
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

    // Deploy the LilNounsVault contract
    lilNounsVault = new LilNounsVault();
    lilNounsVault.initialize();
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
}
