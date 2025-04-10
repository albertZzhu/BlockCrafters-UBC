// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./CrowdfundingProject.sol";
import "./TokenManager.sol";
import {IProjectVotingManager, ProjectVotingCreated} from "./ProjectVotingManager.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CrowdfundingManager is Initializable {
    address public platformOwner;
    mapping(address => CrowdfundingProject) public projects;
    uint256 public projectCount;
    IProjectVotingManager private ProjectVotingManager;

    mapping(address founderAddress => address[]) public founderProjectMap;

    modifier onlyPlatformOwner(){
        require(msg.sender == platformOwner, "Not the platform owner");
        _;
    }

    event ProjectCreated(
        // uint256 indexed projectId,
        address indexed projectAddress,
        address indexed founder,
        uint256 fundingDeadline,
        string descCID,
        string photoCID,
        string socialMediaLinkCID,
        string tokenName,
        string tokenSymbolCID
    );

    event ProjectStatusUpdated(
        address indexed projectAddress,
        uint256 projectId,
        CrowdfundingProject.ProjectStatus status
    );

    event CrowdfundingManagerUpdated(
        address indexed oldOwner,
        address indexed newOwner
    );

    function initialize(address projectVotingManagerAddress) public initializer {
        platformOwner = msg.sender;
        ProjectVotingManager = IProjectVotingManager(projectVotingManagerAddress);
        ProjectVotingManager.setCrowdfundingManager(address(this));
    }
    
    // assumption (supportive) function
    function createProject(
            string memory projectName,
            uint256 fundingDeadline,
            string memory descCID,
            string memory photoCID,
            string memory socialMediaLinkCID,
            string memory tokenName,
            string memory tokenSymbolCID
        ) external {
        // Create a new project, the Project starts without a milestone.
        require(bytes(projectName).length > 0 && bytes(projectName).length <= 100, "Project name length must be between 1 and 100 characters");
        require(bytes(descCID).length == 32, "Invalid IPFS hash");      
        require(bytes(photoCID).length == 32, "Invalid IPFS hash");      
        require(bytes(socialMediaLinkCID).length == 32, "Invalid IPFS hash");      
        require(fundingDeadline > block.timestamp, "Deadline must be in the future");
        projectCount++;

        TokenManager tokenManager = new TokenManager(address(this));
        tokenManager.deployToken(tokenName, tokenSymbolCID);

        CrowdfundingProject project = new CrowdfundingProject(
            msg.sender,
            projectCount,
            projectName,
            fundingDeadline,
            descCID,
            photoCID,
            socialMediaLinkCID,
            tokenManager
        );

        address projectAddress = address(project);
        address voting = ProjectVotingManager.createVotingPlatfrom(projectAddress);
        
        project.setVotingPlatform(voting);
        tokenManager.setCrowdfundingProject(projectAddress);

        projects[projectAddress] = project;
        founderProjectMap[msg.sender].push(projectAddress);
        emit ProjectCreated(projectAddress, msg.sender,fundingDeadline, descCID, photoCID, socialMediaLinkCID, tokenName, tokenSymbolCID);
    }

    function getFounderProjects(address founder) external view returns (address[] memory) {
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