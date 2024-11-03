// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract Example {
    uint8 a = 255; // 0 -> 255
    uint256 b = 22; // alias: uint

    int8 c = 127; // -128 -> 127
    int256 d = -55; // alias: int256

    bool myCondition = true;

    constructor() {
      unchecked {
        a += 1;
      }
        
      console.log(a);
      // console.log("b: %d", b);
      // console.log("c: %d", c);
      // console.log("d: %d", d);
      // console.log("myCondition: %s", myCondition ? "true" : "false");
    }

    enum Choice {
        Up,
        Down,
        Left,
        Right
    }

    Choice choice = Choice.Up;
}
