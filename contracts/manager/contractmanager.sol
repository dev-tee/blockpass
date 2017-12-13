pragma solidity ^0.4.3;

import "../utility/owned.sol";

// This collection of contracts are responsible
// for the management of all contracts in the system itself.
// They provide means to call functions of other contracts
// and ways to replace old ones for updatability purposes.
//
// They are based on Monax's Solidity Tutorials.
// Tutorial 1 the five types model in this case.


// This contract acts as a base for all contracts that are used in this managed system.
// Contracts that extend it are discoverable through the contract manager contract.
// Additionally they have very basic permissions that can be attached to their functions.
contract ManagedContract {

    // This address is a reference to the contract manager contract.
    address MAN;

    // Modifier that provides basic permission and access control functions.
    modifier permission(bytes32 permittedSender) {
        require(msg.sender == ContractProvider(MAN).contracts(permittedSender));
        _;
    }

    // Set the contract manager contract's adress.
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


// This interface is part of the contract manager contract
// and provides an abstraction layer for getting the addresses
// of other contracts the contract manager contract knows.
interface ContractProvider {
    function contracts(bytes32 name) public returns (address);
}


// This contract is responsible for the general contract management.
// It is used to delegate access to contracts and can also be used
// to add new or replace old contracts to update them by redirection.
contract ContractManager is Owned {

    // This mapping holds all references to individual contracts.
    mapping (bytes32 => address) public contracts;

    // Add a new contract to the system.
    function addContract(bytes32 contractName, address contractAddress) onlyOwner returns (bool) {
        // Add contract only if we can set the manager on it.
        if (ManagedContract(contractAddress).setContractManagerAddress(this)) {
            contracts[contractName] = contractAddress;
            return true;
        } else {
            return false;
        }
    }

    // Get the contract that is registered under this name.
    function getContract(bytes32 name) constant returns (address) {
        return contracts[name];
    }
}
