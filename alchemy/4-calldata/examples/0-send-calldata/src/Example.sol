// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract A {
    uint256 public sum;
    uint256 public sum2;
    address b;

    constructor(address _b) {
        b = _b;
    
        // calling directly via a known address
        (bool success, bytes memory data) = b.call(
            // this must be the valid calldata 4bytesfunction signature then the arguments
            hex"1231234123421342134213412342134231" 
        );
        require(success);
        sum2 = abi.decode(data, (uint256));

        // high level call
        sum = iB(b).add(15, 10, 25);
    }
}

interface iB {
    function add(uint256, uint256, uint256) external pure returns (uint256);
}

contract B {
    fallback() external {
        console.logBytes(msg.data);
    }

    function add(uint256 x, uint256 y) external pure returns (uint256) {
        return x + y;
    }

    function add(uint256 x, uint256 y, uint256 z) external pure returns (uint256) {
        return x + y + z;
    }

}


