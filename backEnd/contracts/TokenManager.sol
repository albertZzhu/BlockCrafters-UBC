// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ProjectToken.sol";

contract TokenManager {

    address public crowdfundingProject;
    address public projectToken;
    address public owner;

    event TokenDeployed(address indexed token);
    event TokensMinted(address indexed to, uint256 amount);

    modifier onlyAuthorized() {
        require(msg.sender == crowdfundingProject || msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _crowdfundingProject) {
        require(_crowdfundingProject != address(0), "Invalid manager address");
        crowdfundingProject = _crowdfundingProject;
        owner = msg.sender;
    }

    /// Deploy the token for this project using CREATE2
    function deployToken(string memory name, string memory symbol) external onlyAuthorized returns (address tokenAddress) {
        require(projectToken == address(0), "Token already deployed");

        bytes32 salt = keccak256(abi.encodePacked(address(this)));
        bytes memory bytecode = abi.encodePacked(
            type(ProjectToken).creationCode,
            abi.encode(name, symbol, address(this))
        );

        assembly {
            tokenAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(tokenAddress)) {
                revert(0, 0)
            }
        }

        projectToken = tokenAddress;
        emit TokenDeployed(tokenAddress);
        return tokenAddress;
    }

    /// Mint tokens to investor, called only by the CrowdfundingProject
    function mintTo(address investor, uint256 amount) external onlyAuthorized {
        require(projectToken != address(0), "Token not deployed");
        ProjectToken(projectToken).mint(investor, amount);
        emit TokensMinted(investor, amount);
    }

    function balanceOf(address investor) external view returns (uint256) {
        require(projectToken != address(0), "Token not deployed");
        return ProjectToken(projectToken).balanceOf(investor);
    }

    function refund(address investor, uint256 amount) external onlyAuthorized {
        // require(projectToken != address(0), "Token not deployed");
        uint256 UserBalance = this.balanceOf(owner);
        ProjectToken(projectToken)._refund(investor, amount);
        // call CrowdfundingProject to refund the investor
    }

    /// View future token address before it's deployed
    function computeTokenAddress(string memory name, string memory symbol) public view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(address(this)));
        bytes memory bytecode = abi.encodePacked(
            type(ProjectToken).creationCode,
            abi.encode(name, symbol, address(this))
        );

        bytes32 bytecodeHash = keccak256(bytecode);

        return address(uint160(uint256(keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash)
        ))));
    }

    function setCrowdfundingProject(address _crowdfundingProject) external onlyAuthorized {
        require(_crowdfundingProject != address(0), "Invalid address");
        crowdfundingProject = _crowdfundingProject;
    }
}