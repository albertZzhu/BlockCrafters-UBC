// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./CrowdfundingProject.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CrowdfundingManager is Initializable {
    address public platformOwner;
    mapping(address => CrowdfundingProject) public projects;
    uint256 public projectCount;

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
        string tokenName,
        string tokenSymbol,
        uint256 tokenSupply,
        string descCID,
        string photoCID,
        string socialMediaLinkCID
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

    function initialize() public initializer {
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
        address projectAddress = address(project);
        projects[projectAddress] = project;

        founderProjectMap[msg.sender].push(projectAddress);
        emit ProjectCreated(projectAddress, msg.sender,fundingDeadline, tokenName, tokenSymbol, tokenSupply, descCID, photoCID, socialMediaLinkCID);
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