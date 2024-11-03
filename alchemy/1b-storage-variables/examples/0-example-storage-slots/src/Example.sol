// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract Example {
    uint256 constant a = 55; // this is a constant - not stored in the contract storage
    uint256 b; // storage slot - 0x0
    bool c = true; // storage slot - 0x1

    constructor() {
        // SSTORE - store to some storage location
        // SLOAD - read from some storage location
        uint256 v0;
        uint256 v1;
        uint256 v2;
        assembly {
            v0 := sload(0x0) // read b value
            v1 := sload(0x1) // read c value
            v2 := sload(0x2) // nothing stored at this location - will return 0/false
            sstore(0x0, 100) // store 100 to b
        }
        console.log("v0: %s", v0);  // should be 0
        console.log("v1: %s", v1);  // should be 1
        console.log("v2: %s", v2);  // should be 0 (default value)
        console.log("a: %s", a);  // should be 55
        console.log("b: %s", b);  // should be 100 as it was updated via sstore
        console.log("c: %s", c);  // should be true
    }
}

