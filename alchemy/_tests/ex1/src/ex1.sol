// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Contract {
    address owner;
    constructor() payable {
        require(msg.value >= 1e18);
        owner = msg.sender;
    }

    function withdraw() external {
        require(msg.sender == owner);
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
}