// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Example.sol";

contract ExampleTest is Test {
    Example public example;

    function setUp() public {
        example = new Example();
    }

    function testExample() public {
        address buyer = address(0xADA);
        address seller = address(0xB0B);

        uint256 orderId = example.createOrder(buyer, seller, 1 ether);

        // we are acting as buyer
        hoax(buyer);

        example.payment{value: 1 ether}(orderId);

        Example.Order memory order = example.getOrder(orderId);

        assertEq(address(example).balance, 1 ether);
        assertEq(uint8(order.status), uint8(Example.OrderStatus.Paid));

        // we are acting as seller        
        hoax(seller);
        example.deliver(orderId);

        order = example.getOrder(orderId);

        assertEq(uint8(order.status), uint8(Example.OrderStatus.Delivered));       

        // we are acting as buyer
        hoax(buyer);
        example.received(orderId);

        order = example.getOrder(orderId);

        console.log("Order status: %s", uint8(order.status));
        console.log("Contract balance: %s", address(example).balance);
        console.log("Seller balance: %s", seller.balance);
        console.log("Buyer balance:  %s", buyer.balance);

        assertEq(uint8(order.status), uint8(Example.OrderStatus.Received));
        assertEq(address(example).balance, 0);
        assertEq(seller.balance, buyer.balance + 1 ether);
    }
}
