// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Escrow} from "../src/escrow.sol";

contract CounterScript is Script {
    address public depositor;
    address public beneficiary;
    address public arbiter;
    Escrow public escrow;


    function setUp() public {
        arbiter = address(2);
        depositor = address(3);
        beneficiary = address(4);
    }

    function run() public {
        vm.startBroadcast();

        escrow = new Escrow{ value: 1 ether }(arbiter, beneficiary);

        vm.stopBroadcast();
    }
}
