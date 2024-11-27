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
        string memory node = "0xai_Amfnbt3N-qg2-qGtywZIPQBTVlAnoADVRmSAsdDhlQ-6";
        uint256[] memory epochs = new uint256[](6);
        uint256[] memory epochs_vals = new uint256[](6);

        epochs[0] = 245;
        epochs[1] = 246;
        epochs[2] = 247;
        epochs[3] = 248;
        epochs[4] = 249;
        epochs[5] = 250;

        epochs_vals[0] = 124;
        epochs_vals[1] = 37;
        epochs_vals[2] = 30;
        epochs_vals[3] = 6;
        epochs_vals[4] = 19;
        epochs_vals[5] = 4;

        // Signature and signer address from your Python script
        bytes memory signature = hex"f2a2821120c6508eaf98b39230ee79f37b571e60880422bade8e0011c4ed54ce3e979af6f92a275c844320000ca2f15be32ecf8526f9b2d30aee345aad7454a31c";
        address signer = 0xB053F29cC52816684cD9343E60D44ae467783258;

        // Compute message hash
        bytes32 messageHash = verifier.getMessageHash(node, epochs, epochs_vals);
        console.logBytes32(messageHash);

        // Expected message hash from your Python code
        bytes32 expectedMessageHash = 0x0dd65c4be76c8d86967ef99c800ca30c66ff7a859e780a283c76e4cafd81143f;
        console.logBytes32(expectedMessageHash);

        // Assert that the message hashes match
        assertEq(messageHash, expectedMessageHash, "Message hashes do not match");

        // Compute Ethereum Signed Message hash
        bytes32 ethSignedMessageHash = verifier.getEthSignedMessageHash(messageHash);
        console.logBytes32(ethSignedMessageHash);

        // Perform the verification
        bool result = verifier.verify(signer, node, epochs, epochs_vals, signature);

        // Assert the verification result
        assertTrue(result, "Signature verification failed");
    }
}
