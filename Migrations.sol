//SPDX-License-Identifier:GPL-3.0

pragma solidity^0.8.19;

contract Migrations{    //contract migration to restrict signins  
    address public owner;
    uint public last_completed_migration;

    constructor() {
        owner = msg.sender;
    }

    modifier restricted() {
        if (msg.sender == owner)
        _;
    }

    function setCompleted(uint completed) public restricted {   // to migration set completed
        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {   //to upgrade new address
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }

}