// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BackerRegister {
    
    struct Backer {
        address walletAddress;
        bytes32 emailHash;
        bool isRegistered;
    }

    // map wallet address to a corresponding backer
    mapping(address => Backer) public backers;

    event BackerRegistered(address indexed backer, bytes32 emailHash);

    function registerInvestor(string memory email) public {
        require(!backers[msg.sender].isRegistered, "Investor already registered");

        bytes32 emailHash = keccak256(abi.encodePacked(email));

        backers[msg.sender] = Backer({
            walletAddress: msg.sender,
            emailHash: emailHash,
            isRegistered: true
        });

        emit BackerRegistered(msg.sender, emailHash);
    }

    function isBackerRegistered(address walletAddress) public view returns (bool) {
        return backers[walletAddress].isRegistered;
    }

    function getInvestorEmailHash(address walletAddress) public view returns (bytes32) {
        require(backers[walletAddress].isRegistered, "Investor not registered");
        return backers[walletAddress].emailHash;
    }
}