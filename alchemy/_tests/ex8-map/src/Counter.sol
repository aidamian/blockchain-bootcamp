// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";

contract Counter {
    uint256 public number;

	struct User {
		uint balance;
		bool isActive;
        string name;
	}    

    mapping(address => User) public users;

    mapping(string => address) public usersMap;


	function createUser(string calldata name) public {
        console.log("Trying to create user: ", name, " with address: ", msg.sender);
		require(users[msg.sender].isActive == false, "address already exists");
		users[msg.sender] = User(100, true, name);
	}    

    function getUser(address user) public view returns (User memory) {
        return users[user];
    }

    function getAddress(string calldata name) public view returns (address) {
        address res = usersMap[name];
        return res;
    }

    function getUserdata(string calldata name) public view returns (User memory) {
        address user = usersMap[name];
        return users[user];
    }



    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
