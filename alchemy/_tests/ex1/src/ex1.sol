// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract Contract {
    error OnlyOwnerCanWithdraw();
    address owner;
    constructor() payable {
        require(msg.value >= 1e18);
        owner = msg.sender;
    }

    function withdraw() external {
      uint256 balance = address(this).balance;
      console.log("Owner: ", owner, " Sender: ", msg.sender);
      require(msg.sender == owner, OnlyOwnerCanWithdraw());
      console.log("Balance: ", balance);
      (bool success, ) = payable(msg.sender).call{value: balance}("");
      require(success);
    }

    receive() external payable {} // we need this to receive funds
}