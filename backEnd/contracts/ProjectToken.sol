// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ProjectToken is ERC20 {
    address public project;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address projectAddress
    ) ERC20(name_, symbol_) {
        project = projectAddress;
        _mint(projectAddress, initialSupply_);
    }
}