// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract Bank {
    // Using mapping to store balances of all users
    mapping(address => uint) public balances;

    function deposit() payable public {
        require(msg.value > 0, "Deposit value should be more than 0");
        // Add the ether passed in message to balance of sender
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) payable public {
        require(balances[msg.sender] >= amount, "Not enough balance");
        
        // Performing state update before transferring ether to prevent reentrancy attack
        balances[msg.sender] -= amount;

        // Since the returned data value is not used, we omitted it - 
		// (bool sent, bytes memory data) = msg.sender.call{value: amount}("");
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to withdraw Ether");
    }

    function transfer(uint amount, address recipient) public {
        require(recipient != address(0), "Invalid recipient address");
        require(balances[msg.sender] >= amount, "Not enough balance");
        
        // Performing state update of msg.sender and recipient
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }
}
