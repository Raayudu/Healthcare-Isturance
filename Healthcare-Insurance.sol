//SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.19;

contract HealthCare {
    address public hospitalAdmin;   //address of hospitalAdmin
    address public labAdmin;    //address of labAdmin

    struct Record { //patient Records
        uint256 ID;
        uint256 price;
        uint256 signatureCount;
        string testName;
        string date;
        string hospitalName;
        bool isValue;
        address pAddr;
        mapping (address => uint256) signature;
    }

    constructor(address _labAdmin) {
        hospitalAdmin = msg.sender;
        labAdmin = _labAdmin;
    }

    //Mapping to store records
    mapping (uint256 => Record) public _records;
    uint256[] public recordsArr;

    event recordCreated(uint256 ID, string testName, string date, string hospitalName, uint256 price);
    event recordSigned(uint256 ID, string testName, string date, string hospitalName, uint256 price);

     modifier signOnly {    // to signin officials only
        require (msg.sender == hospitalAdmin || msg.sender == labAdmin, "You are not authorized to sign this.");
        _;
    }

    modifier checkAuthBeforeSign(uint256 _ID) { //checking authority before signin
        require(_records[_ID].isValue, "Record does not exist");
        require(address(0) != _records[_ID].pAddr, "Address is zer0");
        require(msg.sender != _records[_ID].pAddr, "You are not authorized to perform this action");
        require(_records[_ID].signature[msg.sender] != 1, "Same person cannot sign twice.");
        _;
    }

    modifier validateRecord(uint256 _ID) {
        //Only allows new records to be created
        require(!_records[_ID].isValue, "Record with this ID already exists");
        _;
    }

    //Create new record
    function newRecord (
        uint256 _ID,
        string memory _tName,
        string memory _date,
        string memory hName,
        uint256 price
    ) validateRecord(_ID) public {
        Record storage _newrecord = _records[_ID];
        _newrecord.pAddr = msg.sender;
        _newrecord.ID = _ID;
        _newrecord.testName = _tName;
        _newrecord.date = _date;
        _newrecord.hospitalName = hName;
        _newrecord.price = price;
        _newrecord.isValue = true;
        _newrecord.signatureCount = 0;

        recordsArr.push(_ID);
        emit recordCreated(_newrecord.ID, _tName, _date, hName, price);
    }

    //Function to sign a record
    function signRecord(uint256 _ID) signOnly checkAuthBeforeSign(_ID) public {
        Record storage records = _records[_ID];
        records.signature[msg.sender] = 1;
        records.signatureCount++;

        //Check if the record has been signed by both the authorities to process insurance claim
        if(records.signatureCount == 2)
            emit recordSigned(records.ID, records.testName, records.date, records.hospitalName, records.price);
    }

}
