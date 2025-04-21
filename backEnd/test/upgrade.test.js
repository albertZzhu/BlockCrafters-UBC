const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");
// const { it, beforeEach } = require("node:test");
const {upgradeContract} = require("../scripts/upgrade.js");
describe("Contract Upgrade", function () {
    const AMOUNT = ethers.parseEther("0.01"); //bignumber
    let app,
        appAddress,
        upgradedApp,
        upgradedAppAddress;
    let owner;

    // this.timeout(150000);
    before(async function () {
        [owner] = await ethers.getSigners();

        // Deploy addressProvider
        let addressProviderFactory = await ethers.getContractFactory("AddressProvider");
        let addressProvider = await addressProviderFactory.deploy();
        await addressProvider.waitForDeployment();
        // Deploy votingManager+tokenManager+CrowdfundingManager
        let votingManagerFactory = await ethers.getContractFactory("ProjectVotingManager");
        let votingManager = await upgrades.deployProxy(
            votingManagerFactory, [addressProvider.target], { initializer: 'initialize' }
        );
        await votingManager.waitForDeployment();
        await addressProvider.connect(owner).setProjectVotingManager(await votingManager.getAddress());

        let tokenManagerFactory = await ethers.getContractFactory("TokenManager");
        let tokenManager = await upgrades.deployProxy(
            tokenManagerFactory, [addressProvider.target], { initializer: 'initialize' }
        );
        await tokenManager.waitForDeployment();
        await addressProvider.connect(owner).setTokenManager(await tokenManager.getAddress());

        let CrowdfundingManager = await ethers.getContractFactory("CrowdfundingManager");
        let app = await upgrades.deployProxy(
            CrowdfundingManager,
            [addressProvider.target],
            { initializer: "initialize" }
        );
        await app.waitForDeployment();
        appAddress = await app.getAddress();
        await addressProvider.connect(owner).setCrowdfundingManager(appAddress);

        upgradedApp = await upgradeContract(appAddress, "CrowdfundingManagerV2");
        await upgradedApp.waitForDeployment();
        upgradedAppAddress = await upgradedApp.getAddress();
    });

    it("Upgraded App should have the same address as the old one", async function () {
        console.log("app address:", appAddress);
        console.log("upgraded app address:", upgradedAppAddress);
        expect(upgradedAppAddress).to.be.equal(appAddress);
    });
    it("Upgraded App should have the new function (dummyFunction)", async function () {
        const res = await upgradedApp.dummyFunction();
        expect(res).to.be.equal("Dummy function to test contract upgradeability");
    });

});