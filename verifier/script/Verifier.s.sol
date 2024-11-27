// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SignatureVerifier} from "../src/Verifier.sol";

contract VerifierScript is Script {
    SignatureVerifier public verifier;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        verifier = new SignatureVerifier();

        vm.stopBroadcast();
    }
}
