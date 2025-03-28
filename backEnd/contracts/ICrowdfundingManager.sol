// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ICrowdfundingManager{
    function getFounderProjects(address founder) external view returns (uint256[] memory);
    
    function createProject(
        string memory projectName,
        uint256 fundingDeadline,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 tokenSupply,
        bytes32 salt,
        string memory descCID,
        string memory photoCID,
        string memory socialMediaLinkCID
    ) external;

    function withdraw(uint256 _projectId) external;

    function updatePlatformOwner(address newOwner) external;
}