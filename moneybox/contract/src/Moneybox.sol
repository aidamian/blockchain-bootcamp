// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract Moneybox {

    uint256 public ballance;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable { // 0xD197aAf1Ef2584322F191b2B72388f18718A5BC7      
        console.log("CTR RCV:", msg.value / 1 ether, "ETH");
        console.log("CTR FRM:", msg.sender);
        ballance += msg.value;
    }

    // gas efficient: receive() external payable {}

    function withdraw(uint amount, address payable destAddr) public {
        require(ballance >= amount, "Not enough money");
        require(msg.sender == owner, "Only owner can withdraw");
        destAddr.transfer(amount);
        ballance -= amount;
    }
}