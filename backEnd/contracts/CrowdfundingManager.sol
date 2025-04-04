// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./CrowdfundingProject.sol";
// import "./ICrowdfundingProject.sol";
import "./ProjectVoting.sol";

contract CrowdfundingManager{
    address public platformOwner;
    mapping(uint256 => CrowdfundingProject) public projects;
    uint256 public projectCount;

    mapping(address => uint256[]) public founderProjectMap;

    modifier onlyPlatformOwner(){
        require(msg.sender == platformOwner, "Not the platform owner");
        _;
    }

    // modifier onlyDistinctProject(uint256 _projectID) {
    //     require(_projectID <= projectCount, "Project does not exist");
    //     _;
    // }

    event ProjectCreated(
        uint256 indexed projectId,
        address indexed founder,
        uint256 fundingDeadline,
        string tokenName,
        string tokenSymbol,
        uint256 tokenSupply,
        string descCID,
        string photoCID,
        string socialMediaLinkCID
    );

    event ProjectStatusUpdated(
        uint256 projectId,
        CrowdfundingProject.ProjectStatus status
    );

    event CrowdfundingManagerUpdated(
        address indexed oldOwner,
        address indexed newOwner
    );

    constructor() {
        platformOwner = msg.sender;
    }
    
    // assumption (supportive) function
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
        ) external {
        // Create a new project, the Project starts without a milestone.
        require(bytes(projectName).length > 0 && bytes(projectName).length <= 100, "Project name length must be between 1 and 100 characters");
        require(bytes(descCID).length == 32, "Invalid IPFS hash");      
        require(bytes(photoCID).length == 32, "Invalid IPFS hash");      
        require(bytes(socialMediaLinkCID).length == 32, "Invalid IPFS hash");      
        require(fundingDeadline > block.timestamp, "Deadline must be in the future");
        projectCount++;

        CrowdfundingProject project = new CrowdfundingProject(
            msg.sender,
            projectCount,
            projectName,
            fundingDeadline,
            tokenName,
            tokenSymbol,
            tokenSupply,
            salt,
            descCID,
            photoCID,
            socialMediaLinkCID
        );

        projects[projectCount] = project;

        founderProjectMap[msg.sender].push(projectCount);

        emit ProjectCreated(projectCount, msg.sender, fundingDeadline, tokenName, tokenSymbol, tokenSupply, descCID, photoCID, socialMediaLinkCID);
    }

    function getFounderProjects(address founder) external view returns (uint256[] memory) {
        return founderProjectMap[founder];
    }

    function getPlatformOwner() external view returns (address) {
        return platformOwner;
    }

    // change platformOwner to a new address, ONLY the current owner can change
    function setPlatformOwner(address newOwner) external onlyPlatformOwner() {
        address prevOwner = platformOwner;
        require(newOwner != address(0), "Invalid address");
        platformOwner = newOwner;

        emit CrowdfundingManagerUpdated(prevOwner, newOwner);
    }
    
}