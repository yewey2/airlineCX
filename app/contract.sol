// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MSBAAirlinesCompensationSmartContract {

    address owner;

    constructor() payable {
        owner = msg.sender;
    }

    uint256 buffer = 7200; // Set 2 hours buffer for landing for now, before contract triggers
    uint256 amtPayable = 2500000; // Set to 50usd ~2.5Mwei for now, use stablecoins in the future

    struct Contract {
        bytes32 flightId; // e.g. SQ123
        uint256 departureDateTime; // e.g. 1697302294, UNIX time
        bytes32 passportNumber;
        uint256 duration;
        address payable addr;
    }

    // mapping(string => Contract[]) internal contractsByFlights;
    mapping(bytes32 => mapping(uint256 => Contract[])) public contractsByFlights; // To display for now, will be made internal 
    // mapping(bytes32 => Contract[]) public contractsByCustomer;                   // To display for now, will be made internal 

    event contractAdded();

    event contractCompensated();
    
    event compensationError();

    function exist (
        bytes32 _flightId, uint256 _departureDateTime, bytes32 _passportNumber) internal view returns (bool){
            for (uint i; i<contractsByFlights[_flightId][_departureDateTime].length; i++){
                Contract memory _contract = contractsByFlights[_flightId][_departureDateTime][i];
                if (_contract.passportNumber == _passportNumber){
                    return true;
            }}
            return false;
    }

    function addContract(
        bytes32 _flightId, uint256 _departureDateTime, 
        bytes32 _passportNumber, uint256 _duration, address payable _addr) public returns (Contract memory) {
            require(!exist(_flightId, _departureDateTime, _passportNumber));
            require(_flightId.length > 0);
            require(_departureDateTime > 0);
            require(_passportNumber.length > 0);
            Contract memory _c = Contract(
                _flightId, _departureDateTime, _passportNumber, _duration, _addr
            );
            contractsByFlights[_flightId][_departureDateTime].push(_c);

            emit contractAdded();
            return _c;

            // contractsByCustomer[_passportNumber].push(Contract(
            //     _flightId, _departureDateTime, _passportNumber, _duration, _addr
            // ));
    }

    // this function will be called by the oracle
    function setFlightLandingTime(bytes32 _flightId, uint256 _departureDateTime, uint256 _arrivalDateTime) public returns (uint256) {
        if (!((contractsByFlights[_flightId][_departureDateTime]).length > 0)){
            // no flights found
            return 1;
        }

        uint256 _duration = contractsByFlights[_flightId][_departureDateTime][0].duration;
        if (_departureDateTime + _duration - buffer > _arrivalDateTime) {
            // the flight arrived on time / within buffer period

            // remove contract from contractsByFlights
            // delete contractsByFlights[_flightId][_departureDateTime];
            return 2;
        }

        for (uint i; i<contractsByFlights[_flightId][_departureDateTime].length;i++) {
            // pay all customers
            address payable _addr = contractsByFlights[_flightId][_departureDateTime][i].addr;
            if(_addr.send(amtPayable)) {
                emit contractCompensated();
            } else {
                emit compensationError();
            }
            // // remove contract from contractsByCustomer
            // contractsByCustomer[contractsByFlights[_flightId][_departureDateTime][i].passportNumber];
        }
        // remove contract from contractsByFlights
        // delete contractsByFlights[_flightId][_departureDateTime];
        return 3;

    }


    // Testing purposes, new contract
    Contract public new_contract = Contract(
        "SQ123", 1697302294, "K12334567A", 12300, payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
    );
    function test() public returns (Contract memory) {
        contractsByFlights["SQ123"][1697302294].push(new_contract);
        return new_contract;
    }

    function test2() public view returns (Contract memory){
        return contractsByFlights["SQ123"][1697302294][0];

    }
    
    function getNow() public view returns (uint256) {
        return block.timestamp;
    }
    
    function getbal() public view returns (uint) {
        return address(this).balance;
    }

}

