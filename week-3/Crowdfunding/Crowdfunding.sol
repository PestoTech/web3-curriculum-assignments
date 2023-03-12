// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract Crowdfunding {
    struct Project {
        address creator;
        uint totalAsk;
        uint amountRaised;
        bool fundingCompleted;
        bool fundsWithdrawn;
    }

    Project[] public projects;
    mapping(uint => mapping(address => uint)) public contributions;

    function propose(uint amount) public {
        require(amount > 0, "Amount raised cannot be 0");

        Project memory newProject;
        newProject.creator = msg.sender;
        newProject.totalAsk = amount;
        
        projects.push(newProject);
    }

    function contribute(uint projectIndex) payable public {
        require(projectIndex < projects.length, "project does not exist");
        require(msg.value > 0, "Please pass Ether to contribute");

        Project storage targetProject = projects[projectIndex];
        if (targetProject.amountRaised >= targetProject.totalAsk) {
            revert("Target already achieved");
        }

        targetProject.amountRaised += msg.value;
        contributions[projectIndex][msg.sender] += msg.value;

        if (targetProject.amountRaised >= targetProject.totalAsk) {
            targetProject.fundingCompleted = true;
        }
    }

    function withdrawContribution(uint projectIndex) public {
        require(projectIndex < projects.length, "Proposal does not exist");
        Project storage targetProject = projects[projectIndex];

        if (targetProject.fundingCompleted == true || 
            targetProject.amountRaised >= targetProject.totalAsk) {
            revert("Withdraw not allowed");
        }

        uint withdrawAmount = contributions[projectIndex][msg.sender];
        require(withdrawAmount > 0, "Nothing to withdraw");

        targetProject.amountRaised -= withdrawAmount;
        contributions[projectIndex][msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: withdrawAmount}("");
        require(sent, "Failed to withdraw Ether");
    }

    function withdrawFunds(uint projectIndex) public {
        require(projectIndex < projects.length, "Proposal does not exist");
        Project storage targetProject = projects[projectIndex];

        if (targetProject.fundingCompleted == false || 
            targetProject.amountRaised < targetProject.totalAsk) {
            revert("Withdraw not allowed");
        }

        if (targetProject.fundsWithdrawn == true) {
            revert("Already withdrawn");
        }

        targetProject.fundsWithdrawn = true;

        (bool sent, ) = targetProject.creator.call{value: targetProject.amountRaised}("");
        require(sent, "Failed to withdraw Ether");
    }
}
