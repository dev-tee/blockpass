pragma solidity ^0.4.0;

import "./contractmanager.sol";
import "../data/studentdb.sol";
import "../data/supervisordb.sol";


contract AccountManager is ManagedContract {

    event RegisteredStudent(address, bytes32, uint);
    event RegisteredSupervisor(address, bytes32);

    function registerStudent(address account, bytes32 name, uint matrnr) public {
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        StudentDB(studentDB).addStudent(account, name, matrnr);

        RegisteredStudent(account, name, matrnr);
    }

    function registerSupervisor(address account, bytes32 name) public {
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        SupervisorDB(supervisorDB).addSupervisor(account, name);

        RegisteredSupervisor(account, name);
    }
}
