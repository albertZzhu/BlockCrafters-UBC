// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ProjectToken.sol";
import {IAddressProvider} from "./AddressStorage.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
interface ITokenManager {
    // function setCrowdfundingManager(address _crowdFundingManager) external;
    function deployToken(address projectAddress, string memory name, string memory symbol) external returns (address deployedTokenAddress);
    function mintTo(address investor, uint256 amount) external;
    function balanceOf(address project, address investor) external view returns (uint256);
    function refund(address investor, uint256 amount) external;
    function computeTokenAddress(address projectAddress, string memory name, string memory symbol) external view returns (address);
    function getPastVotes(address project, address account, uint256 blockNumber) external view returns (uint256);
    function getTokenAddress(address project) external view returns (address);
}
contract TokenManager is ITokenManager, Initializable{
    mapping(address=>address) public tokenAddresses;
    // address CrowdFundingManagerAddress;
    IAddressProvider private addressProvider;
    // address public crowdfundingProject;
    // address public tokenAddresses[msg.sender];
    address public owner;

    event TokenDeployed(address indexed token);
    event TokensMinted(address indexed to, uint256 amount);
    function initialize(address _addressProvider) external initializer {
        addressProvider = IAddressProvider(_addressProvider);
    }
    modifier onlyCrowdFundingManager() {
        address crowdFundingManagerAddress = addressProvider.getCrowdfundingManager();
        require(msg.sender == crowdFundingManagerAddress, "Only CrowdFundingManager can call this function");
        _;
    }
    modifier onlyAuthorized() {
        // require(msg.sender == crowdfundingProject || msg.sender == owner, "Not authorized");
        require(tokenAddresses[msg.sender]!=address(0), "Not authorized");
        _;
    }
    modifier tokenDeployed(address projectAddress) {
        require(tokenAddresses[projectAddress] != address(0), "Token not deployed");
        _;
    }
    // function setCrowdfundingManager(address _crowdFundingManager) external {
    //     require(CrowdFundingManagerAddress == address(0), "CrowdFundingManager already set");
    //     CrowdFundingManagerAddress = _crowdFundingManager;
    // }  

    /// Deploy the token for this project using CREATE2
    function deployToken(address projectAddress, string memory name, string memory symbol) external onlyCrowdFundingManager returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(projectAddress, address(this)));
        bytes memory bytecode = abi.encodePacked(
            type(ProjectToken).creationCode,
            abi.encode(name, symbol, address(this))
        );
        address tokenAddress;
        assembly {
            tokenAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(tokenAddress)) {
                revert(0, 0)
            }
        }
        tokenAddresses[projectAddress] = tokenAddress;
        emit TokenDeployed(tokenAddress);
        return tokenAddress;
    }

    /// Mint tokens to investor, called only by the CrowdfundingProject
    function mintTo(address investor, uint256 amount) external onlyAuthorized{
        ProjectToken(tokenAddresses[msg.sender]).mint(investor, amount);
        emit TokensMinted(investor, amount);
    }

    function balanceOf(address project, address investor) external tokenDeployed(project) view returns (uint256){
        return ProjectToken(tokenAddresses[project]).balanceOf(investor);
    }

    function refund(address investor, uint256 amount) external onlyAuthorized{
        // require(tokenAddresses[msg.sender] != address(0), "Token not deployed");
        ProjectToken(tokenAddresses[msg.sender])._refund(investor, amount);
        // call CrowdfundingProject to refund the investor
    }

    /// View future token address before it's deployed
    function computeTokenAddress(address projectAddress, string memory name, string memory symbol) public view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(projectAddress, address(this)));
        bytes memory bytecode = abi.encodePacked(
            type(ProjectToken).creationCode,
            abi.encode(name, symbol, address(this))
        );

        bytes32 bytecodeHash = keccak256(bytecode);

        return address(uint160(uint256(keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash)
        ))));
    }

    // function setCrowdfundingProject(address _crowdfundingProject) external onlyAuthorized {
    //     require(_crowdfundingProject != address(0), "Invalid address");
    //     crowdfundingProject = _crowdfundingProject;
    // }
    function getTokenAddress(address project) external view returns (address) {
        return tokenAddresses[project];
    }
    function getPastVotes(address project, address account, uint256 blockNumber) external view tokenDeployed(project) returns (uint256) {
        return ProjectToken(tokenAddresses[project]).getPastVotes(account, blockNumber);
    }
}