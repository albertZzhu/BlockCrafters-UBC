// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ICrowdfundingProject{
    enum ProjectStatus {
        Inactive,    // Project created but not started (editing available)
        Funding,     // Project is open for funding, no more modifications can be done.
        Active,      // Funding done,no more fundings can be done(fundingBalance==getProjectFundingGoal()), 
                     // project is active (founder can withdraw)
        Failed,     // voting failed or passed deadline
        Completed    // all milestones completed (all fund released), project END
    }
    enum MilestoneStatus{ //not currently used, may be redundant
        Pending,  // milestone not started or working in progress
        Failed,   // milestone failed (deadline passed/Extension failed)
        Completed // milestone advance request approved
    }
    struct Milestone {
        string name;
        string descCID;
        uint256 fundingGoal;
        uint256 deadline;
        MilestoneStatus status; //not currently used, may be redundant
    }

    function addMilestone(
        string memory _name, 
        string memory _descCID,
        uint256 _fundingGoal, 
        uint256 _deadline
    ) external;

    function editProject(
            string memory projectName,
            uint256 fundingDeadline,
            string memory descIPFSHash
            // Token info can be edited as well
        ) external;

    function startFunding() external;

    function endProject() external;

    function invest() external payable;

    // function activateProject() internal;

    function withdraw() external;

    function getProjectFundingGoal() external view returns(uint256);

    function requestExtension(uint256 milestoneID, uint256 newDeadline) external;

    function getMilestone(uint256 milestoneID) external view returns(Milestone memory);

    function requestAdvance() external;

    function extendDeadline(uint256 milestoneID) external;

    function advanceMilestone() external;

    function getBackerCredibility(address backer) external view returns(uint);

    function getInvestment(address investor) external view returns(uint256);

    function getFounder() external view returns(address);

    function getStatus() external view returns(ProjectStatus);

    function getFundingBalance() external view returns(uint256);

    function getFrozenFunding() external view returns(uint256);

    function getCurrentMilestone() external view returns(uint256);

    function getMilestoneList() external view returns(Milestone[] memory);

    // function setFounder(address founderAddr) external;

    // function setFundingBalance(uint256 balance) external;

    // function setFrozenFunding(uint256 _frozenFund) external;

    // function setFundingPool(uint256 _fund) external;

    // function setCurrentMilestone(uint256 _currMilestone) external;

    // function pushFounder(address investorAddr) external;

    // function completeOneMilestone() external;
}