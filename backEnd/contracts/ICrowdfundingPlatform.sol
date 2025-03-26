// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
enum MilestoneStatus{ //not currently used, may be redundant
        Pending,  // milestone not started or working in progress
        Failed,   // milestone failed (deadline passed/extention failed)
        Completed // milestone advance request approved
    }
struct Milestone {
        string name;
        string description;
        uint256 fundingGoal;
        uint256 deadline;
        MilestoneStatus status; //not currently used, may be redundant
    }

enum ProjectStatus {
        Inactive,    // Project created but not started (editing available)
        Funding,     // Project is open for funding, no more modifications can be done.
        Active,      // Funding done,no more fundings can be done(fundingBalance==getProjectFundingGoal()), 
                     // project is active (founder can withdraw)
        // Voting,
        // Approved, // voting passed
        Failed,     // voting failed or passed deadline
        Finished    // all milestones completed
    }

struct Project {
        address founder;
        string name;
        // uint256 goal; call getProjectFundingGoal instead
        uint256 funded;
        uint256 fundingBalance;
        mapping(address => uint256) investment;
        ProjectStatus status;
        bool fundingDone;
        uint256 fundingDeadline;
        string descCID; // IPFS cid for project description
        string photoCID; // IPFS cid for project photo
        string socialMediaLinkCID; // IPFS cid for project social media link
        Milestone[] milestones;
        uint CurrentMilestone;
    }
interface ICrowdfundingPlatform{
    function createProject(
        string memory projectName,
        uint256 fundingDeadline,
        string memory descCID,
        string memory photoCID,
        string memory socialMediaLinkCID
    ) external;
    function addMilestone(
        uint256 projectID, 
        string memory name, 
        string memory description, 
        uint256 fundingGoal, 
        uint256 deadline
    ) external;
    function startFunding(uint256 projectID) external;
    function invest(uint256 _projectId, uint256 _amount) external payable;
    function activateProject(uint256 projectID) external;
    function setProjectFailed(uint256 projectId) external;
    function withdraw(uint256 _projectId) external;
    function refund(uint256 _projectId) external;
    function updatePlatformOwner(address newOwner) external;
    function requestExtension(uint256 projectID, uint256 milestoneID, uint256 newDeadline) external;
    function requestAdvance(uint256 projectID) external;
    function extendDeadline(uint256 projectID, uint256 milestoneID) external;
    function advanceMilestone(uint256 projectID) external;
    function getBackerCredibility(address backer) external view returns(uint);
    function getInvestment(uint256 projectID, address backer) external view returns(uint256);
    function getProjectFundingGoal(uint256 projectID) external view returns(uint256);
    function getMilestone(uint256 projectID, uint256 milestoneID) external view returns(Milestone memory);
    function getFounderProjects(address founderAddr) external view returns (uint256[] memory);
}