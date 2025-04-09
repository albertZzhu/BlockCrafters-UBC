// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ICrowdfundingManager{
    function createProject(
        string memory projectName,
        uint256 fundingDeadline,
        string memory descCID,
        string memory photoCID,
        string memory socialMediaLinkCID,
        string memory tokenName,
        string memory tokenSymbolCID
    ) external;

    function getFounderProjects(address founder) external view returns (uint256[] memory);

    function getPlatformOwner() external view returns (address);

    function setPlatformOwner(address newOwner) external;
}