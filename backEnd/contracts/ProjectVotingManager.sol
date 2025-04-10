// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import './ProjectVoting.sol';
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

event ProjectVotingCreated(address indexed projectAddress, address indexed votingPlatformAddress);
interface IProjectVotingManager {
    function createVotingPlatfrom(address _projectAddress) external returns(address);
    function setCrowdfundingManager(address _crowdFundingManager) external;
    // function computeProjectVotingAddress(address _projectAddress) external view returns (address);
}
contract ProjectVotingManager is IProjectVotingManager, Initializable {
    mapping(address project => address) public VotingPlatforms;
    address CrowdFundingManagerAddress;

    modifier onlyCrowdFundingManager() {
        require(msg.sender == CrowdFundingManagerAddress, "Only CrowdFundingManager can call this function");
        _;
    }
    function setCrowdfundingManager(address _crowdFundingManager) external {
        require(CrowdFundingManagerAddress == address(0), "CrowdFundingManager already set");
        CrowdFundingManagerAddress = _crowdFundingManager;
    }


    function createVotingPlatfrom(
        address _projectAddress
    ) external onlyCrowdFundingManager returns (address) {

        ProjectVoting votingPlatform = new ProjectVoting(_projectAddress);
        VotingPlatforms[_projectAddress] = address(votingPlatform);
        emit ProjectVotingCreated(
            _projectAddress,
            VotingPlatforms[_projectAddress]
        );
        return VotingPlatforms[_projectAddress];
    }


}