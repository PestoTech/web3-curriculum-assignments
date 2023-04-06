// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

contract EventTicket {
    // Creating a counter for the tickets
    using Counters for Counters.Counter;
    Counters.Counter private ticketCounter;

    // Creating a struct for the tickets
    struct Ticket {
        uint256 id;
        address owner;
        uint256 price;
    }

    // Mapping from tickedId to Ticket struct
    mapping(uint256 => Ticket) public tickets;
    // Mapping from user address to the number of tickets
    mapping(address => uint256) public userTickets;

    // Creating an event for the ticket purchase
    event TicketPurchased(uint256 indexed ticketId, address indexed owner, uint256 price);

    // Function to buy a ticket: the price should be greater than zero
    function buyTicket(uint256 _price) public {
        require(_price > 0, "Price should be greater than zero");

        // Increate the ticket counter by 1
        ticketCounter.increment();
        // Get the current ticket id
        uint256 newTicketId = ticketCounter.current();

        // Initialize a new ticket struct
        Ticket memory newTicket = Ticket({
            id: newTicketId,
            owner: msg.sender,
            price: _price
        });

        // Add the new ticket to the tickets mapping
        tickets[newTicketId] = newTicket;
        // Increase the number of tickets for the user
        userTickets[msg.sender]++;

        // Emit the TicketPurchased event
        emit TicketPurchased(newTicketId, msg.sender, _price);
    }

    // View Function to get the number of tickets for a user
    function getTicketCount(address _user) public view returns (uint256) {
        return userTickets[_user];
    }
}
