const { ethers, upgrades } = require("hardhat");
const CONTRACT_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

async function upgradeContract(contractAddress, newContractName) {
    let time = Date.now();
    const [owner] = await ethers.getSigners();
    console.log("Upgrading contracts with the account:", owner.address);
    const contractFactory = await ethers.getContractFactory(newContractName);
    const updatedContract = await upgrades.upgradeProxy(contractAddress, contractFactory);
    console.log("Contract upgraded");

    let newContractAddress = await updatedContract.getAddress();
    console.log("Contract address:", newContractAddress);
    console.log("Time taken:", Date.now() - time);
    return updatedContract;
}
async function main() {
    await upgradeContract(CONTRACT_ADDRESS, 'CrowdfundingManagerV2')
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    main().catch((error) => {
        console.error(error);
        process.exitCode = 1;
    });
}

module.exports = {
    upgradeContract,
};