// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Verifier.sol";
import "forge-std/console.sol";

contract SignatureVerifierTest is Test {
    SignatureVerifier verifier;

    function setUp() public {
        verifier = new SignatureVerifier();
    }

    function testVerifySignature() public view {
        // Data from your Python script
        string memory node = "0xai_AthDPWc_k3BKJLLYTQMw--Rjhe3B6_7w76jlRpT6nDeX";
        uint256[] memory epochs = new uint256[](1);
        uint256[] memory epochs_vals = new uint256[](1);

        epochs[0] = 262;
        // epochs[1] = 246;
        // epochs[2] = 247;
        // epochs[3] = 248;
        // epochs[4] = 249;
        // epochs[5] = 250;

        epochs_vals[0] = 0;
        // epochs_vals[1] = 37;
        // epochs_vals[2] = 30;
        // epochs_vals[3] = 6;
        // epochs_vals[4] = 19;
        // epochs_vals[5] = 4;

        // Signature and signer address from your Python script
        bytes memory signature = hex"c36176619a56bffca1c39148c206883e2a8377625af412c321f15ba7f60e965249e60a77acb581165c0f975ed7cb485d8ee52633567a07f6ce02f8d71ffe71521b";
        address signer = 0x129a21A78EBBA79aE78B8f11d5B57102950c1Fc0;

        // Compute message hash
        bytes32 messageHash = verifier.getMessageHash(node, epochs, epochs_vals);
        console.logBytes32(messageHash);

        // // Expected message hash from your Python code
        // bytes32 expectedMessageHash = 0x0dd65c4be76c8d86967ef99c800ca30c66ff7a859e780a283c76e4cafd81143f;
        // console.logBytes32(expectedMessageHash);

        // // Assert that the message hashes match
        // assertEq(messageHash, expectedMessageHash, "Message hashes do not match");

        // Compute Ethereum Signed Message hash
        bytes32 ethSignedMessageHash = verifier.getEthSignedMessageHash(messageHash);
        console.logBytes32(ethSignedMessageHash);

        // Perform the verification
        bool result = verifier.verify(signer, node, epochs, epochs_vals, signature);

        // Assert the verification result
        assertTrue(result, "Signature verification failed");
    }
}
