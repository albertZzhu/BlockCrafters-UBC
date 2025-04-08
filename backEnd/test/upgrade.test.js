const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");
// const { it, beforeEach } = require("node:test");
const {upgradeContract} = require("../scripts/upgrade.js");
describe("App", function () {
    const AMOUNT = ethers.parseEther("0.01"); //bignumber
    let app,
        appAddress,
        upgradedApp,
        upgradedAppAddress;
    let owner, attacker;

    // this.timeout(150000);
    beforeEach(async function () {
        [owner, attacker] = await ethers.getSigners();

        const App = await ethers.getContractFactory("CrowdfundingManager");

        app = await upgrades.deployProxy(App);
        await app.waitForDeployment();
        appAddress = await app.getAddress();
        console.log("App address:", appAddress);

        // attackAddress = await attack.getAddress();
        // console.log("Attack address:", attackAddress);
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