// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract ProjectToken is ERC20 {
    address public owner;

    constructor(
        string memory name_,
        string memory symbol_,
        address owner_
    ) ERC20(name_, symbol_) {
        require(owner_ != address(0), "Invalid owner");
        owner = owner_;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }
    function _refund(address to, uint256 amount) external onlyOwner returns (uint256) {
        uint256 UserBalance = balanceOf(to);
        require(amount > 0, "Amount must be > 0");
        // burns tokens equivalent to the amount requested
        require(UserBalance >= amount, "Insufficient balance to refund");
        _burn(to, amount);
        return amount;
    }
}