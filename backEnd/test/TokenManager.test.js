
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TokenManager", function () {
  let TokenManager, ProjectToken;
  let manager, projectTokenAddress;
  let crowdfundingProject, investor, other;

  const name = "StartupToken";
  const symbol = "STK";

  beforeEach(async () => {
    [crowdfundingProject, investor, other] = await ethers.getSigners();

    TokenManager = await ethers.getContractFactory("TokenManager");
    manager = await TokenManager.connect(crowdfundingProject).deploy(crowdfundingProject.address);
    await manager.waitForDeployment();

    ProjectToken = await ethers.getContractFactory("ProjectToken");
  });

  it("should compute the expected token address before deployment", async () => {
    const computed = await manager.computeTokenAddress(name, symbol);
    expect(ethers.isAddress(computed)).to.be.true;
  });

  it("should deploy a token using CREATE2 and save address", async () => {
    const tx = await manager.connect(crowdfundingProject).deployToken(name, symbol);
    const receipt = await tx.wait();

    const event = receipt.logs.find(log => log.fragment.name === "TokenDeployed");
    projectTokenAddress = event.args.token;

    expect(await manager.projectToken()).to.equal(projectTokenAddress);
    expect(ethers.isAddress(projectTokenAddress)).to.be.true;
  });

  it("should not allow duplicate token deployment", async () => {
    await manager.connect(crowdfundingProject).deployToken(name, symbol);
    await expect(
      manager.connect(crowdfundingProject).deployToken(name, symbol)
    ).to.be.revertedWith("Token already deployed");
  });

  it("should allow only crowdfunding project to deploy token", async () => {
    await expect(
      manager.connect(other).deployToken(name, symbol)
    ).to.be.revertedWith("Not authorized");
  });

  it("should mint tokens to investor via deployed token", async () => {
    const tx = await manager.connect(crowdfundingProject).deployToken(name, symbol);
    const receipt = await tx.wait();
    const tokenAddress = receipt.logs.find(log => log.fragment.name === "TokenDeployed").args.token;

    const tokenInstance = await ethers.getContractAt("ProjectToken", tokenAddress);

    await manager.connect(crowdfundingProject).mintTo(investor.address, 500);
    expect(await tokenInstance.balanceOf(investor.address)).to.equal(500);
  });

  it("should NOT mint if token is not yet deployed", async () => {
    await expect(
      manager.connect(crowdfundingProject).mintTo(investor.address, 100)
    ).to.be.revertedWith("Token not deployed");
  });

  it("should NOT allow minting from non-project account", async () => {
    await manager.connect(crowdfundingProject).deployToken(name, symbol);
    await expect(
      manager.connect(other).mintTo(investor.address, 100)
    ).to.be.revertedWith("Not authorized");
  });
});
