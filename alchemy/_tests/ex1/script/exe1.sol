// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Contract} from "../src/ex1.sol";

contract CounterScript is Script {
    Contract public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new Contract();

        vm.stopBroadcast();
    }
}
