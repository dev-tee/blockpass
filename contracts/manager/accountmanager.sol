pragma solidity ^0.4.3;

import "./contractmanager.sol";
import "../data/studentdb.sol";
import "../data/supervisordb.sol";


contract AccountManager is ManagedContract {

    event RegisteredStudent(address, string, uint);
    event RegisteredSupervisor(address, string, string);

    function registerStudent(address account, string name, uint matrNr) public {
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        StudentDB(studentDB).addStudent(account, name, matrNr);

        RegisteredStudent(account, name, matrNr);
    }

    function registerSupervisor(address account, string name, string uaccountID) public {
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        SupervisorDB(supervisorDB).addSupervisor(account, name, uaccountID);

        RegisteredSupervisor(account, name, uaccountID);
    }
}
