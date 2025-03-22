// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// TODO: is CFDToken following ERC20?
// search 'cfdToken' for replacement

contract CrowdfundingPlatform {
    // IERC20 public cfdToken;
    address public platformOwner; // Receive the 1% fee

    enum ProjectStatus {
        Active,
        Approved, // voting passed
        Failed, // voting failed or passed deadline
        Released, // 90% funding released to startup (1% to platform)
        Finished // when backers receive dividend first time, remaining 10% fund released to the founder (1% to platform)
    }

    // TODO: milstone release && Milestone Approval Process
    struct Project {
        address founder;
        uint256 goal;
        uint256 funded;
        uint256 frozen;
        uint256 totalInvestors;
        mapping(address => uint256) investments;
        ProjectStatus status;
        uint256 deadline;
        string descIPFSHash; // TODO: IPFS hash for project description
        uint256 dividendConfirmed; // number of investors receiving dividend
        mapping(address => bool) hasReported;
    }

    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    uint256 public constant PLATFORM_FEE_PERCENT = 1; // percentage
    uint8 public constant FIRST_RELEASE_AMT = 90; // percentage of the first partial fund releasing to startup
    uint8 public constant FINAL_RELEASE_THREHOLD = 80; // percentage of investors who received dividend for second release

    modifier onlyPositiveGoal(uint256 goal) {
        require(goal > 0, "Goal must be a positive number");
        _;
    }

    modifier onlyFutureDeadline(uint256 deadline) {
        require(deadline > block.timestamp, "Deadline must be in the future");
        _;
    }

    modifier onlyPlatformOwner() {
        require(msg.sender == platformOwner, "Not the platform owner");
        _;
    }

    modifier onlyActive(uint256 projectId) {
        Project storage p = projects[projectId];
        require(p.status == ProjectStatus.Active, "Project not active");
        _;
    }

    modifier onlyReleased(uint256 projectId) {
        Project storage p = projects[projectId];
        require(
            p.status == ProjectStatus.Released,
            "Project not released the first portion yet"
        );
        _;
    }

    modifier onlyReadyToFirstRelease(uint256 projectId) {
        Project storage p = projects[projectId];
        require(msg.sender == p.founder, "Only founder can withdraw");
        require(p.status == ProjectStatus.Approved, "Project not approved");
        require(p.funded >= p.goal, "Goal not reached");
        _;
    }

    modifier onlyInvestorNotReportedBefore(uint256 projectId) {
        Project storage p = projects[projectId];

        require(p.investments[msg.sender] > 0, "Not an investor");
        require(!p.hasReported[msg.sender], "Already reported");
        _;
    }

    modifier onlyReadyToFinalRelease(uint256 projectId) {
        Project storage p = projects[projectId];
        require(msg.sender == p.founder, "Only founder can withdraw");
        require(
            p.dividendConfirmed * 100 >=
                FINAL_RELEASE_THREHOLD * p.totalInvestors,
            "Not enough confirmation from investor"
        );
        _;
    }

    // projectID uses projectCount when a new project is proposed
    event ProjectCreated(
        uint256 indexed projectId,
        address indexed founder,
        uint256 goal,
        uint256 deadline
    );
    event InvestmentMade(
        uint256 indexed projectId,
        address indexed backer,
        uint256 amount
    );
    event ProjectStatusUpdated(uint256 indexed projectId, ProjectStatus status);
    event FundsReleased(
        uint256 indexed projectId,
        address indexed founder,
        uint256 amount,
        uint256 fee
    );
    event DividendReportMade(
        uint256 indexed projectId,
        address indexed backer,
        bool report
    );
    event RefundIssued(
        uint256 indexed projectId,
        address indexed backer,
        uint256 amount
    );
    event PlatformOwnerUpdated(
        address indexed oldOwner,
        address indexed newOwner
    );

    constructor() {
        // add `address _cfdToken` to argument
        // cfdToken = IERC20(_cfdToken);
        platformOwner = msg.sender;
    }

    // assumption (supportive) function
    function createProject(
        uint256 _goal,
        uint256 _deadline
    ) external onlyPositiveGoal(_goal) onlyFutureDeadline(_deadline) {
        projectCount++;
        Project storage p = projects[projectCount];
        p.founder = msg.sender;
        p.goal = _goal;
        p.funded = 0;
        p.status = ProjectStatus.Active;
        p.deadline = _deadline;

        emit ProjectCreated(projectCount, msg.sender, _goal, _deadline);
    }

    function invest(
        uint256 _projectId,
        uint256 _amount
    ) external payable onlyActive(_projectId) onlyPositiveGoal(_amount) {
        require(msg.value == _amount, "Send exact amount");

        Project storage p = projects[_projectId];

        require(p.deadline > block.timestamp, "Expired project");

        // transfer CFD from backer to this contract
        // cfdToken.transferFrom(msg.sender, address(this), _amount);

        if (p.investments[msg.sender] == 0) {
            p.totalInvestors += 1;
        }

        p.funded += _amount;
        p.investments[msg.sender] += _amount; // record total investment

        emit InvestmentMade(_projectId, msg.sender, _amount);
    }

    // TODO: call the voting function
    // OR voting function sets the corresponding Project struct
    function setProjectApproved(
        uint256 _projectId
    ) external onlyActive(_projectId) {
        // bool approved = votingApproved(_projectId);

        bool approved = true; // dummy simulation

        Project storage p = projects[_projectId];

        p.status = approved ? ProjectStatus.Approved : ProjectStatus.Failed;

        emit ProjectStatusUpdated(_projectId, p.status);
    }

    // set the status to fail
    function setProjectFailed(
        uint256 _projectId
    ) external onlyActive(_projectId) {
        Project storage p = projects[_projectId];

        p.status = ProjectStatus.Failed;

        emit ProjectStatusUpdated(_projectId, ProjectStatus.Failed);
    }

    // TODO: need to consider all-or-nothing
    // first 90% released after goal reached and voting approved
    function firstRelease(
        uint256 _projectId
    ) external onlyReadyToFirstRelease(_projectId) {
        Project storage p = projects[_projectId];

        // transaction fee (90% * 1%) and founder's share (90% * 99%)
        uint256 total = p.funded;
        uint256 releasing = (total * FIRST_RELEASE_AMT) / 100;
        uint256 remaining = total - releasing;

        uint256 transactionFee = (releasing * PLATFORM_FEE_PERCENT) / 100;
        uint256 founderShare = releasing - transactionFee;

        // frozen is the remaining 10%
        p.frozen = remaining;
        p.status = ProjectStatus.Released;

        emit ProjectStatusUpdated(_projectId, ProjectStatus.Released);

        // Transfer the fee to platformOwner
        if (transactionFee > 0) {
            // cfdToken.transfer(platformOwner, transactionFee);
            payable(platformOwner).transfer(transactionFee);
        }

        // Transfer the remainder to founder
        // cfdToken.transfer(p.founder, founderShare);
        payable(p.founder).transfer(founderShare);

        emit FundsReleased(_projectId, p.founder, founderShare, transactionFee);
    }

    function reportDividend(
        uint256 _projectId,
        bool _received
    )
        external
        onlyReleased(_projectId)
        onlyInvestorNotReportedBefore(_projectId)
    {
        Project storage p = projects[_projectId];

        p.hasReported[msg.sender] = true;

        if (_received) {
            p.dividendConfirmed += 1;
        }
        emit DividendReportMade(_projectId, msg.sender, _received);
    }

    // remaining 10% released (fully released) after first dividend
    function finalRelease(
        uint256 _projectId
    ) external onlyReleased(_projectId) onlyReadyToFinalRelease(_projectId) {
        Project storage p = projects[_projectId];

        // transaction fee (10% * 1%) and founder's share (10% * 99%)
        uint256 total = p.frozen; // only 10% of is remaining after firstRelease

        uint256 transactionFee = (total * PLATFORM_FEE_PERCENT) / 100;
        uint256 founderShare = total - transactionFee;

        // reset funded to the remaining 10%
        p.frozen = 0;
        p.status = ProjectStatus.Finished;

        emit ProjectStatusUpdated(_projectId, ProjectStatus.Finished);

        // Transfer the fee to platformOwner
        if (transactionFee > 0) {
            // cfdToken.transfer(platformOwner, transactionFee);
            payable(platformOwner).transfer(transactionFee);
        }

        // Transfer the remainder to founder
        // cfdToken.transfer(p.founder, founderShare);
        payable(p.founder).transfer(founderShare);

        emit FundsReleased(_projectId, p.founder, founderShare, transactionFee);
    }

    // Backer refund if project fails or not approved
    function refund(uint256 _projectId) external {
        Project storage p = projects[_projectId];
        require(p.status == ProjectStatus.Failed, "Project not failed");

        uint256 invested = p.investments[msg.sender];
        require(invested > 0, "No investment to refund");

        // 100% refund
        // reset the investment
        p.investments[msg.sender] = 0;

        // update project funded
        // avoid underflow
        if (p.funded >= invested) {
            p.funded -= invested;
        } else {
            p.funded = 0;
        }

        // transfer tokens back to the backer
        // cfdToken.transfer(msg.sender, invested);
        payable(msg.sender).transfer(invested);

        emit RefundIssued(_projectId, msg.sender, invested);
    }

    // change platformOwner to a new address, ONLY the current owner can change
    function updatePlatformOwner(address newOwner) external onlyPlatformOwner {
        address prevOwner = platformOwner;
        require(newOwner != address(0), "Invalid address");
        platformOwner = newOwner;
        emit PlatformOwnerUpdated(prevOwner, newOwner);
    }

    function getInvestments(
        uint256 _projectId,
        address _investor
    ) public view returns (uint256) {
        return projects[_projectId].investments[_investor];
    }

    function getReported(
        uint256 projectId,
        address investor
    ) public view returns (bool) {
        return projects[projectId].hasReported[investor];
    }
}
