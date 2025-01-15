// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import "forge-std/console.sol";



contract SignatureVerifier {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    function verify(
        address signer,
        address node,
        uint256[] calldata epochs,
        uint256[] calldata epochs_vals,
        bytes calldata signature
    ) public pure returns (bool) {


        bytes32 messageHash = getMessageHash(node, epochs, epochs_vals);
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        address recoveredSigner = ethSignedMessageHash.recover(signature);

        console.log("Signer   ", signer);
        console.log("Recovered", recoveredSigner);
        return (recoveredSigner == signer);
    }

    function getMessageHash(
        address node,
        uint256[] memory epochs,
        uint256[] memory epochs_vals
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(node, epochs, epochs_vals));
    }

    function getEthSignedMessageHash(bytes32 messageHash) public pure returns (bytes32) {
        return messageHash.toEthSignedMessageHash();
    }

}




