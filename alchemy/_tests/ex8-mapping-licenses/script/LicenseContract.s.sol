// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LicenseContract} from "../src/LicenseContract.sol";

contract LicenseContractScript is Script {
    LicenseContract public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new LicenseContract();

        vm.stopBroadcast();
    }
}
