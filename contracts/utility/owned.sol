pragma solidity ^0.4.3;

// This contract provides basic ownership
// and access control functions for contracts.
// It won't be instantiated but only extended by others.


contract Owned {

    // A public reference to the owner of the contract
    // in case they need to be contacted in some form.
    address public owner;

    // Constructor that simply sets the owner to the creator.
    function Owned() {
        owner = msg.sender;
    }

    // Modifier that ensures that only the owner
    // can call the tagged function.
    modifier onlyOwner {
        if (msg.sender == owner)
            _;
    }
}
