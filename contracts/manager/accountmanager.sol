pragma solidity ^0.4.3;

import "./contractmanager.sol";
import "../data/studentdb.sol";
import "../data/supervisordb.sol";


contract AccountManager is ManagedContract {

    event RegisteredStudent(address, bytes32, uint);
    event RegisteredSupervisor(address, bytes32, bytes32);

    function registerStudent(address account, bytes32 name, uint matrNr) public {
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        StudentDB(studentDB).addStudent(account, name, matrNr);

        RegisteredStudent(account, name, matrNr);
    }

    function registerSupervisor(address account, bytes32 name, bytes32 uaccountID) public {
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        SupervisorDB(supervisorDB).addSupervisor(account, name, uaccountID);

        RegisteredSupervisor(account, name, uaccountID);
    }
}
