// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        bool executed;
    }

    struct Vote {
        bool voted;
        bool vote;
    }

    event ProposalCreated(uint proposalId);
    event VoteCast(uint proposalId, address voter);
    
    Proposal[] public proposals;
    mapping(address => mapping(uint256 => Vote)) votes;

    uint256 VOTE_THRESHOLD = 10;

    mapping(address => bool) allowedVoters;
    address owner;

    constructor(address[] memory voters) {
        owner = msg.sender;
        allowedVoters[msg.sender] = true;
        for(uint i=0; i< voters.length; i++){
            allowedVoters[voters[i]] = true;
        }
    }

    function maybeExecuteProposal(uint256 proposalId) private {
        require(proposals[proposalId].executed == false, "proposal already executed");

        if(proposals[proposalId].yesCount >= VOTE_THRESHOLD) {
            proposals[proposalId].executed = true;            
            (bool success, ) = proposals[proposalId].target.call(proposals[proposalId].data);
            require(success, "execution failed");
        }
    }    

    function getNumberOfProposals() external view returns (uint) {
        return proposals.length;
    }

    function isAllowed() external view returns (bool) {
        return allowedVoters[msg.sender];
    }

    function newProposal(address target, bytes calldata _data) external returns (uint256) {
        require(allowedVoters[msg.sender] == true, "creation not allowed");
        Proposal memory _proposal = Proposal(target, _data, 0, 0, false);        
        proposals.push(_proposal);
        uint256 proposalId = proposals.length - 1;
        emit ProposalCreated(proposalId);
        return proposalId;
    }    

    function castVote(uint proposalId, bool vote) external {
        require(allowedVoters[msg.sender] == true, "voting not allowed");
        emit VoteCast(proposalId, msg.sender); // this is NOT ok here but was left for the sake of the example
        if (votes[msg.sender][proposalId].voted) {
            if (votes[msg.sender][proposalId].vote != vote) {
                // we reset the vote
                bool previousVote = votes[msg.sender][proposalId].vote;
                proposals[proposalId].yesCount -= previousVote?1:0;
                proposals[proposalId].noCount -= previousVote?0:1;
            }
            else return;
        }
        proposals[proposalId].yesCount += vote?1:0;
        proposals[proposalId].noCount += vote?0:1;
        votes[msg.sender][proposalId].voted = true;
        votes[msg.sender][proposalId].vote = vote;      
        maybeExecuteProposal(proposalId);  
    }
}
