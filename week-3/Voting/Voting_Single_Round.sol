// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract Voting {

    struct CandidateInfo {
        string name;
        uint votes;
    }

    mapping(address => bool) public voters;
    mapping(address => CandidateInfo) public candidates;

    address immutable public admin;
    bool public isOpen;
    address public leadingCandidate;
    uint public leadingVotes;

    event DeclareWinner(address winner, uint voteCount);

    modifier _onlyAdmin() {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerCandidate(string calldata _name) public {
        require(!isOpen, "Voting has already started");
        candidates[msg.sender] = CandidateInfo(_name, 0);
    }

    function startVoting() _onlyAdmin public {
        require(!isOpen, "Voting has already started");
        isOpen = true;
    }

    function stopVoting() _onlyAdmin public {
        isOpen = false;
        emit DeclareWinner(leadingCandidate, leadingVotes);
    }

    function vote(address _to) public {
        require(isOpen, "Voting has not started");
        voters[msg.sender] = true;
        CandidateInfo storage candidate = candidates[_to];
        candidate.votes += 1;

        if (candidate.votes > leadingVotes && leadingCandidate != _to) {
            leadingVotes = candidate.votes;
            leadingCandidate = _to;
        }
    }
}
