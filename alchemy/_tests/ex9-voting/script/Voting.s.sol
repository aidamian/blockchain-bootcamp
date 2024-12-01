// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Voting} from "../src/Voting.sol";

contract VotingScript is Script {
    Voting public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address[] memory voters = new address[](3);

        counter = new Voting(voters);

        vm.stopBroadcast();
    }
}
