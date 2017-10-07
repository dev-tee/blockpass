pragma solidity ^0.4.3;

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

    function setContractManagerAddress(address contractManagerAddress) returns (bool) {
        // Contract manager address should only be set if it hasn't been set yet.
        // Updateable only by the contract manager itself.
        if (MAN == 0x0 || MAN == msg.sender) {
            MAN = contractManagerAddress;
            return true;
        } else {
            return false;
        }
    }
}


// Interface for getting contracts from ContractManager
interface ContractProvider {
    function contracts(bytes32 name) public returns (address);
}


contract ContractManager is Owned {

    mapping (bytes32 => address) public contracts;

    function addContract(bytes32 contractName, address contractAddress) onlyOwner returns (bool) {
        // Add contract only if we can set the manager on it.
        if (ManagedContract(contractAddress).setContractManagerAddress(this)) {
            contracts[contractName] = contractAddress;
            return true;
        } else {
            return false;
        }
    }

    function getContract(bytes32 name) constant returns (address) {
        return contracts[name];
    }
}
