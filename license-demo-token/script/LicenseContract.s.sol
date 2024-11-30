// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LicenseContract, MockERC20} from "../src/LicenseContract.sol";

contract LicenseContractScript is Script {
    LicenseContract public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        MockERC20 token = new MockERC20();
        counter = new LicenseContract(address(token));

        vm.stopBroadcast();
    }
}
