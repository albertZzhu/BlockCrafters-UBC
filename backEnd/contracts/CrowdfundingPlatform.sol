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
        Finished // fund released to the founder
    }

    struct Project {
        address founder;
        uint256 goal;
        uint256 funded;
        mapping(address => uint256) investment;
        ProjectStatus status;
        uint256 deadline;
        string descIPFSHash; // IPFS hash for project description
    }

    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    uint256 public constant PLATFORM_FEE_PERCENT = 1; // percentage

    modifier onlyPlatformOwner() {
        require(msg.sender == platformOwner, "Not the platform owner");
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
    event FundsWithdrawn(
        uint256 indexed projectId,
        address indexed founder,
        uint256 amount,
        uint256 fee
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
    function createProject(uint256 _goal, uint256 _deadline) external {
        require(_goal > 0, "Goal must be a positive number");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        projectCount++;
        Project storage p = projects[projectCount];
        p.founder = msg.sender;
        p.goal = _goal;
        p.funded = 0;
        p.status = ProjectStatus.Active;
        p.deadline = _deadline;

        emit ProjectCreated(projectCount, msg.sender, _goal, _deadline);
    }

    function invest(uint256 _projectId, uint256 _amount) external payable {
        require(msg.value == _amount, "Send exact amount");

        Project storage p = projects[_projectId];
        require(p.status == ProjectStatus.Active, "Project is not active");
        require(_amount > 0, "investment must be > 0");
        require(p.deadline > block.timestamp, "Expired project");

        // transfer CFD from backer to this contract
        // cfdToken.transferFrom(msg.sender, address(this), _amount);

        p.funded += _amount;
        p.investment[msg.sender] += _amount; // record total investment

        emit InvestmentMade(_projectId, msg.sender, _amount);
    }

    // TODO: call the voting function
    // OR voting function sets the corresponding Project struct
    function setProjectApproved(uint256 projectId) external {
        // bool approved = votingApproved(_projectId);

        bool approved = true; // dummy simulation

        Project storage p = projects[projectId];
        require(p.status == ProjectStatus.Active, "Project not active");

        p.status = approved ? ProjectStatus.Approved : ProjectStatus.Failed;

        emit ProjectStatusUpdated(projectId, p.status);
    }

    // set the status to fail
    function setProjectFailed(uint256 projectId) external {
        Project storage p = projects[projectId];
        require(p.status == ProjectStatus.Active, "Project not active");

        p.status = ProjectStatus.Failed;

        emit ProjectStatusUpdated(projectId, ProjectStatus.Failed);
    }

    //Founder withdraw after success
    function withdraw(uint256 _projectId) external {
        Project storage p = projects[_projectId];
        require(msg.sender == p.founder, "Only founder can withdraw");
        require(p.funded >= p.goal, "Goal not reached");
        require(p.status == ProjectStatus.Approved, "Project not approved");

        // transaction fee (1%) and founder's share (99%)
        uint256 total = p.funded;
        uint256 transactionFee = (total * PLATFORM_FEE_PERCENT) / 100;
        uint256 founderShare = total - transactionFee;

        // reset funded to 0
        p.funded = 0;
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

        emit FundsWithdrawn(
            _projectId,
            p.founder,
            founderShare,
            transactionFee
        );
    }

    // Backer refund if project fails or not approved
    function refund(uint256 _projectId) external {
        Project storage p = projects[_projectId];
        require(p.status == ProjectStatus.Failed, "Project not failed");

        uint256 invested = p.investment[msg.sender];
        require(invested > 0, "No investment to refund");

        // 100% refund
        // reset the investment
        p.investment[msg.sender] = 0;

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
}
