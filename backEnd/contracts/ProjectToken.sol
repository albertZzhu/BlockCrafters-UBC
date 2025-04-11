// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract ProjectToken is ERC20, ERC20Permit, ERC20Votes {
    address public owner;

    constructor(
        string memory name_,
        string memory symbol_,
        address owner_
    ) 
        ERC20(name_, symbol_)
        ERC20Permit(name_)
    {
        require(owner_ != address(0), "Invalid owner");
        owner = owner_;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    function nonces(address owner_) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner_);
    }
    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
        _delegate(to, to);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }
    function _refund(address to, uint256 amount) external onlyOwner returns (uint256) {
        uint256 UserBalance = balanceOf(to);
        require(amount > 0, "Amount must be > 0");
        require(UserBalance >= amount, "Insufficient balance to refund");
        _burn(to, amount);
        return amount;
    }
}