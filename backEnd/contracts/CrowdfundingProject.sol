// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IProjectVoting, VotingStarted, Voting, VoteType, VoteResult} from "./ProjectVoting.sol";
import "./ICrowdfundingProject.sol";
import "./ICrowdfundingManager.sol";
import {ITokenManager} from "./TokenManager.sol";

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdfundingProject is ICrowdfundingProject {
    ICrowdfundingManager public ProjectManager; 
    IProjectVoting public votingPlatform;
    ITokenManager public tokenManager;
    // PriceFeed
    // PriceFeed public priceFeed;

    uint256 public projectId;
    address public founder;
    string public name;
    uint256 public fundingBalance;
    uint256 public frozenFund;
    // mapping(address => uint256) public investment;
    ProjectStatus public status;
    bool public fundingDone;
    uint256 public fundingDeadline;

    Milestone[] public milestones;
    uint256 public currentMilestone;

    string public descCID; // IPFS cid for project description
    string public photoCID; // IPFS cid for project photo
    string public socialMediaLinkCID;
    

    // all the investors' addresses in a project 
    // auto-generated getter: address[] public investors;
    address[] public investors;

    uint8 public PLATFORM_FEE_PERCENT = 1; // percentage of the platform fee (transfer to wallet of platform owner)
    uint8 public FROZEN_PERCENTAGE = 20; // percentage of fund frozen until investors acknowledge completion of milestone

    modifier onlyFunder() {
        require(tokenManager.balanceOf(address(this),msg.sender) > 0, "Only funders can perform this action");
        // require(investment[msg.sender] > 0, "Only funders can perform this action");
        _;
    }
    modifier onlyFounder() {
        require(founder == msg.sender, "Only the founder can perform this action");
        _;
    }
    modifier isFundingProject() {
        require(status == ProjectStatus.Funding, "Project is not funding");
        require(fundingDeadline > block.timestamp, "Expired project");
        _;
    }
    modifier isWorkingProject() {
        require(status == ProjectStatus.Active, "Project is not active");
        require(fundingDone, "Project funding is not done");
        _;
    }

    event MilestoneAdded(
        uint256 indexed milestoneId,
        string name,
        string descCID,
        uint fundingGoal,
        uint deadline
    );
    event InvestmentMade(
        address indexed backer,
        uint256 amount
    );
    event FundsWithdrawn(
        uint256 projectId,
        address indexed founder,
        uint256 amount,
        uint256 fee
    );
    event ProjectStatusUpdated(
        ProjectStatus status,
        bool fundingDone
    );
    event RefundIssued(
        address indexed backer,
        uint256 amount
    );
    event ProjectBalanceUpdated(
        uint balance
    );

    constructor(
        address _founder,
        uint256 _projectId,
        string memory _name,
        uint256 _fundingDeadline,
        string memory _descCID,
        string memory _photoCID,
        string memory _socialMediaLinkCID
    ) {
        founder = _founder;
        projectId = _projectId;
        fundingDeadline = _fundingDeadline;
        name = _name;
        descCID = _descCID;
        photoCID = _photoCID;
        socialMediaLinkCID = _socialMediaLinkCID;
        ProjectManager = ICrowdfundingManager(msg.sender); // set the project manager to the contract deployer
        tokenManager = ITokenManager(ProjectManager.getTokenManagerAddress()); // set the token manager address
        // votingPlatform = IProjectVoting(ProjectManager.getVotingPlatformAddress()); // set the voting platform address
        // priceFeed = new PriceFeed();
    }
    function setVotingPlatform(address platformAddress) external {
        // set the voting platform address
        require(msg.sender == address(ProjectManager), "Only the project manager can set the voting platform");
        require(address(votingPlatform) == address(0), "Voting platform already set");
        votingPlatform = IProjectVoting(platformAddress);
    }

    function addMilestone(
        string memory _name, 
        string memory _descCID,
        uint256 _fundingGoal, 
        uint256 _deadline
    ) external onlyFounder() {
        // Add a new milestone to the project
        require(_fundingGoal > 0, "Milestone goal must be positive");
        require(_deadline > block.timestamp, "Deadline must be in the future");
        if (milestones.length > 0) {
            Milestone memory prevMilestone = milestones[milestones.length-1];
        require(prevMilestone.deadline < _deadline, "Milestone deadline must be after the previous milestone");
        }
        
        Milestone memory milestone = Milestone({
            name: _name,
            descCID: _descCID,
            fundingGoal: _fundingGoal,
            deadline: _deadline,
            status: MilestoneStatus.Pending
        });
        milestones.push();
        milestones[milestones.length-1] = milestone;

        emit MilestoneAdded(milestones.length, _name, _descCID, _fundingGoal, _deadline);
    }

    function editProject(
            string memory _projectName,
            uint256 _fundingDeadline,
            string memory _descIPFSHash
            // Token info can be edited as well
        ) external {
            //PlaceHolder, investors may edit projects when project is inactive
            //TODO: Implement this function
    }

    function startFunding() external onlyFounder() {
        require(milestones.length > 0, "No milestones added");
        require(status == ProjectStatus.Inactive, "Can only start funding if project is inactive");
        status = ProjectStatus.Funding;

        emit ProjectStatusUpdated(status, fundingDone);
    }

    function endProject() external onlyFounder() {
        setProjectFailed();
    }

    function invest() external payable isFundingProject() {
        require(msg.value > 0, "investment must be > 0");     
        require(fundingBalance + msg.value <= this.getProjectFundingGoal(), "Investment exceeds funding goal"); // limit investment to not exceed the goal
        
        uint256 usdAmount = msg.value;     

        tokenManager.mintTo(msg.sender, usdAmount);

        fundingBalance += usdAmount;
        // investment[msg.sender] += usdAmount; // record total investment

        // check if this is a new investor
        // if (investment[msg.sender] == 0) {
        //     investors.push(msg.sender);
        // }
        
        // activate the project if the funding goal is reached
        if (fundingBalance >= this.getProjectFundingGoal()) {
            activateProject();
        }

        emit InvestmentMade(msg.sender, usdAmount);
    }

    function activateProject() internal isFundingProject() {
        // activate the project if the funding goal is reached
        require(fundingBalance >= this.getProjectFundingGoal(), "Goal not reached");
        
        status = ProjectStatus.Active;
        fundingDone = true;
        frozenFund = fundingBalance; // freeze the funding milestone is completed
        releaseFrozenFunding(); // release the frozen funding for milestones[0]

        emit ProjectStatusUpdated(status, fundingDone);
    }
    //Founder withdraw after success
    function refund() external {
        // TODO: Implement this function
        // 1.set project status to failed if the last milestone is not completed after the deadline.
        if(block.timestamp > milestones[milestones.length-1].deadline){
            setProjectFailed();
        }        
        require(status == ProjectStatus.Failed, "Project is not failed");
        // 2. refund the investors based on their their number of ProjectTokens.
        // 3. burn the ProjectTokens.
        uint256 toRefund = tokenManager.balanceOf(address(this), msg.sender);
        require(toRefund > 0, "No tokens to refund");
        require(address(this).balance >= toRefund, "Insufficient balance for refund");
        tokenManager.refund(msg.sender, toRefund); // burn the tokens and get the refund amount
        // 4. transfer the refund to the investor.
        fundingBalance -= toRefund; // remove the refund amount from the funding balance
        payable(msg.sender).transfer(toRefund); // transfer the refund to the investor

        emit RefundIssued(msg.sender, toRefund);
    }
    function withdraw() external onlyFounder() {
        // each withdrawal is 80% of the milestone funding goal, 
        // the remaining 20% is frozen until the project is completed.
        require(status == ProjectStatus.Active||status==ProjectStatus.Completed, "Project is not active");

        // Milestone memory m = milestones[currentMilestone];

        uint256 totalAvailable = fundingBalance-frozenFund; // 80% of the funding goal
        require(totalAvailable > 0, "No funds available for withdrawal");
        uint256 ammount = totalAvailable; // withdraw the entire available amount

        // transaction fee (1%) and founder's share (99%)
        uint256 transactionFee = (ammount * PLATFORM_FEE_PERCENT) / 100;
        uint256 founderShare = ammount - transactionFee;


        require(address(this).balance >= transactionFee, "Insufficient balance for fee");
        // minus the withdrawing frm funding balance
        fundingBalance -= ammount;

        payable(ProjectManager.getPlatformOwner()).transfer(transactionFee);
        payable(founder).transfer(founderShare);

        emit ProjectStatusUpdated(status, fundingDone);

        emit FundsWithdrawn(projectId, founder, founderShare, transactionFee);
    }


    // set the status to fail
    function setProjectFailed() private {
        require(status == ProjectStatus.Active, "Project is not active");
        status = ProjectStatus.Failed;
        emit ProjectStatusUpdated(status, fundingDone);
    }

    function getProjectFundingGoal() external view returns(uint256){
        uint256 goal = 0; 
        for(uint i = 0; i < milestones.length; i++){
            goal += milestones[i].fundingGoal;
        }
        return goal;
    }

    function requestExtension(uint256 milestoneID, uint256 newDeadline
    ) external isWorkingProject() onlyFounder(){
        // Founders can request a deadline extension before the deadline.
        // The voting will start after the deadline, and last for VOTE_LENGTH.
        // approved based on the voting results of the Users. (Project canceled if fails -> refund){
        Milestone memory milestone = getMilestone(milestoneID);        
        require(milestone.deadline > block.timestamp, "Milestone deadline has already passed");
        require(newDeadline > milestone.deadline, "New deadline must be after the current deadline");
        require(newDeadline > block.timestamp, "New deadline must be in the future");
        votingPlatform.startNewVoting(milestoneID, newDeadline);    
    } 

    function getMilestone(uint256 milestoneID) public view returns(Milestone memory){
        require(milestoneID < milestones.length, "Milestone does not exist");
        return milestones[milestoneID];
    }

    function requestAdvance() external isWorkingProject() onlyFounder(){
        // Founders can request an advance before the deadline.
        // The voting will start after the deadline, and last for VOTE_LENGTH.
        // approved based on the voting results of the Users. (Project canceled if fails -> refund)
        Milestone memory milestone = getMilestone(currentMilestone);  
        require(milestone.status == MilestoneStatus.Pending, "This milestone is already failed or completed");
        votingPlatform.startNewVoting(currentMilestone, 0);     // 0 for VoteType.Advance  
        // Voting memory voting = votingPlatform.getVoting(currentMilestone, -1);
        uint256 endTime = votingPlatform.getVoting(currentMilestone, -1).endTime; // start the voting for the current milestone
        uint256 startTime = votingPlatform.getVoting(currentMilestone, -1).startTime; // start the voting for the current milestone
        emit VotingStarted(currentMilestone, VoteType.Advance, startTime, endTime);
    } 

    function extendDeadline(uint256 milestoneID) external isWorkingProject(){
        // Extend the deadline of the milestone if the voting is approved
        Milestone storage milestone = milestones[milestoneID];
        // check voting results
        Voting memory voting = votingPlatform.getVoting(milestoneID, -1);
        require(voting.voteType == VoteType.Extension, "Invalid voting type");
        require(voting.result == VoteResult.Approved, "Voting not approved");
        // extend the deadline based on the voting objectives
        milestone.deadline = voting.newDeadline;
        
    }  

    function advanceMilestone() external isWorkingProject(){
        // Advance the milestone if the voting is approved
        Milestone storage milestone = milestones[currentMilestone];
        
        // check voting results
        Voting memory voting = votingPlatform.getVoting(currentMilestone, -1);
        require(voting.voteType == VoteType.Advance, "Invalid voting type");
        require(voting.result == VoteResult.Approved, "Voting not approved");
        
        // advance the milestone based on the voting objectives
        milestone.status = MilestoneStatus.Completed;
        
        if (currentMilestone == milestones.length - 1) {
            status = ProjectStatus.Completed; // if this is the last milestone, set the project to completed
        } else {
            currentMilestone += 1; // otherwise, set the project to active
        }
           // move to withdraw(), only after success withdraw, can advance
        releaseFrozenFunding(); // release the frozen funding
    }
    function releaseFrozenFunding() private{
        // Release the frozen funding
        if(status==ProjectStatus.Completed){
            frozenFund = 0; // release the frozen funding
        } else{
           require(status == ProjectStatus.Active, "Project is not active");
        Milestone storage milestone = milestones[currentMilestone];
        frozenFund -= (milestone.fundingGoal * (100-FROZEN_PERCENTAGE)) / 100;
        }
    }

    function getBackerCredibility(address backer) external view returns(uint){
        // return the credibility score of the backer
        // TODO: Implement this function if possible
        // NOTE: Voting.threshold should be weighted by the range of the credibility score
        return 1;
    }
    function getTokenAddress() external view returns(address) {
        return tokenManager.getTokenAddress(address(this));
    }

    function getInvestment(address investor) external view returns(uint256){
        // return investment[investor];
        return tokenManager.balanceOf(address(this), investor);
    }

    function getFounder() external view returns(address) {
        return founder;
    }

    function getStatus() external view returns(ProjectStatus) {
        return status;
    }

    function getFundingBalance() external view returns(uint256) {
        return fundingBalance;
    }

    function getFrozenFunding() external view returns(uint256) {
        return frozenFund;
    }

    // function getFundingPool() external view returns(uint256) {
    //     return fundingPool;
    // }

    function getCurrentMilestone() external view returns(uint256) {
        return currentMilestone;
    }

    function getMilestoneList() external view returns(Milestone[] memory) {
        return milestones;
    }

    // function getInvestorsList() external view returns (address[] memory) {
    //     return investors;
    // }

    // function setFounder(address founderAddr) external {
    //     founder = founderAddr;
    // }

    // function setCurrentMilestone(uint256 _currMilestone) external {
    //     currentMilestone = _currMilestone;
    // }

    // function pushFounder(address investorAddr) external {
    //     investors.push(investorAddr);
    // }

}