// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./CrowdfundingProject.sol";
// import "./ICrowdfundingProject.sol";
import "./ProjectVoting.sol";

contract CrowdfundingManager{
    // Constant
    uint256 public constant PLATFORM_FEE_PERCENT = 1; // percentage

    address public platformOwner;
    mapping(uint256 => CrowdfundingProject) public projects;
    uint256 public projectCount;

    mapping(address => uint256[]) public founderProjectMap;
    ProjectVoting public votingPlatform = new ProjectVoting(address(this));

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

    event FundsWithdrawn(
        uint256 projectId,
        address indexed founder,
        uint256 amount,
        uint256 fee
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
    
    function getFounderProjects(address founder) external view returns (uint256[] memory) {
        return founderProjectMap[founder];
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

    //Founder withdraw after success
    function withdraw(uint256 _projectId) external {
        CrowdfundingProject p = projects[_projectId];
        require(p.getFounder() == msg.sender, "Only founder can withdraw");
        require(p.getStatus() == ICrowdfundingProject.ProjectStatus.Active, "Project is not active");

        uint256 currentMilestone = p.getCurrentMilestone();
        CrowdfundingProject.Milestone[] memory milestones = p.getMilestoneList();
        require(
            currentMilestone < milestones.length,
            "All milestones completed"
        );

        CrowdfundingProject.Milestone memory m = milestones[currentMilestone];

        require(
            m.fundingGoal <= p.getFundingBalance(),
            "Insufficient funds for this milestone"
        );

         // get voting result
        ProjectVoting.VoteResult votingResult = votingPlatform.getVotingResult(
            currentMilestone,
            -1
        );

        require(
            votingResult == ProjectVoting.VoteResult.Approved,
            "Milestone not approved by voting"
        );

        // transaction fee (1%) and founder's share (99%)
        uint256 total = m.fundingGoal;
        uint256 transactionFee = (total * PLATFORM_FEE_PERCENT) / 100;
        uint256 founderShare = total - transactionFee;

        // minus the withdrawing fund from balance
        uint256 balance = p.getFundingBalance() - total;
        p.setFundingBalance(balance);
        // m.status = MilestoneStatus.Completed;
        // p.completeOneMilestone();

        payable(platformOwner).transfer(transactionFee);
        payable(p.getFounder()).transfer(founderShare);

        // update the entire project status if that's the ending milstone
         if (currentMilestone == milestones.length) {
             p.setProjectStatus(ICrowdfundingProject.ProjectStatus.Finished);
         }

        emit ProjectStatusUpdated(_projectId, ICrowdfundingProject.ProjectStatus.Finished);

        emit FundsWithdrawn(
            _projectId,
            p.getFounder(),
            founderShare,
            transactionFee
        );
    }

    // change platformOwner to a new address, ONLY the current owner can change
    function updatePlatformOwner(address newOwner) external {
        require(msg.sender == platformOwner, "Not the platform owner");
        address prevOwner = platformOwner;
        require(newOwner != address(0), "Invalid address");
        platformOwner = newOwner;

        emit CrowdfundingManagerUpdated(prevOwner, newOwner);
    }
    
}