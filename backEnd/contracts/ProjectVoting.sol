pragma solidity ^0.8.28;

import "hardhat/console.sol";
// import "./ProjectPlatform.sol";
import "./ICrowdfundingProject.sol";
contract ProjectVoting {
    uint VOTE_LENGTH = 604800; // 1 week in seconds (7*24*60*60)
    ICrowdfundingProject Project;
    
    enum VoteType{
        Extension,
        Advance
    }
    enum VoteResult{
        Pending,
        Approved,
        Rejected 
    }
    event VotingValidated(uint256 milestoneID, VoteResult result);
    struct Vote{
        VoteResult decision;
        uint256 votePower;
    }
    struct Voting{
        VoteResult result;
        VoteType voteType;
        uint256 threshold;
        uint256 positives;
        uint256 negatives;        
        uint256 startTime;
        uint256 endTime;
        uint256 newDeadline;
    }
    constructor(address _ProjectAddress){
        Project = ICrowdfundingProject(_ProjectAddress);
    }

    mapping(uint256 milestoneID => Voting[]) votings;
    mapping(bytes32 hashVoterProjectMilestone => Vote) votes;
    function startNewVoting(uint256 milestoneID, uint256 newDeadline) external {
        /**
        * @dev Users can vote for project advance base on credibility score        
        **/ 
        // this function can only called by Project contract
        require(msg.sender == address(Project), "Only the Project contract can start a vote");
        
        Voting[] storage projectVotings = votings[milestoneID];
        if(projectVotings.length > 0){            
            Voting storage lastVoting = projectVotings[projectVotings.length-1];
            require(block.timestamp > lastVoting.endTime, "Voting has not ended yet");
        }
        // Create new voting 
        projectVotings.push(); 
        Voting storage voting = projectVotings[projectVotings.length-1];
        voting.newDeadline = newDeadline;
        voting.voteType = newDeadline > 0 ? VoteType.Extension : VoteType.Advance;
        voting.startTime = block.timestamp;
        voting.endTime = block.timestamp+VOTE_LENGTH;
        voting.threshold = Project.getProjectFundingGoal()/2;
    }
    function getVoting(uint256 milestoneID, int votingID) external view returns(Voting memory){
        Voting[] storage _votings = votings[milestoneID];
        require(_votings.length > 0, "No voting has started yet");
        votingID = votingID<0?votingID%int(_votings.length):votingID;
        require(0 <= votingID && votingID < int(_votings.length), "Voting does not exist");
        Voting storage voting = _votings[uint256(votingID)];
        return voting;
    }
    function validateVotingResult(uint256 milestoneID, int votingID ) external {
        // check if the voting can be ended already
        // anyone can call this function (but will have to pay gas if vote is validated)
        Voting[] storage _votings = votings[milestoneID];
        require(_votings.length > 0, "No voting has started yet");
        votingID = votingID<0?votingID%int(_votings.length):votingID;
        require(0 <= votingID && votingID < int(_votings.length), "Voting does not exist");
        Voting storage voting = _votings[uint256(votingID)];
        if (voting.positives > voting.threshold){
            voting.result = VoteResult.Approved;
            if(voting.voteType == VoteType.Extension){
                Project.extendDeadline(milestoneID);
                // console.log('ExtensionApproved');
            }else if(voting.voteType == VoteType.Advance){
                Project.advanceMilestone();
                // console.log('AdvanceApproved');
            }
        }else if (voting.negatives >= voting.threshold){
            voting.result = VoteResult.Rejected;
            // console.log('Rejected');
        }
        emit VotingValidated(milestoneID, voting.result);
    }
    function getVotingResult(uint256 milestoneID, int votingID) external view returns(VoteResult){
        Voting memory voting = this.getVoting(milestoneID, votingID);
        // Relative Plurality
        // if vote expired 
        if(block.timestamp > voting.endTime){
            return voting.positives > voting.negatives ? VoteResult.Approved : VoteResult.Rejected;
        }
        if (voting.positives > voting.threshold){
            return VoteResult.Approved;
        }else if (voting.negatives > voting.threshold){
            return VoteResult.Rejected;
        }
        return VoteResult.Pending;
    }
    function vote(uint256 milestoneID, bool decision) external {
        Voting[] storage _votings = votings[milestoneID];
        require(_votings.length > 0, "No voting has started yet");
        Voting storage voting = _votings[_votings.length-1];
        bytes32 voteKey = keccak256(abi.encodePacked(msg.sender, milestoneID));
        
        require(block.timestamp < voting.endTime, "Voting has ended");
        require(votes[voteKey].decision == VoteResult.Pending, "Already voted");
        uint256 votePower = Project.getInvestment(msg.sender)*Project.getBackerCredibility(msg.sender);
        require(votePower > 0, "You have no voting power");
        votes[voteKey].votePower = votePower;
        votes[voteKey].decision = decision ? VoteResult.Approved : VoteResult.Rejected;
        if(decision){
            voting.positives += votePower;
        }else{
            voting.negatives += votePower;
        }
        
        this.validateVotingResult(milestoneID, -1);
    }

    function viewCurrentVoting(uint256 projectID) public view returns(uint, uint, uint){
        //TODO: "Implement this function"
    }

    // function viewVoting(uint256 milestoneID, int votingID) public view returns(uint, uint, uint){
    //     Voting storage voting =  this.getVoting(milestoneID, votingID);
    //     return (voting.positives, voting.negatives, voting.threshold, voting.startTime, voting.endTime);
    // }
}
