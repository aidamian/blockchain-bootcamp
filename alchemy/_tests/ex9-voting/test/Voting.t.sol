// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Voting.sol";


contract Target {
    address public sender;

    function mint() external {
        sender = msg.sender;
        console.log("mint called by: ", msg.sender);
    }
}


contract VotingTest is Test {
    Voting public voting;
    address public _target = address(0x100);
    bytes public _data = abi.encodePacked(bytes2(0x1337));
    Target public target;
    address nonMember = address(0xdeadbeef);
    address[] members;

    uint256 proposalId1;
    uint256 proposalId2;


    function setUp() public {
        for(uint160 i = 100; i <= 200; i++) {
            members.push(address(i));
        }
        voting = new Voting(members);
        target = new Target();
        console.log("Address: ", address(this), " is allowed", voting.isAllowed());
        proposalId1 = voting.newProposal(_target, _data);
        console.log("Proposal 1: ", proposalId1, "Nr proposals: ", voting.getNumberOfProposals());

        vm.prank(members[0]);
        voting.castVote(proposalId1, true);
        vm.prank(members[1]);
        voting.castVote(proposalId1, true);
        vm.prank(members[2]);
        voting.castVote(proposalId1, false);

        proposalId2 = voting.newProposal(address(target), abi.encodeWithSignature("mint()"));
        console.log("Proposal 2: ", proposalId2, "Nr proposals: ", voting.getNumberOfProposals());
        
        for(uint160 i = 1; i <= 9; i++) {
            vm.prank(members[i]);
            voting.castVote(proposalId2, true);
        }        
    }

    function testProposal() public view {
        (,, uint yesCount, uint noCount,) = voting.proposals(proposalId1);
        console.log("Proposal", proposalId1, "yesCount: ", yesCount);
        assertEq(yesCount, 2);   
        assertEq(noCount, 1);  
    }

    function testSwitchFromSupports() public {
        vm.prank(members[0]);
        voting.castVote(proposalId1, false);
        vm.prank(members[1]);
        voting.castVote(proposalId1, false);

        (,, uint yesCount, uint noCount, ) = voting.proposals(proposalId1);
        assertEq(yesCount, 0);   
        assertEq(noCount, 3);  
    }

    function testSwitchToSupports() public {
        vm.prank(members[2]);
        voting.castVote(0, true);

        (,, uint yesCount, uint noCount, ) = voting.proposals(proposalId1);
        assertEq(yesCount, 3);   
        assertEq(noCount, 0);  
    }


    function testProposalEvent() public {
        vm.recordLogs();
        uint256 proposalId = voting.newProposal(_target, _data);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        console.log("nr entries: ", entries.length);
        console.log("abi.decode(entries[0].data, (uint)): ", abi.decode(entries[0].data, (uint)));

        assertEq(entries.length, 1, "there should only be one event emitted");
        assertEq(entries[0].topics[0], keccak256("ProposalCreated(uint256)"), "the first topic should be the name of the event, ProposalCreated(uint256)");
        assertEq(abi.decode(entries[0].data, (uint)), proposalId, "the data in the event should be the proposal id, 0");
    }

    function testVoteEvent() public {
        uint256 proposalId = voting.newProposal(_target, _data);
        console.log("proposalId: ", proposalId);
        
        vm.recordLogs();
        
        address voter = members[0];
        vm.startPrank(voter);
        voting.castVote(proposalId, true);
        voting.castVote(proposalId, true);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 2, "there should be two vote cast events emitted");
        assertEq(entries[1].topics[0], keccak256("VoteCast(uint256,address)"), "the first topic should be the name of the event, VoteCast(uint256,address)");
    }    

    function testVoteNonMember() public {
        vm.prank(nonMember);
        vm.expectRevert();
        voting.castVote(proposalId1, true);
    }    

    function testStateBefore() public  view {
        assertEq(target.sender(), address(0), "the target should not have been called until 10 supporting votes");
    }

    function testStateAfter() public {
        vm.prank(members[20]);
        voting.castVote(proposalId2, true);
        assertEq(target.sender(), address(voting), "the proposal should have been executed after 10 supporting votes");
    }    
}
