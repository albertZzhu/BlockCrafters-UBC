// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ProjectVoting.sol";
// import "./IProjectVoting.sol";

// TODO: is CFDToken following ERC20?
// search 'cfdToken' for replacement
contract CrowdfundingPlatform {
    // IERC20 public cfdToken;
    address public platformOwner; // Receive the 1% fee
    ProjectVoting public votingPlatform = new ProjectVoting(address(this));
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
        string descIPFSHash; // IPFS hash for project description
        Milestone[] milestones;
        uint CurrentMilestone;
    }

    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    uint256 public constant PLATFORM_FEE_PERCENT = 1; // percentage
    
    modifier onlyPlatformOwner() {
        require(msg.sender == platformOwner, "Not the platform owner");
        _;
    }
    modifier onlyFounder(uint256 projectID) {
        require(projectID <= projectCount, "Project does not exist");
        require(projects[projectID].founder == msg.sender, "Only the founder can perform this action");
        _;
    }
    modifier isFundingProject(uint256 projectID){
        Project storage p = projects[projectID];
        require(p.status == ProjectStatus.Funding, "Project is not funding");
        require(p.fundingDeadline > block.timestamp, "Expired project");
        _;
    }
    modifier isWorkingProject(uint256 projectID){
        Project storage p = projects[projectID];
        require(p.status == ProjectStatus.Active, "Project is not active");
        require(p.fundingDone, "Project funding is not done");
        _;
    }

    // projectID uses projectCount when a new project is proposed
    event ProjectCreated(
        uint256 indexed projectId,
        address indexed founder,
        uint256 fundingDeadline,
        string descIPFSHash
        // uint256 goal
    );
    event MilestoneAdded(
        uint256 indexed projectId,
        uint256 indexed milestoneId,
        string name,
        string description,
        uint fundingGoal,
        uint deadline
    );
    event InvestmentMade(
        uint256 indexed projectId,
        address indexed backer,
        uint256 amount
    );
    event ProjectStatusUpdated(uint256 indexed projectId, ProjectStatus status, bool fundingDone);
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
    function createProject(
            string memory projectName,
            uint256 fundingDeadline,
            string memory descIPFSHash
        ) external {
        // Create a new project, the Project starts without a milestone.
        require(bytes(projectName).length > 0 && bytes(projectName).length <= 100, "Project name length must be between 1 and 100 characters");
        require(bytes(descIPFSHash).length == 32, "Invalid IPFS hash");
        require(fundingDeadline > block.timestamp, "Deadline must be in the future");
        projectCount++;
        Project storage p = projects[projectCount];
        p.founder = msg.sender;
        p.name = projectName;
        // p.goal //this value would be set by the sum of the milestone goals
        // p.funded = 0;
        // p.fundingBalance = 0;
        // p.status = ProjectStatus.Inactive; // this is the default value
        // p.fundingDone = FundingStatus.Funding; // this is the default value
        p.fundingDeadline = fundingDeadline;
        p.descIPFSHash = descIPFSHash;       

        emit ProjectCreated(projectCount, msg.sender, p.fundingDeadline, descIPFSHash);
    }
    
    function addMilestone(
        uint256 projectID, 
        string memory name, 
        string memory description, 
        uint256 fundingGoal, 
        uint256 deadline
    ) external onlyFounder(projectID) {
        // Add a new milestone to the project
        require(fundingGoal > 0, "Milestone goal must be positive");
        require(deadline > block.timestamp, "Deadline must be in the future");
        require(projectID <= projectCount, "Project does not exist");

        Project storage project = projects[projectID];

        require(deadline > block.timestamp, "Deadline must be in the future");
        Milestone memory milestone = Milestone({
            name: name,
            description: description,
            fundingGoal: fundingGoal,
            deadline: deadline,
            status: MilestoneStatus.Pending
        });
        project.milestones.push();
        project.milestones[project.milestones.length-1] = milestone;
        // project.goal += fundingGoal;
        emit MilestoneAdded(projectID, project.milestones.length, name, description, fundingGoal, deadline);
    }

    function editProject(
            uint256 projectID,
            string memory projectName,
            uint256 fundingDeadline,
            string memory descIPFSHash
        ) external {
            //PlaceHolder, founders may edit projects when project is inactive
            //TODO: Implement this function
    }

    function editMilestone(
            uint256 projectID,
            uint256 milestoneID,
            string memory name,
            string memory description,
            uint256 fundingGoal,
            uint256 deadline
        ) external {
            //PlaceHolder, founders may edit milestones when project is inactive
            //TODO: Implement this function            
    }

    function startFunding(uint256 projectID) external onlyFounder(projectID) {
        Project storage p = projects[projectID];
        require(p.milestones.length > 0, "No milestones added");
        // requrie(p.goal > 0, "Goal must be a positive number");
        require(p.status == ProjectStatus.Inactive, "Can only start funding if project is inactive");
        p.status = ProjectStatus.Funding;
        emit ProjectStatusUpdated(projectID, p.status, p.fundingDone);
    }

    function endProject(uint256 projectID) external onlyFounder(projectID) {
        Project storage p = projects[projectID];
        require(p.status == ProjectStatus.Active, "Project is not active");
        p.status = ProjectStatus.Failed;
    }
    
    function invest(uint256 _projectId, uint256 _amount) external payable isFundingProject(_projectId) {
        require(msg.value == _amount, "Send exact amount");
        Project storage p = projects[_projectId];
        require(_amount > 0, "investment must be > 0");     
        require(p.fundingBalance + _amount <= getProjectFundingGoal(_projectId), "Investment exceeds funding goal"); // limit investment to not exceed the goal

        // transfer CFD from backer to this contract
        // cfdToken.transferFrom(msg.sender, address(this), _amount);

        p.fundingBalance += _amount;
        p.investment[msg.sender] += _amount; // record total investment
        
        // activate the project if the funding goal is reached
        if (p.fundingBalance >= getProjectFundingGoal(_projectId)) {
            activateProject(_projectId);
        }
        emit InvestmentMade(_projectId, msg.sender, _amount);
    }

    function activateProject(uint256 projectID) internal isFundingProject(projectID) {
        // activate the project if the funding goal is reached
        Project storage p = projects[projectID];
        require(p.fundingBalance >= getProjectFundingGoal(projectID), "Goal not reached");
        p.status = ProjectStatus.Active;
        p.fundingDone = true;
        emit ProjectStatusUpdated(projectID, p.status, p.fundingDone);
    }

    // // TODO: call the voting function
    // // OR voting function sets the corresponding Project struct
    // function setProjectApproved(uint256 projectId) external {
    //     // bool approved = votingApproved(_projectId);

    //     bool approved = true; // dummy simulation

    //     Project storage p = projects[projectId];
    //     require(p.status == ProjectStatus.Active, "Project is not active");

    //     p.status = approved ? ProjectStatus.Approved : ProjectStatus.Failed;

    //     emit ProjectStatusUpdated(projectId, p.status);
    // }

    // set the status to fail
    function setProjectFailed(uint256 projectId) external {
        Project storage p = projects[projectId];
        require(p.status == ProjectStatus.Active, "Project is not active");

        p.status = ProjectStatus.Failed;

        emit ProjectStatusUpdated(projectId, p.status, p.fundingDone);
    }

    //Founder withdraw after success
    function withdraw(uint256 _projectId) external {
        Project storage p = projects[_projectId];
        require(msg.sender == p.founder, "Only founder can withdraw");
        require(p.status==ProjectStatus.Active, "Project is not active");
        // require(p.fundingBalance >= p.goal, "Goal not reached");
        // require(p.status == ProjectStatus.Approved, "Project not approved");

        // transaction fee (1%) and founder's share (99%)
        uint256 total = p.fundingBalance;
        uint256 transactionFee = (total * PLATFORM_FEE_PERCENT) / 100;
        uint256 founderShare = total - transactionFee;

        // reset funded to 0
        p.fundingBalance = 0;
        p.status = ProjectStatus.Finished;

        emit ProjectStatusUpdated(_projectId, ProjectStatus.Finished, p.fundingDone);

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
        if (p.fundingBalance >= invested) {
            p.fundingBalance -= invested;
        } else {
            p.fundingBalance = 0;
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

    function requestExtension(uint256 projectID, uint256 milestoneID, uint256 newDeadline
    ) external isWorkingProject(projectID) onlyFounder(projectID){
        // Founders can request a deadline extension before the deadline.
        // The voting will start after the deadline, and last for VOTE_LENGTH.
        // approved based on the voting results of the Users. (Project canceled if fails -> refund){
        Milestone memory milestone = getMilestone(projectID, milestoneID);        
        require(milestone.deadline > block.timestamp, "Milestone deadline has already passed");
        require(newDeadline > milestone.deadline, "New deadline must be after the current deadline");
        require(newDeadline > block.timestamp, "New deadline must be in the future");
        votingPlatform.startNewVoting(projectID, milestoneID, newDeadline);    
    }    
    function requestAdvance(uint256 projectID) external onlyFounder(projectID){
        // Founders can request an advance before the deadline.
        // The voting will start after the deadline, and last for VOTE_LENGTH.
        // approved based on the voting results of the Users. (Project canceled if fails -> refund)
        //TODO: Implement this function    
    }    
    function extendDeadline(uint256 projectID, uint256 milestoneID) external isWorkingProject(projectID){
        // Extend the deadline of the milestone if the voting is approved
        Project storage project = projects[projectID];
        Milestone storage milestone = project.milestones[milestoneID];
        // check voting results
        ProjectVoting.Voting memory voting = votingPlatform.getVoting(projectID, milestoneID,-1);
        require(voting.voteType == ProjectVoting.VoteType.Extension, "Invalid voting type");
        require(voting.result == ProjectVoting.VoteResult.Approved, "Voting not approved");
        // extend the deadline based on the voting objectives
        milestone.deadline = voting.newDeadline;
    }
    function advanceMilestone(uint256 projectID) external isWorkingProject(projectID){
        // Advance the milestone if the voting is approved
        Project storage project = projects[projectID];
        Milestone storage milestone = project.milestones[project.CurrentMilestone];
        // check voting results
        ProjectVoting.Voting memory voting = votingPlatform.getVoting(projectID, project.CurrentMilestone,-1);
        require(voting.voteType == ProjectVoting.VoteType.Advance, "Invalid voting type");
        require(voting.result == ProjectVoting.VoteResult.Approved, "Voting not approved");
        // advance the milestone based on the voting objectives
        milestone.status = MilestoneStatus.Completed;
        project.CurrentMilestone += 1;
    }
    function getBackerCredibility(address backer) external view returns(uint){
        // return the credibility score of the backer
        // TODO: Implement this function if possible
        // NOTE: ProjectVoting.Voting.threshold should be weighted by the range of the credibility score
        return 1;
    }
    function getInvestment(uint256 projectID, address backer) external view returns(uint256){
        return projects[projectID].investment[backer];
    }
    function getProjectFundingGoal(uint256 projectID) public view returns(uint256){
        Project storage project = projects[projectID];
        require(projectID <= projectCount, "Project does not exist");
        uint256 goal = 0; 
        for(uint i = 0; i < project.milestones.length; i++){
            goal += project.milestones[i].fundingGoal;
        }
        return goal;
    }
    function getMilestone(uint256 projectID, uint256 milestoneID) public view returns(Milestone memory){
        require(projectID <= projectCount, "Project does not exist");
        Project storage project = projects[projectID];
        require(milestoneID < project.milestones.length, "Milestone does not exist");
        return project.milestones[milestoneID];
    }
}
