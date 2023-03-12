// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Calculator {

    /* State variables */
    uint public result;
    
    function add(uint a, uint b) public {
        result = a + b;
    }
    
    function subtract(uint a, uint b) public {
        result = a - b;
    }
    
    function multiply(uint a, uint b) public {
        result = a * b;
    }
    
    function divide(uint a, uint b) public {
        require(b != 0, "Cannot divide by zero");
        result = a / b;
    }
}
