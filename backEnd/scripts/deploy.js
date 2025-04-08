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

  // Deploy CrowdfundingManager
  const CrowdfundingManager = await ethers.getContractFactory("CrowdfundingManager");
  const manager = await upgrades.deployProxy(
    CrowdfundingManager,
    { initializer: "initialize" }
  );
  await manager.waitForDeployment();
  console.log("CrowdfundingManager proxy deployed at:", await manager.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
