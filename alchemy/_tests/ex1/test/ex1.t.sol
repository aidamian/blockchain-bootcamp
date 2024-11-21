// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ex1.sol";

contract ContractTest is Test {
    Contract public contractInstance;
    address public owner;
    address public nonOwner;

    receive() external payable {} // we need this to receive funds from the tested contract

    function setUp() public {
        owner = address(this); // Test contract is the deployer
        nonOwner = address(0x123); // Simulated non-owner address

        // Fund the deployer with enough ETH for deployment
        vm.deal(owner, 2 ether);

        // Deploy the contract with 1 ETH
        contractInstance = new Contract{value: 1 ether}();

        // Verify that the contract was deployed with the correct balance
        assertEq(address(contractInstance).balance, 1 ether);
    }

    function testDeployment() public view {
        // Verify that the owner is correctly set
        // Note: owner is private, so you can't directly check it from the contract
        assertEq(address(this), owner);

        // Verify the contract balance
        assertEq(address(contractInstance).balance, 1 ether);
    }

    function testWithdrawByOwner() public {
        uint256 ownerInitialBalance = address(owner).balance;
        uint256 contractBalance = address(contractInstance).balance;

        // Withdraw funds as the owner
        contractInstance.withdraw();

        // Verify that the contract's balance is zero
        assertEq(address(contractInstance).balance, 0);

        // Verify that the owner's balance increased by the contract balance
        assertEq(address(owner).balance, ownerInitialBalance + contractBalance);
    }

    function testWithdrawByNonOwner() public {

        uint256 initialValue = address(contractInstance).balance;
        console.log("Pre deposit value: ", initialValue);

        (bool success, ) = address(contractInstance).call{value: 1 ether}("");
        require(success); // Fund the contract with 1 ETH

        initialValue = address(contractInstance).balance;
        console.log("Initial value: ", initialValue);

        // Set the next call to be made from a non-owner address
        vm.prank(nonOwner);

        // Expect the withdraw call to revert because the caller is not the owner
        vm.expectRevert();
        contractInstance.withdraw();

        // Verify that the contract's balance remains unchanged
        console.log("Following bandit withdraw: ", address(contractInstance).balance);
        assertEq(address(contractInstance).balance, initialValue);
    }

    function testInsufficientDeploymentFunds() public {
        // Attempt to deploy the contract with less than 1 ETH
        vm.expectRevert();
        new Contract{value: 0.5 ether}();
    }
}
