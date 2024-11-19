// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Example.sol";

contract ExampleTest is Test {
    A public a;
    B public b;

    function setUp() public {
        b = new B();
        a = new A(address(b));
    }

    function testExample() public {
        console.log("test contract: %s", address(this), " balance: %s", address(this).balance);
        console.log("a: %s", address(a), " balance: %s", address(a).balance);
        console.log("b: %s", address(b), " balance: %s", address(b).balance);
        a.callB{value: 1.5 ether}();
        assertEq(address(a).balance, 1.5 ether);
        assertEq(a.errorsCount(), 1);
        assertEq(b.x(), 0); // due to revert the x value should not have changed
    }
}
