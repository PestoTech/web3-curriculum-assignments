// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract Crowdfunding {
    struct Project {
        address creator;
        uint totalAsk;
        uint amountRaised;
        bool isOpen;
    }

    Project[] public projects;
    mapping(uint => mapping(address => uint)) public contributions;

    function propose(uint amount) public {
        require(amount > 0, "Amount raised cannot be 0");

        Project memory newProject;
        newProject.creator = msg.sender;
        newProject.totalAsk = amount;
        newProject.amountRaised = 0;
        newProject.isOpen = true;
        
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
        contributions[projects.length][msg.sender] += msg.value;

        if (targetProject.amountRaised >= targetProject.totalAsk) {
            targetProject.isOpen = false;
        }
    }

    function withdrawContribution(uint projectIndex) public {
        require(projectIndex < projects.length, "Proposal does not exist");
        Project storage targetProject = projects[projectIndex];

        if (targetProject.isOpen == true || 
            targetProject.amountRaised >= targetProject.totalAsk) {
            revert("Withdraw not allowed");
        }

        uint withdrawAmount = contributions[projectIndex][msg.sender];
        require(withdrawAmount > 0, "Nothing to withdraw");

        contributions[projectIndex][msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: withdrawAmount}("");
        require(sent, "Failed to withdraw Ether");
    }
}
