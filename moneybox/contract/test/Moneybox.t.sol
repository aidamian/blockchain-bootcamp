// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Moneybox.sol"; // Adjust the path as necessary

contract MoneyboxTest is Test {
    Moneybox public moneybox;
    address public owner;
    address public nonOwner;
    address public destAddr;

    function setUp() public {
        owner = address(this);
        nonOwner = address(0x123);
        destAddr = address(0x456);

        // now allocate ballance for the test contract
        uint256 myFunds = 10 ether;
        vm.deal(address(this), myFunds);
        console.log("Test contract: ", address(this));
        uint256 loadedBalance = address(this).balance;
        console.log("Test balance:  ", loadedBalance / 1 ether, " ETH");

        moneybox = new Moneybox();
    }

    function testInitialBalance() public view {
        uint256 balance = moneybox.ballance();
        assertEq(balance, 0, "Initial balance should be 0");
    }

    function testReceiveEther() public {
        // Send 1 ether to the contract
        uint256 sendAmount = 1 ether;
        destAddr = address(moneybox);        
        console.log("Sending", sendAmount / 1 ether, "ETH to", destAddr);

        //payable(destAddr).transfer(sendAmount);

        // Use `.call` to specify a custom gas limit for the transfer
        (bool success, ) = payable(destAddr).call{value: sendAmount, gas: 100000}("");
        require(success, "Ether transfer failed");        

        uint256 balance = moneybox.ballance();
        console.log("Moneybox Balance: ", balance / 1 ether, "ETH");        
        assertEq(balance, sendAmount, "Balance should match amount sent");
    }

    function testWithdrawAsOwner() public {
        uint256 depositAmount = 2 ether;
        uint256 withdrawAmount = 1 ether;
        destAddr = address(moneybox);        

        // Deposit Ether into the contract        
        uint256 prevBalance = destAddr.balance;
        console.log("Previous balance: ", prevBalance / 1 ether, "ETH");
        console.log("Sending", depositAmount / 1 ether, "ETH to", destAddr);
        (bool success, ) = payable(destAddr).call{value: depositAmount, gas: 100000}("");
        require(success, "Ether transfer failed");        
        uint256 newBalance = destAddr.balance;
        console.log("New balance: ", newBalance / 1 ether, "ETH");
        assertEq(newBalance - prevBalance, depositAmount, "Deposit amount mismatch");

        // Withdraw Ether as the owner
        console.log("Withdrawing", withdrawAmount / 1 ether, "ETH from", destAddr);
        moneybox.withdraw(withdrawAmount, payable(destAddr));
        uint256 finalBalance = destAddr.balance;
        console.log("Final balance: ", finalBalance / 1 ether, "ETH");
        assertEq(finalBalance, newBalance - withdrawAmount, "Remaining balance mismatch");
    }

    function testWithdrawExceedsBalance() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawAmount = 2 ether; // more than the deposited amount

        // Deposit Ether into the contract
        payable(address(moneybox)).transfer(depositAmount);
        assertEq(moneybox.ballance(), depositAmount, "Deposit amount mismatch");

        // Attempt to withdraw more than available balance should revert
        vm.expectRevert("Not enough money");
        moneybox.withdraw(withdrawAmount, payable(destAddr));
    }

    function testWithdrawAsNonOwner() public {
        uint256 depositAmount = 1 ether;

        // Deposit Ether into the contract
        payable(address(moneybox)).transfer(depositAmount);
        assertEq(moneybox.ballance(), depositAmount, "Deposit amount mismatch");

        // Attempt withdrawal from non-owner account should revert
        vm.prank(nonOwner);
        vm.expectRevert("Only owner can withdraw");
        moneybox.withdraw(0.5 ether, payable(destAddr));
    }

    // Helper function to receive Ether for test contract
    receive() external payable {}
}
