pragma solidity ^0.4.0;

import "../utility/owned.sol";


//Monax Solidity Tutorials: 1 The Five Types Model
//https://monax.io/docs/tutorials/solidity/solidity_1_the_five_types_model/

// Base class for contracts that are used in this managed system.
contract ManagedContract {

    address MAN;

    modifier permission(bytes32 permittedSender) {
        require(msg.sender == ContractProvider(MAN).contracts(permittedSender));
        _;
    }

    function setContractManagerAddress(address contractManagerAddress) returns (bool result) {
        // Contract manager address should only be set if it hasn't been set yet.
        // Updateable only by the contract manager itself.
        if (MAN != 0x0 && MAN != msg.sender) {
            return false;
        }

        MAN = contractManagerAddress;

        return true;
    }
}


// Interface for getting contracts from ContractManager
contract ContractProvider {
    function contracts(bytes32 name) returns (address addr);
}


contract ContractManager is Owned {

    //dataman
    //courseman
    mapping (bytes32 => address) public contracts;

    function addContract(bytes32 name, address addr) onlyOwner {
        contracts[name] = addr;
    }

    function getContract(bytes32 name) constant returns (address addr) {
        return contracts[name];
    }
}
