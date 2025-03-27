// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ProjectToken.sol";
import "./ProjectVoting.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdfundingProject {
    // Token
    address public projectToken;
    string public tokenName;
    string public tokenSymbol;
    uint256 public tokenSupply;
    bytes32 public salt;

    uint256 public projectId;
    address public founder;
    string public name;
    // uint256 goal; call getProjectFundingGoal instead
    uint256 public funded;
    uint256 public fundingBalance;
    mapping(address => uint256) public investment;
    ProjectStatus public status;
    bool public fundingDone;
    uint256 public fundingDeadline;
    string public descIPFSHash; // IPFS hash for project description
    Milestone[] public milestones;
    uint256 public currentMilestone;
    string descCID; // IPFS cid for project description
    string photoCID; // IPFS cid for project photo
    string socialMediaLinkCID;

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
        Failed,     // voting failed or passed deadline
        Finished    // all milestones completed
    }

    ProjectVoting public votingPlatform = new ProjectVoting(address(this));

    // all the investors' addresses in a project 
    address[] public investors;

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
        string description,
        uint fundingGoal,
        uint deadline
    );
    event InvestmentMade(
        address indexed backer,
        uint256 amount
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
        uint256 _projectId,
        string memory _name,
        ProjectStatus  _status,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenSupply,
        bytes32 _salt,
        string memory descCID,
        string memory photoCID,
        string memory socialMediaLinkCID
    ) {
        projectId = _projectId;
        name = _name;
        status = _status;
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        tokenSupply = _tokenSupply;
        salt = _salt;
        founder = msg.sender;
    }

    function addMilestone(
        string memory name, 
        string memory description, 
        uint256 fundingGoal, 
        uint256 deadline,
        string memory descCID
    ) external onlyFounder() {
        // Add a new milestone to the project
        require(fundingGoal > 0, "Milestone goal must be positive");
        require(deadline > block.timestamp, "Deadline must be in the future");

        Milestone memory milestone = Milestone({
            name: name,
            description: description,
            fundingGoal: fundingGoal,
            deadline: deadline,
            status: MilestoneStatus.Pending
        });
        milestones[milestones.length-1] = milestone;

        emit MilestoneAdded(milestones.length, name, description, fundingGoal, deadline);
    }

    function editProject(
            string memory projectName,
            uint256 fundingDeadline,
            string memory descIPFSHash
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
        require(status == ProjectStatus.Active, "Project is not active");
        status = ProjectStatus.Failed;
    }

    function invest(uint256 _amount) external payable isFundingProject() {
        require(msg.value == _amount, "Send exact amount");
        require(_amount > 0, "investment must be > 0");     
        require(fundingBalance + _amount <= getProjectFundingGoal(), "Investment exceeds funding goal"); // limit investment to not exceed the goal

        fundingBalance += _amount;
        investment[msg.sender] += _amount; // record total investment
        investors.push(msg.sender);
        
        // activate the project if the funding goal is reached
        if (fundingBalance >= getProjectFundingGoal()) {
            activateProject();
        }

        emit InvestmentMade(msg.sender, _amount);
    }

    function activateProject() internal isFundingProject() {
        // activate the project if the funding goal is reached
        require(fundingBalance >= getProjectFundingGoal(), "Goal not reached");
        status = ProjectStatus.Active;
        fundingDone = true;

        emit ProjectStatusUpdated(status, fundingDone);
    }

    // set the status to fail
    function setProjectFailed() external {
        require(status == ProjectStatus.Active, "Project is not active");
        status = ProjectStatus.Failed;

        emit ProjectStatusUpdated(status, fundingDone);
    }

    function setProjectStatue(ProjectStatus _status) external {
        status = _status;

        emit ProjectStatusUpdated(status, fundingDone);
    }

    function getProjectFundingGoal() public view returns(uint256){
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
        votingPlatform.startNewVoting(projectId, milestoneID, newDeadline);    
    } 

    function getMilestone(uint256 milestoneID) public view returns(Milestone memory){
        require(milestoneID < milestones.length, "Milestone does not exist");
        return milestones[milestoneID];
    }

    function requestAdvance(uint256 projectID) external onlyFounder(){
        // Founders can request an advance before the deadline.
        // The voting will start after the deadline, and last for VOTE_LENGTH.
        // approved based on the voting results of the Users. (Project canceled if fails -> refund)
        //TODO: Implement this function    
    } 

    function extendDeadline(uint256 milestoneID) external isWorkingProject(){
        // Extend the deadline of the milestone if the voting is approved
        Milestone storage milestone = milestones[milestoneID];
        // check voting results
        ProjectVoting.Voting memory voting = votingPlatform.getVoting(projectId, milestoneID, -1);
        require(voting.voteType == ProjectVoting.VoteType.Extension, "Invalid voting type");
        require(voting.result == ProjectVoting.VoteResult.Approved, "Voting not approved");
        // extend the deadline based on the voting objectives
        milestone.deadline = voting.newDeadline;
    }  

    function advanceMilestone() external isWorkingProject(){
        // Advance the milestone if the voting is approved
        Milestone storage milestone = milestones[currentMilestone];
        // check voting results
        ProjectVoting.Voting memory voting = votingPlatform.getVoting(projectId, currentMilestone, -1);
        require(voting.voteType == ProjectVoting.VoteType.Advance, "Invalid voting type");
        require(voting.result == ProjectVoting.VoteResult.Approved, "Voting not approved");
        // advance the milestone based on the voting objectives
        milestone.status = MilestoneStatus.Completed;
        currentMilestone += 1;
    }

    function getBackerCredibility(address backer) external view returns(uint){
        // return the credibility score of the backer
        // TODO: Implement this function if possible
        // NOTE: ProjectVoting.Voting.threshold should be weighted by the range of the credibility score
        return 1;
    }

    function getInvestment(address investor) external view returns(uint256){
        return investment[investor];
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

    function getCurrentMilestone() external view returns(uint256) {
        return currentMilestone;
    }

    function getMilestoneList() external view returns(Milestone[] memory) {
        return milestones;
    }

    function setFounder(address founderAddr) external {
        founder = founderAddr;
    }

    function setFundingBalance(uint256 balance) external {
        fundingBalance = balance;

        emit ProjectBalanceUpdated(balance);
    }

    function pushFounder(address investorAddr) external {
        investors.push(investorAddr);
    }

    function completeOneMilestone() external {
        currentMilestone++;
    }

    function setStatus(ProjectStatus _status) external {
        status = _status;
    }

    // function getFounderProjects(address founderAddr) external view returns (uint256[] memory) {
    //     return investors[founderAddr];
    // }


    // invoke this method when the project raise enough money
    function deployTokenIfSuccessful() external isWorkingProject() {
        require(projectToken == address(0), "Token already deployed");

        address tokenAddr = deployToken();
        projectToken = tokenAddr;
    }

    function deployToken() internal returns (address tokenAddress) {
        bytes memory bytecode = abi.encodePacked(
            type(ProjectToken).creationCode,
            abi.encode(tokenName, tokenSymbol, tokenSupply, address(this))
        );

        assembly {
            tokenAddress := create2(0, add(bytecode, 0x20), mload(bytecode), sload(salt.slot))
            if iszero(extcodesize(tokenAddress)) {
                revert(0, 0)
            }
        }
    }

    function distributeTokens() external {
        require(projectToken != address(0), "Token not deployed yet");

        for (uint i = 0; i < investors.length; i++) {
            address investor = investors[i];
            uint256 share = (investment[investor] * tokenSupply) / getProjectFundingGoal();
            IERC20(projectToken).transfer(investor, share);
        }
    }

    function computeTokenAddress() external view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(ProjectToken).creationCode,
            abi.encode(tokenName, tokenSymbol, tokenSupply, address(this))
        );
        bytes32 bytecodeHash = keccak256(bytecode);
        return address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash)
                    )
                )
            )
        );
    }

}