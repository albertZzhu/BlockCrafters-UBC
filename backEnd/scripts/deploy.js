const { ethers, upgrades } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with:", deployer.address);

    // Deploy UserRegister
    const UserRegister = await ethers.getContractFactory("UserRegister");
    const userRegister = await UserRegister.deploy();
    await userRegister.waitForDeployment();
    console.log("UserRegister deployed at:", await userRegister.getAddress());

    // Deploy PriceFeed
    const PriceFeed = await ethers.getContractFactory("PriceFeed");
    const priceFeed = await PriceFeed.deploy();
    await priceFeed.waitForDeployment();
    console.log("PriceFeed deployed at:", await priceFeed.getAddress());

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
    await addressProvider.connect(deployer).setProjectVotingManager(await votingManager.getAddress());

    let tokenManagerFactory = await ethers.getContractFactory("TokenManager");
    let tokenManager = await upgrades.deployProxy(
        tokenManagerFactory, [addressProvider.target], { initializer: 'initialize' }
    );
    await tokenManager.waitForDeployment();
    await addressProvider.connect(deployer).setTokenManager(await tokenManager.getAddress());

    let CrowdfundingManager = await ethers.getContractFactory("CrowdfundingManager");
    let manager = await upgrades.deployProxy(
        CrowdfundingManager,
        [addressProvider.target],
        { initializer: "initialize" }
    );
    await manager.waitForDeployment();
    await addressProvider.connect(deployer).setCrowdfundingManager(await manager.getAddress());
    
    console.log("CrowdfundingManager proxy deployed at:", await manager.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
