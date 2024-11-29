// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


contract Escrow {
    address public depositor;
    address public beneficiary;
    address public arbiter;

    error OnlyArbiterAllowedToApprove();

    event Approved(uint); // event fired if approaved

    constructor(address _arbiter, address _beneficiary) payable {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
    }

    function approve() external {
        if (msg.sender != arbiter){
            revert OnlyArbiterAllowedToApprove();
        } 
        uint toSend = address(this).balance; // get the ballance so we can emit later if everything is ok
        (bool result,) = payable(beneficiary).call{value: toSend}("");
        require(result);

        emit Approved(toSend); // emit the event after all is ok
    }
}