// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Moneybox.sol"; // Adjust the path as necessary

contract MoneyboxTest is Test {
    Moneybox public moneybox;
    address public nonOwner;
    address public destAddr;
    address public ownerAddr;

    function setUp() public {
        ownerAddr = address(this);
        nonOwner = address(0x123);

        // now allocate ballance for the test contract
        uint256 myFunds = 10 ether;
        vm.deal(address(this), myFunds);
        console.log("Test contract: ", address(this));
        uint256 loadedBalance = address(this).balance;
        console.log("Test balance:  ", loadedBalance / 1 ether, " ETH");

        moneybox = new Moneybox();
        destAddr = address(moneybox);
        console.log("Moneybox: ", destAddr);
        console.log("Owner: ", ownerAddr);
    }

    function testInitialBalance() public view {
        uint256 balance = moneybox.ballance();
        assertEq(balance, 0, "Initial balance should be 0");
    }

    function testReceiveEther() public {
        // Send 1 ether to the contract
        uint256 sendAmount = 1 ether;
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

        // Deposit Ether into the contract        
        uint256 prevBalance = destAddr.balance;
        console.log("Previous balance: ", prevBalance / 1 ether, "ETH");
        console.log("Sending", depositAmount / 1 ether, "ETH to", destAddr);
        (bool success, ) = payable(destAddr).call{value: depositAmount, gas: 100000}("");
        require(success, "Ether transfer failed");        
        uint256 newBalance = destAddr.balance;
        console.log("New balance: ", newBalance / 1 ether, "ETH");
        assertEq(newBalance - prevBalance, depositAmount, "Deposit amount mismatch");
        console.log("My ballance: ", ownerAddr.balance / 1 ether, "ETH");

        // Withdraw Ether as the owner
        address destination = ownerAddr;
        console.log("Withdrawing", withdrawAmount / 1 ether, "ETH from TO", destination);
        // moneybox.withdraw(withdrawAmount, payable(destAddr));
        // Use `.call` to specify a custom gas limit for the withdraw function
        (success, ) = address(moneybox).call{gas: 100000}(
          abi.encodeWithSignature("withdraw(uint256,address)", withdrawAmount, payable(destination))
        );
        require(success, "Withdraw failed");
        uint256 finalBalance = destAddr.balance;
        console.log("Final balance in moneybox:", finalBalance / 1 ether, "ETH");
        assertEq(finalBalance, newBalance - withdrawAmount, "Remaining balance mismatch");
        console.log("Final balance in owner:", ownerAddr.balance / 1 ether, "ETH");
    }

    function testWithdrawExceedsBalance() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawAmount = 2 ether; // more than the deposited amount

        // Deposit Ether into the contract
        // payable(address(moneybox)).transfer(depositAmount);
        (bool success, ) = payable(destAddr).call{value: depositAmount, gas: 100000}("");
        require(success, "Ether transfer failed"); 
        assertEq(moneybox.ballance(), depositAmount, "Deposit amount mismatch");

        // Attempt to withdraw more than available balance should revert
        vm.expectRevert("Not enough money");
        moneybox.withdraw(withdrawAmount, payable(ownerAddr));
    }

    function testWithdrawAsNonOwner() public {
        uint256 depositAmount = 1 ether;

        // Deposit Ether into the contract
        //payable(address(moneybox)).transfer(depositAmount);
        (bool success, ) = payable(destAddr).call{value: depositAmount, gas: 100000}("");
        require(success, "Ether transfer failed");         
        assertEq(moneybox.ballance(), depositAmount, "Deposit amount mismatch");

        // Attempt withdrawal from non-owner account should revert
        vm.prank(nonOwner);
        vm.expectRevert("Only owner can withdraw");
        moneybox.withdraw(0.5 ether, payable(destAddr));
    }

    // Helper function to receive Ether for test contract
    receive() external payable {}
}
