// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract Lottery {
    
    /* State variables */
    // List of all players participating in the lottery
    address[] public players;
    // Address of admin
    address public immutable admin;
    // Total amount of money to be won for current Lottery round 
    uint public winningAmount;
    // Balances pending to be withdrawn by winners 
    mapping(address => uint) winnerBalances;
    
    event WinnerDeclared(address winner, uint amount);

    constructor() {
        // Setting up admin. 
        // Note: admin is immutable, so cannot be changed throughout the contract
        admin = msg.sender;
    }

    function enter() external payable {
        require(msg.value >= 0.1 ether, "Minimum 0.1 eth required");
        // Add the ether passed in message to winningAmount
        winningAmount += msg.value;
        players.push(msg.sender);
    }

    function claimReward() external {
        require(winnerBalances[msg.sender] > 0, "No pending balance");
        
        // Set the winnerBalances of msg.sender to avoid reentrancy attack
        uint amount = winnerBalances[msg.sender];
        winnerBalances[msg.sender] = 0;
        
        // Transfer the lottery amount to the winner using call method
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
    
    function decideWinner() public onlyAdmin {
        // Use the random method to decide winner among Lottery winners
        uint winningIndex = random() % players.length;
        // Add the winningAmount to balance of lottery winner
        winnerBalances[players[winningIndex]] += winningAmount;

        // Emit event when winner is decided
        emit WinnerDeclared(players[winningIndex], winningAmount);
        
        // reset the state of the contract
        players = new address[](0);
        winningAmount = 0;
    }

    function random() private view returns(uint) {
        // Below function generates pseudorandom uint based on admin and block.timestamp
        return uint(keccak256(abi.encodePacked(admin, block.timestamp)));
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Unauthorized");
        _;
    }
}