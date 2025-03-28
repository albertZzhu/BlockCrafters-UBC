// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ProjectVoting.sol";
// import "./IProjectVoting.sol";
import "./ICrowdfundingPlatform.sol";
import "./ProjectToken.sol";

import "./ProjectToken.sol";


contract CrowdfundingPlatform {
    // IERC20 public cfdToken;
    address public platformOwner; // Receive the 1% fee

    // Token
    address public projectToken;
    string public tokenName;
    string public tokenSymbol;
    uint256 public tokenSupply;
    bytes32 public salt;


    // Token
    address public projectToken;
    string public tokenName;
    string public tokenSymbol;
    uint256 public tokenSupply;
    bytes32 public salt;

    ProjectVoting public votingPlatform = new ProjectVoting(address(this));
    
    // -----Moved ProjectStatus and Project to ICrowdfundingPlatform.sol-----


    // all the investors' addresses in a project 
    address[] public investors;

    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    mapping(address => uint256[]) public founders;

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
        string descCID,
        string photoCID,
        string socialMediaLinkCID
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

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenSupply,
        bytes32 _salt
    ) {
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenSupply,
        bytes32 _salt
    ) {
        // add `address _cfdToken` to argument
        // cfdToken = IERC20(_cfdToken);
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        tokenSupply = _tokenSupply;
        salt = _salt;
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        tokenSupply = _tokenSupply;
        salt = _salt;
        platformOwner = msg.sender;
    }

    // assumption (supportive) function
    function createProject(
            string memory projectName,
            uint256 fundingDeadline,
            string memory descCID,
            string memory photoCID,
            string memory socialMediaLinkCID
        ) external {
        // Create a new project, the Project starts without a milestone.
        require(bytes(projectName).length > 0 && bytes(projectName).length <= 100, "Project name length must be between 1 and 100 characters");
        require(bytes(descCID).length == 32, "Invalid IPFS hash");
        require(fundingDeadline > block.timestamp, "Deadline must be in the future");
        projectCount++;
        Project storage p = projects[projectCount];
        p.founder = msg.sender;
        p.name = projectName;
        
        p.fundingDeadline = fundingDeadline;
        p.descCID = descCID;
        p.photoCID = photoCID;
        p.socialMediaLinkCID = socialMediaLinkCID;

        // founders info
        founders[msg.sender].push(projectCount);

        emit ProjectCreated(
            projectCount,
            msg.sender,
            p.fundingDeadline,
            descCID,
            photoCID,
            socialMediaLinkCID
        );        
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
            string memory descCID
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
        Project storage p = projects[_projectId];
        require(
            block.timestamp < p.fundingDeadline,
            "Milestone deadline has passed"
        );

        require(_amount > 0, "investment must be > 0");     
        require(p.fundingBalance + _amount <= getProjectFundingGoal(_projectId), "Investment exceeds funding goal"); // limit investment to not exceed the goal

        p.fundingBalance += _amount;
        p.investment[msg.sender] += _amount; // record total investment
        investors.push(msg.sender);
        investors.push(msg.sender);
        
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

    // set the status to fail
    function setProjectFailed(uint256 projectId) external {
        Project storage p = projects[projectId];
        require(p.status == ProjectStatus.Active, "Project is not active");

        p.status = ProjectStatus.Failed;

        emit ProjectStatusUpdated(projectId, p.status, p.fundingDone);
    }

    //Founder withdraw after success
    function withdraw(uint256 _projectId) external onlyFounder(_projectId){
        Project storage p = projects[_projectId];
        require(p.status == ProjectStatus.Active, "Project is not active");

        uint256 currentMilestone = p.CurrentMilestone;
        require(
            currentMilestone < p.milestones.length,
            "All milestones completed"
        );

        Milestone storage m = p.milestones[currentMilestone];
        require(
            m.fundingGoal <= p.fundingBalance,
            "Insufficient funds for this milestone"
        );

        // get voting result
        ProjectVoting.VoteResult votingResult = votingPlatform.getVotingResult(
            _projectId,
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
        p.fundingBalance -= total;
        m.status = MilestoneStatus.Completed;
        p.CurrentMilestone++;

        payable(platformOwner).transfer(transactionFee);
        payable(p.founder).transfer(founderShare);

        // update the entire project status if that's the ending milstone
        if (p.CurrentMilestone == p.milestones.length) {
            p.status = ProjectStatus.Finished;
        }

        emit ProjectStatusUpdated(_projectId, ProjectStatus.Finished, p.fundingDone);

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

    function getFounderProjects(address founderAddr) external view returns (uint256[] memory) {
        return founders[founderAddr];
    }


    // invoke this method when the project raise enough money
    function deployTokenIfSuccessful(uint256 _projectId) external isWorkingProject(_projectId) {
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

    function distributeTokens(uint256 _projectId) external {
        require(projectToken != address(0), "Token not deployed yet");

        Project storage p = projects[_projectId];

        for (uint i = 0; i < investors.length; i++) {
            address investor = investors[i];
            uint256 share = (p.investment[investor] * tokenSupply) / getProjectFundingGoal(_projectId);
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
