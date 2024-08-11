import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import {
  loadFixture,
  time,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ERC20Mock, ERC721Mock, LilNounsVault } from "../typechain-types";

describe("LilNounsVault", function () {
  async function deployVaultAndTokens() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy ERC-20 token for testing
    const erc20 = (await ethers.deployContract("ERC20Mock", [
      "TestToken",
      "TTK",
    ])) as ERC20Mock;
    await erc20.mint(owner.address, 1000n);

    // Deploy ERC-721 token for testing
    const erc721 = (await ethers.deployContract("ERC721Mock", [
      "TestNFT",
      "TNFT",
    ])) as ERC721Mock;

    // Deploy LilNounsVault implementation as a UUPS proxy
    const vault = (await upgrades.deployProxy(
      await ethers.getContractFactory("LilNounsVault"),
      [], // Arguments to the initialize function
      { kind: "uups" },
    )) as unknown as LilNounsVault;

    // Deploy a new instance of LilNounsVault for upgrade testing
    const newImplementation = await ethers.getContractFactory("LilNounsVault");

    return {
      vault,
      erc20,
      erc721,
      owner,
      addr1,
      addr2,
      newImplementation,
    };
  }

  describe("Deployment and Initialization", function () {
    it("should deploy and initialize the contract correctly", async function () {
      const { vault, owner } = await loadFixture(deployVaultAndTokens);
      expect(await vault.owner()).to.equal(await owner.getAddress());
    });
  });

  describe("ETH Handling", function () {
    it("should receive ETH correctly", async function () {
      const { vault, addr1 } = await loadFixture(deployVaultAndTokens);
      const initialBalance = await ethers.provider.getBalance(
        await vault.getAddress(),
      );

      // Send 1 ETH to the contract
      await addr1.sendTransaction({
        to: await vault.getAddress(),
        value: ethers.parseEther("1"),
      });

      const finalBalance = await ethers.provider.getBalance(
        await vault.getAddress(),
      );
      expect(finalBalance - initialBalance).to.equal(ethers.parseEther("1"));
    });
  });

  describe("ERC-20 Token Handling", function () {
    it("should receive ERC-20 tokens correctly", async function () {
      const { vault, erc20 } = await loadFixture(deployVaultAndTokens);

      // Transfer 100 tokens to the contract
      await erc20.transfer(await vault.getAddress(), 100n);

      const contractBalance = await erc20.balanceOf(await vault.getAddress());
      expect(contractBalance).to.equal(100n);
    });
  });

  describe("ERC-721 Token Handling", function () {
    it("should receive ERC-721 tokens correctly", async function () {
      const { vault, erc721, addr1 } = await loadFixture(deployVaultAndTokens);

      // Mint a new NFT and transfer it to the contract
      await erc721.mint(addr1.address, 1);
      await erc721
        .connect(addr1)
        .transferFrom(addr1.address, await vault.getAddress(), 1);

      const ownerOfToken = await erc721.ownerOf(1);
      expect(ownerOfToken).to.equal(await vault.getAddress());
    });
  });

  describe("Pause and Unpause", function () {
    it("should pause and unpause correctly with timestamps", async function () {
      const { vault, owner } = await loadFixture(deployVaultAndTokens);
      const currentBlock = await ethers.provider.getBlockNumber();
      const currentTimestamp =
        (await ethers.provider.getBlock(currentBlock))?.timestamp ?? 0;

      const startTimestamp = currentTimestamp + 5;
      const endTimestamp = currentTimestamp + 10;

      await vault.connect(owner).pause(startTimestamp, endTimestamp);

      // Fast forward to the start timestamp
      await time.increaseTo(startTimestamp);
      expect(await vault.paused()).to.be.true;

      // Attempt to unpause during the pause period (should fail)
      await expect(
        vault.connect(owner).unpause(),
      ).to.be.revertedWithCustomError(vault, "EnforcedPausePeriod");

      // Fast forward to the end timestamp
      await time.increaseTo(endTimestamp + 1);
      await vault.connect(owner).unpause();
      expect(await vault.paused()).to.be.false;
    });

    it("should block upgrades during the pause period", async function () {
      const { vault, newImplementation, owner } =
        await loadFixture(deployVaultAndTokens);
      const currentBlock = await ethers.provider.getBlockNumber();
      const currentTimestamp =
        (await ethers.provider.getBlock(currentBlock))?.timestamp ?? 0;

      const startTimestamp = currentTimestamp + 5;
      const endTimestamp = currentTimestamp + 10;

      await vault.connect(owner).pause(startTimestamp, endTimestamp);

      // Fast forward to the start timestamp
      await time.increaseTo(startTimestamp);

      // Attempt to upgrade during the pause period (should fail)
      await expect(
        upgrades.upgradeProxy(await vault.getAddress(), newImplementation),
      ).to.be.revertedWithCustomError(vault, "EnforcedPausePeriod");
    });

    it("should revert with invalid pause periods", async function () {
      const { vault, owner } = await loadFixture(deployVaultAndTokens);

      // Pause end timestamp is less than start timestamp
      await expect(
        vault
          .connect(owner)
          .pause((await time.latest()) + 10, (await time.latest()) + 5),
      ).to.be.revertedWithCustomError(vault, "InvalidPausePeriod");

      // Pause start timestamp is in the past
      await expect(
        vault
          .connect(owner)
          .pause((await time.latest()) - 1, (await time.latest()) + 10),
      ).to.be.revertedWithCustomError(vault, "InvalidPausePeriod");
    });
  });

  describe("Withdrawals", function () {
    it("should withdraw ERC721 tokens correctly", async function () {
      const { vault, erc721, owner, addr1 } =
        await loadFixture(deployVaultAndTokens);

      // Mint and transfer an NFT to the contract
      await erc721.mint(addr1.address, 1);
      await erc721
        .connect(addr1)
        .transferFrom(addr1.address, await vault.getAddress(), 1);

      expect(await erc721.ownerOf(1)).to.equal(await vault.getAddress());

      // Withdraw the NFT from the vault to the owner using the correct overloaded function
      const withdrawERC721 = "withdraw(address,uint256)";
      await vault.connect(owner)[withdrawERC721](erc721.getAddress(), 1);

      expect(await erc721.ownerOf(1)).to.equal(await owner.getAddress());
    });

    it("should withdraw ETH correctly", async function () {
      const { vault, owner, addr1 } = await loadFixture(deployVaultAndTokens);

      // Send 1 ETH to the contract
      await addr1.sendTransaction({
        to: await vault.getAddress(),
        value: ethers.parseEther("1"),
      });

      const contractBalance = await ethers.provider.getBalance(
        await vault.getAddress(),
      );
      expect(contractBalance).to.equal(ethers.parseEther("1"));

      const ownerBalanceBefore = await ethers.provider.getBalance(
        owner.address,
      );

      // Withdraw the ETH
      const withdrawETH = "withdraw()";
      const tx = await vault.connect(owner)[withdrawETH]();
      const receipt = await tx.wait();

      // @ts-ignore
      const gasUsed = receipt.gasUsed * tx.gasPrice;

      const ownerBalanceAfter = await ethers.provider.getBalance(owner.address);
      const expectedBalance =
        ownerBalanceBefore + ethers.parseEther("1") - gasUsed;

      expect(ownerBalanceAfter).to.be.closeTo(
        expectedBalance,
        ethers.parseEther("0.001"),
      );
    });

    it("should withdraw ERC20 tokens correctly", async function () {
      const { vault, erc20, owner } = await loadFixture(deployVaultAndTokens);

      const initialBalance = await erc20.balanceOf(owner.address);

      // Transfer 100 tokens to the contract
      await erc20.transfer(await vault.getAddress(), 100n);

      // Withdraw the tokens using the correct overloaded function
      const withdrawERC20 = "withdraw(address)";
      await vault.connect(owner)[withdrawERC20](erc20.getAddress());

      const finalBalance = await erc20.balanceOf(owner.address);
      expect(finalBalance).to.equal(initialBalance);
    });
  });
});
