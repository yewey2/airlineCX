// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MSBAAirlinesCompensationSmartContract {

    uint256 buffer = 7200; // Set 2 hours buffer for landing for now, before contract triggers
    uint256 amtPayable = 1; // Set to 1 for now

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
        bytes32 _passportNumber, uint256 _duration, address payable _addr) public {
            require(!exist(_flightId, _departureDateTime, _passportNumber));
            require(_flightId.length > 0);
            require(_departureDateTime > 0);
            require(_passportNumber.length > 0);
            
            contractsByFlights[_flightId][_departureDateTime].push(Contract(
                _flightId, _departureDateTime, _passportNumber, _duration, _addr
            ));

            emit contractAdded();

            // contractsByCustomer[_passportNumber].push(Contract(
            //     _flightId, _departureDateTime, _passportNumber, _duration, _addr
            // ));
    }

    // this function will be called by the oracle
    function setFlightLandingTime(bytes32 _flightId, uint256 _departureDateTime, uint256 _arrivalDateTime) public {
        if (!((contractsByFlights[_flightId][_departureDateTime]).length > 0)){
            // no flights found
            return;
        }

        uint256 _duration = contractsByFlights[_flightId][_departureDateTime][0].duration;
        if (_departureDateTime + _duration + buffer < _arrivalDateTime) {
            // the flight arrived on time / within buffer period

            // remove contract from contractsByFlights
            delete contractsByFlights[_flightId][_departureDateTime];
            return;
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
        delete contractsByFlights[_flightId][_departureDateTime];


    }


    // Testing purposes, new contract
    Contract public new_contract = Contract(
        "SQ123", 1697302294, "K12334567A", 12300, payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4)
    );
    function test() public {
        contractsByFlights["SQ123"][1697302294].push(new_contract);
    }
    
    function getNow() public view returns (uint256) {
        return block.timestamp;
    }

}

