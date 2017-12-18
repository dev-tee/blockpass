pragma solidity ^0.4.3;

import "./contractmanager.sol";
import "../data/studentdb.sol";
import "../data/supervisordb.sol";

// This contract is responsible for account management.
// It registers students as well as supervisors and
// makes it possible for them to use this system.


contract AccountManager is ManagedContract {

    // Modifier that ensures that an account has not
    // been registered as a student or supervisor yet.
    modifier accountNotRegisteredYet(address account) {
        require(!StudentDB(ContractProvider(MAN).contracts("studentdb"))
                    .isStudent(account)
            && !SupervisorDB(ContractProvider(MAN).contracts("supervisordb"))
                    .isSupervisor(account));
        _;
    }

    // This event is fired when a student account has been registered successfully.
    event RegisteredStudent(address, string, uint);

    // This event is fired when a supervisor account has been registered successfully.
    event RegisteredSupervisor(address, string, string);

    // Register an ethereum address as a student account
    // with the name and matrikel number that was provided.
    function registerStudent(address account, string name, uint matrNr) public accountNotRegisteredYet(account) {
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        StudentDB(studentDB).addStudent(account, name, matrNr);

        RegisteredStudent(account, name, matrNr);
    }

    // Register an ethereum address as a supervisor account
    // with the name and uaccount id that was provided.
    function registerSupervisor(address account, string name, string uaccountID) public accountNotRegisteredYet(account) {
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        SupervisorDB(supervisorDB).addSupervisor(account, name, uaccountID);

        RegisteredSupervisor(account, name, uaccountID);
    }
}
