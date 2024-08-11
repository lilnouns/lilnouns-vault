import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
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

    // Deploy LilNounsVault implementation as a UUPS proxy
    const lilNounsVault = (await upgrades.deployProxy(
      await ethers.getContractFactory("LilNounsVault"),
      [], // Arguments to the initialize function
      { kind: "uups" },
    )) as unknown as LilNounsVault;

    // Deploy a new instance of LilNounsVault for upgrade testing
    const newImplementation = await ethers.getContractFactory("LilNounsVault");

    return {
      lilNounsVault,
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
      const { lilNounsVault, owner } = await loadFixture(deployVaultAndTokens);
      expect(await lilNounsVault.owner()).to.equal(await owner.getAddress());
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
      const { lilNounsVault, erc20 } = await loadFixture(deployVaultAndTokens);

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

  describe("Pause and Unpause", function () {
    it("should pause and unpause correctly with timestamps", async function () {
      const { lilNounsVault, owner } = await loadFixture(deployVaultAndTokens);
      const currentBlock = await ethers.provider.getBlockNumber();
      const currentTimestamp =
        (await ethers.provider.getBlock(currentBlock))?.timestamp ?? 0;

      const startTimestamp = currentTimestamp + 5;
      const endTimestamp = currentTimestamp + 10;

      await lilNounsVault.connect(owner).pause(startTimestamp, endTimestamp);

      // Fast forward to the start timestamp
      await time.increaseTo(startTimestamp);
      expect(await lilNounsVault.paused()).to.be.true;

      // Attempt to unpause during the pause period (should fail)
      await expect(
        lilNounsVault.connect(owner).unpause(),
      ).to.be.revertedWithCustomError(
        lilNounsVault,
        "CannotUnpauseDuringPausePeriod",
      );

      // Fast forward to the end timestamp
      await time.increaseTo(endTimestamp + 1);
      await lilNounsVault.connect(owner).unpause();
      expect(await lilNounsVault.paused()).to.be.false;
    });

    it("should block upgrades during the pause period", async function () {
      const { lilNounsVault, newImplementation, owner } =
        await loadFixture(deployVaultAndTokens);
      const currentBlock = await ethers.provider.getBlockNumber();
      const currentTimestamp =
        (await ethers.provider.getBlock(currentBlock))?.timestamp ?? 0;

      const startTimestamp = currentTimestamp + 5;
      const endTimestamp = currentTimestamp + 10;

      await lilNounsVault.connect(owner).pause(startTimestamp, endTimestamp);

      // Fast forward to the start timestamp
      await time.increaseTo(startTimestamp);

      // Attempt to upgrade during the pause period (should fail)
      await expect(
        upgrades.upgradeProxy(await lilNounsVault.getAddress(), newImplementation),
      ).to.be.revertedWithCustomError(
        lilNounsVault,
        "UpgradeNotAllowedWhilePaused",
      );
    });

    it("should revert with invalid pause periods", async function () {
      const { lilNounsVault, owner } = await loadFixture(deployVaultAndTokens);

      // Pause end timestamp is less than start timestamp
      await expect(
        lilNounsVault
          .connect(owner)
          .pause((await time.latest()) + 10, (await time.latest()) + 5),
      ).to.be.revertedWithCustomError(lilNounsVault, "InvalidPausePeriod");

      // Pause start timestamp is in the past
      await expect(
        lilNounsVault
          .connect(owner)
          .pause((await time.latest()) - 1, (await time.latest()) + 10),
      ).to.be.revertedWithCustomError(lilNounsVault, "InvalidPausePeriod");
    });
  });

  describe("Withdrawals", function () {
    it("should withdraw ERC721 tokens correctly", async function () {
      const { lilNounsVault, erc721, owner, addr1 } =
        await loadFixture(deployVaultAndTokens);

      // Mint and transfer an NFT to the contract
      await erc721.mint(addr1.address, 1);
      await erc721
        .connect(addr1)
        .transferFrom(addr1.address, await lilNounsVault.getAddress(), 1);

      expect(await erc721.ownerOf(1)).to.equal(
        await lilNounsVault.getAddress(),
      );

      // Withdraw the NFT from the vault to the owner using the correct overloaded function
      const withdrawERC721 = "withdraw(address,uint256)";
      await lilNounsVault
        .connect(owner)
        [withdrawERC721](erc721.getAddress(), 1);

      expect(await erc721.ownerOf(1)).to.equal(await owner.getAddress());
    });

    it("should withdraw ETH correctly", async function () {
      const { lilNounsVault, owner, addr1 } =
        await loadFixture(deployVaultAndTokens);

      // Send 1 ETH to the contract
      await addr1.sendTransaction({
        to: await lilNounsVault.getAddress(),
        value: ethers.parseEther("1"),
      });

      const contractBalance = await ethers.provider.getBalance(
        await lilNounsVault.getAddress(),
      );
      expect(contractBalance).to.equal(ethers.parseEther("1"));

      // Withdraw the ETH using the correct overloaded function
      const withdrawETH = "withdraw()";
      await lilNounsVault.connect(owner)[withdrawETH]();

      const finalOwnerBalance = await ethers.provider.getBalance(owner.address);
      expect(finalOwnerBalance).to.be.closeTo(
        (await ethers.provider.getBalance(owner.address)) +
          ethers.parseEther("1"),
        ethers.parseEther("0.001"), // Accounting for gas costs
      );
    });

    it("should withdraw ERC20 tokens correctly", async function () {
      const { lilNounsVault, erc20, owner } =
        await loadFixture(deployVaultAndTokens);

      // Transfer 100 tokens to the contract
      await erc20.transfer(await lilNounsVault.getAddress(), 100n);

      // Withdraw the tokens using the correct overloaded function
      const withdrawERC20 = "withdraw(address)";
      await lilNounsVault.connect(owner)[withdrawERC20](erc20.getAddress());

      expect(await erc20.balanceOf(owner.address)).to.equal(
        (await erc20.balanceOf(owner.address)) + 100n,
      );
    });
  });
});
