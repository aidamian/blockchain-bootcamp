// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract Example {
    enum OrderStatus {
        Created,
        Paid,
        Delivered,
        Received, 
        Closed
    }

    struct Order {
        address buyer;
        address seller;
        uint256 amount;
        OrderStatus status;
    }

    Order[] public orders;

    function getOrder(uint256 key) external view returns (Order memory) {
        return orders[key];
    }

    // indexed keyword is used to make the event filterable
    event OrderCreated(uint256 indexed key, uint256 amount);
    // OrderCreated.where({ key: 0 }).watch(console.log)

    function createOrder(address buyer, address seller, uint256 amount) external returns (uint256) {
        // we can use memory keyword to store the struct in memory then push it
        Order memory order = Order(buyer, seller, amount, OrderStatus.Created);
        orders.push(order);
        emit OrderCreated(orders.length - 1, amount);
        return orders.length - 1;
    }

    function payment(uint256 key) external payable {
        // we are using storage keyword to store the struct in storage
        // so that we can update the status of the order
        Order storage order = orders[key];
        require(order.buyer == msg.sender, "Only buyer can call this function");
        require(order.amount == msg.value, "Amount should be equal to order amount");
        // created -> paid -> ?
        require(order.status == OrderStatus.Created, "Order is not created yet");

        order.status = OrderStatus.Paid;
        // or we can do orders[key].status = OrderStatus.Paid;
    }

    function deliver(uint256 key) external {
        Order storage order = orders[key];
        require(order.seller == msg.sender, "Only seller can call this function");
        require(order.status == OrderStatus.Paid, "Order is not paid yet");

        order.status = OrderStatus.Delivered;
    }

    function received(uint256 key) external {
        Order storage order = orders[key];
        require(order.buyer == msg.sender, "Only buyer can call this function");
        require(order.status == OrderStatus.Delivered, "Order is not delivered yet");

        order.status = OrderStatus.Received;
        payable(order.seller).transfer(order.amount);

        // bool isCtr = isContract(order.seller);
        // if(isCtr) {
        //         // Use .call for contracts
        //         (bool success, ) = payable(order.seller).call{value: order.amount}("");
        //         require(success, "Transfer to seller failed");
        //     } else {
        //         // Use transfer for EOAs
        //         payable(order.seller).transfer(order.amount);        
        // }
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
