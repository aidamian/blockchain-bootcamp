// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract Example {
    uint256 public sum;
    uint256 public product;

    constructor(uint256 x, uint256 y) {
        console.log("called constructor with x:", x, "y:", y);
        (sum, product) = math(x, y);
        console.log("sum:", sum);
        console.log("product:", product);

        uint256 t;
        t = test(100);
        console.log("t:", t);
    }

    function test(uint256 x) private view returns(uint256) {
        console.log("called test with x:", x);
        return x + sum;
    }

    function math(uint256 x, uint256 y) private pure returns (uint256, uint256) {
        return (x + y, x * y);
    }
}
