// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UserRegister {
    
    struct User {
        address walletAddress;
        bool isRegistered;
    }

    // map wallet address to a corresponding users
    mapping(address => User) public users;

    modifier onlyRegsiterOnce() {
        require(!users[msg.sender].isRegistered, "Already registered");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].isRegistered, "User not registered");
        _;
    }

    event UserRegistered(address indexed users);

    function registerUser() public onlyRegsiterOnce() {

        users[msg.sender] = User({
            isRegistered: true,
            walletAddress: msg.sender
        });

        emit UserRegistered(msg.sender);
    }
}