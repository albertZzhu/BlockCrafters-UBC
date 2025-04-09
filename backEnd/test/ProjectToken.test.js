
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProjectToken", function () {
  let token;
  let owner, project, investor, other;

  const name = "ProjectToken";
  const symbol = "PTK";

  beforeEach(async function () {
    [owner, project, investor, other] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("ProjectToken");
    token = await Token.deploy(name, symbol, project.address, owner.address);
    await token.waitForDeployment();
  });

  it("should have correct name, symbol, owner, and project", async function () {
    expect(await token.name()).to.equal(name);
    expect(await token.symbol()).to.equal(symbol);
    expect(await token.owner()).to.equal(owner.address);
    expect(await token.project()).to.equal(project.address);
  });

  it("should allow owner to mint tokens", async function () {
    await token.connect(owner).mint(investor.address, 1000);
    expect(await token.balanceOf(investor.address)).to.equal(1000);
  });

  it("should NOT allow non-owner to mint tokens", async function () {
    await expect(
      token.connect(other).mint(investor.address, 1000)
    ).to.be.revertedWith("Not the owner");
  });

  it("should allow owner to transfer ownership", async function () {
    await token.connect(owner).transferOwnership(other.address);
    expect(await token.owner()).to.equal(other.address);
  });

  it("should NOT allow non-owner to transfer ownership", async function () {
    await expect(
      token.connect(other).transferOwnership(investor.address)
    ).to.be.revertedWith("Not the owner");
  });
});
