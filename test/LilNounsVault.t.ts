import { expect } from "chai";
import { ethers } from "hardhat";
import {
  loadFixture,
  time,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { LilNounsVault, ERC20Mock, ERC721Mock } from "../typechain-types";

describe("LilNounsVault", function () {
  async function deployVaultAndTokens() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy ERC-20 token for testing
    const erc20 = (await ethers.deployContract("ERC20Mock", [
      "TestToken",
      "TTK",
      owner.address,
      1000n,
    ])) as ERC20Mock;

    // Deploy ERC-721 token for testing
    const erc721 = (await ethers.deployContract("ERC721Mock", [
      "TestNFT",
      "TNFT",
    ])) as ERC721Mock;

    // Deploy LilNounsVault contract
    const lilNounsVault = (await ethers.deployContract(
      "LilNounsVault",
    )) as LilNounsVault;

    // Initialize the vault contract
    await lilNounsVault.initialize();

    return { lilNounsVault, erc20, erc721, owner, addr1, addr2 };
  }

  describe("Deployment and Initialization", function () {
    it("should deploy and initialize the contract correctly", async function () {
      const { lilNounsVault } = await loadFixture(deployVaultAndTokens);
      expect(await lilNounsVault.getAddress()).to.not.be.null;
    });
  });

  describe("ETH Handling", function () {
    it("should receive ETH correctly", async function () {
      const { lilNounsVault, addr1 } = await loadFixture(deployVaultAndTokens);
      const initialBalance = await ethers.provider.getBalance(
        await lilNounsVault.getAddress(),
      );

      // Send 1 ETH to the contract
      await addr1.sendTransaction({
        to: await lilNounsVault.getAddress(),
        value: ethers.parseEther("1"),
      });

      const finalBalance = await ethers.provider.getBalance(
        await lilNounsVault.getAddress(),
      );
      expect(finalBalance - initialBalance).to.equal(ethers.parseEther("1"));
    });
  });

  describe("ERC-20 Token Handling", function () {
    it("should receive ERC-20 tokens correctly", async function () {
      const { lilNounsVault, erc20, addr1 } =
        await loadFixture(deployVaultAndTokens);

      // Transfer 100 tokens to the contract
      await erc20.transfer(await lilNounsVault.getAddress(), 100n);

      const contractBalance = await erc20.balanceOf(
        await lilNounsVault.getAddress(),
      );
      expect(contractBalance).to.equal(100n);
    });
  });

  describe("ERC-721 Token Handling", function () {
    it("should receive ERC-721 tokens correctly", async function () {
      const { lilNounsVault, erc721, addr1 } =
        await loadFixture(deployVaultAndTokens);

      // Mint a new NFT and transfer it to the contract
      await erc721.mint(addr1.address, 1);
      await erc721
        .connect(addr1)
        .transferFrom(addr1.address, await lilNounsVault.getAddress(), 1);

      const ownerOfToken = await erc721.ownerOf(1);
      expect(ownerOfToken).to.equal(await lilNounsVault.getAddress());
    });
  });

  describe("NFT Withdrawal", function () {
    it("should revert NFT withdrawal if the contract is paused", async function () {
      const { lilNounsVault, erc721, owner, addr1 } =
        await loadFixture(deployVaultAndTokens);
      const currentBlock = await ethers.provider.getBlockNumber();
      const currentTimestamp =
        (await ethers.provider.getBlock(currentBlock))?.timestamp ?? 0;

      // Mint and transfer an NFT to the contract
      await erc721.mint(addr1.address, 1);
      await erc721
        .connect(addr1)
        .transferFrom(addr1.address, await lilNounsVault.getAddress(), 1);

      // Pause the contract with block numbers based on the current timestamp
      await lilNounsVault
        .connect(owner)
        .pause(currentBlock + 10, currentBlock + 20);

      // Fast forward to a time within the pause period
      await time.increaseTo(currentTimestamp + 15);

      // Attempt to withdraw the NFT (should fail)
      const withdrawERC721Function = "withdraw(address,uint256)";
      await expect(
        lilNounsVault
          .connect(owner)
          [withdrawERC721Function](erc721.getAddress(), 1),
      ).to.be.revertedWithCustomError(lilNounsVault, "EnforcedPause");

      // Fast forward to a time after the pause period and withdraw the NFT
      await time.increaseTo(currentTimestamp + 21);
      await lilNounsVault.connect(owner).unpause();
      await lilNounsVault
        .connect(owner)
        [withdrawERC721Function](erc721.getAddress(), 1);
      expect(await erc721.ownerOf(1)).to.equal(await owner.getAddress());
    });
  });
});
