// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;        

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }

    function testStructs() public {
        address user1 = address(0x1234);
        address user2 = address(0x5678);
        address user3 = address(0x9abc);

        hoax(user1);
        counter.createUser("Ana");        
        Counter.User memory userData = counter.getUser(user1);
        console.log("User data: ", userData.name);
        console.log("User balance: ", userData.balance);
        console.log("User isActive: ", userData.isActive);
        console.log("-------------------");

        hoax(user2);
        counter.createUser("Bob");
        userData = counter.getUser(user2);
        console.log("User data: ", userData.name);
        console.log("User balance: ", userData.balance);
        console.log("User isActive: ", userData.isActive);
        console.log("-------------------");

        hoax(user2);
        vm.expectRevert("address already exists");
        counter.createUser("Bob Again");
        userData = counter.getUser(user2);
        console.log("User data: ", userData.name);
        console.log("User balance: ", userData.balance);
        console.log("User isActive: ", userData.isActive);
        console.log("-------------------");
       
        userData = counter.getUser(user3);
        console.log("User data: ", userData.name);
        console.log("User balance: ", userData.balance);
        console.log("User isActive: ", userData.isActive);
    }



}
