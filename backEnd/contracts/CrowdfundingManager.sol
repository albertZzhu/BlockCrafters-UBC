// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./CrowdfundingProject.sol";
import "./ICrowdfundingProject.sol";
import {ITokenManager} from "./TokenManager.sol";
import {IProjectVotingManager, ProjectVotingCreated} from "./ProjectVotingManager.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CrowdfundingManager is Initializable {
    address public platformOwner;
    mapping(address => CrowdfundingProject) public projects;
    address[] public projectAddresses;
    uint256 public projectCount;
    IProjectVotingManager private ProjectVotingManager;
    ITokenManager private tokenManager;

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

    function initialize(address projectVotingManagerAddress, address tokenManagerAddress) public initializer {
        platformOwner = msg.sender;
        ProjectVotingManager = IProjectVotingManager(projectVotingManagerAddress);
        tokenManager = ITokenManager(tokenManagerAddress);
        ProjectVotingManager.setCrowdfundingManager(address(this));
        tokenManager.setCrowdfundingManager(address(this));
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
        require(bytes(descCID).length == 46, "Invalid IPFS hash");      
        require(bytes(photoCID).length == 46, "Invalid IPFS hash");      
        require(bytes(socialMediaLinkCID).length == 46, "Invalid IPFS hash");      
        require(fundingDeadline > block.timestamp, "Deadline must be in the future");
        projectCount++;

        CrowdfundingProject project = new CrowdfundingProject(
            msg.sender,
            projectCount,
            projectName,
            fundingDeadline,
            descCID,
            photoCID,
            socialMediaLinkCID
        );

        address projectAddress = address(project);
        tokenManager.deployToken(projectAddress, tokenName, tokenSymbolCID);
        address voting = ProjectVotingManager.createVotingPlatfrom(projectAddress);
        
        project.setVotingPlatform(voting);
        // project.setTokenManager(address(tokenManager));
        // tokenManager.setCrowdfundingProject(projectAddress);

        projects[projectAddress] = project;
        projectAddresses.push(projectAddress);
        founderProjectMap[msg.sender].push(projectAddress);
        emit ProjectCreated(projectAddress, msg.sender,fundingDeadline, descCID, photoCID, socialMediaLinkCID, tokenName, tokenSymbolCID);
    }
    function getVotingManagerAddress() external view returns (address) {
        return address(ProjectVotingManager);
    }
    function getTokenManagerAddress() external view returns (address) {
        return address(tokenManager);
    }

    function getFounderProjects(address founder) external view returns (address[] memory) {
        return founderProjectMap[founder];
    }
    
    function getAllFundingProjects() external view returns (address[] memory) {
        // TODO: Implement a more efficient way to get all funding projects
        // Bad Implementation: requires looping through all projects to check their status
        address[] memory fundingAddresses = new address[](projectAddresses.length);
        uint256 countEligible = 0;
        for (uint256 i = 0; i < projectAddresses.length; i++) {
            address projectAddress = projectAddresses[i];
            if (projects[projectAddress].getStatus() == ICrowdfundingProject.ProjectStatus.Funding) {
                fundingAddresses[countEligible] = projectAddress;
                countEligible++;
            }
        }
        assembly { mstore(fundingAddresses, countEligible) } // Resize the array to the actual count
        return fundingAddresses;
    }
    function getAllActiveProjects() external view returns (address[] memory) {
        // TODO: Implement a more efficient way to get all active projects
        // Bad Implementation: requires looping through all projects to check their status
        address[] memory activeAddresses = new address[](projectAddresses.length);
        uint256 countEligible = 0;
        for (uint256 i = 0; i < projectAddresses.length; i++) {
            address projectAddress = projectAddresses[i];
            if (projects[projectAddress].getStatus() == ICrowdfundingProject.ProjectStatus.Active) {
                activeAddresses[countEligible] = projectAddress;
                countEligible++;
            }
        }
        assembly { mstore(activeAddresses, countEligible) } // Resize the array to the actual count
        return activeAddresses;
    
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