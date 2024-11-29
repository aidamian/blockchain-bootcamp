// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {LicenseContract} from "../src/LicenseContract.sol";

contract LicenseContractTest is Test {
    LicenseContract public example;

    function setUp() public {
        counter = new LicenseContract();
    }

    function test_one() public {
    }

}
