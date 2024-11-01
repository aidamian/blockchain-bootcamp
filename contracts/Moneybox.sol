// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Moneybox {

    uint256 public ballance;

    receive() external payable {
        ballance += msg.value;
    }
}