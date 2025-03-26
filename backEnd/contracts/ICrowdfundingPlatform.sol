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
interface ICrowdfundingPlatform{
    function createProject(
        string memory projectName,
        uint256 fundingDeadline,
        string memory descIPFSHash
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
}