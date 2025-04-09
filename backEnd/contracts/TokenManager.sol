// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ProjectToken.sol";

contract TokenManager {

    address public crowdfundingProject;
    address public projectToken;

    event TokenDeployed(address indexed token);
    event TokensMinted(address indexed to, uint256 amount);

    modifier onlyCrowdfundingProject() {
        require(msg.sender == crowdfundingProject, "Not authorized");
        _;
    }

    constructor(address _crowdfundingProject) {
        require(_crowdfundingProject != address(0), "Invalid manager address");
        crowdfundingProject = _crowdfundingProject;
    }

    /// Deploy the token for this project using CREATE2
    function deployToken(string memory name, string memory symbol) external onlyCrowdfundingProject returns (address tokenAddress) {
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
    function mintTo(address investor, uint256 amount) external onlyCrowdfundingProject {
        require(projectToken != address(0), "Token not deployed");
        ProjectToken(projectToken).mint(investor, amount);
        emit TokensMinted(investor, amount);
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
}