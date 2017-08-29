pragma solidity ^0.4.0;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../testdb.sol";


contract TestParticipationDB is ManagedContract {

    struct TestParticipation {
        address studentID;
        uint testID;
    }

    TestParticipation[] testParticipations;

    function exists(uint id) public constant returns(bool) {
        return testParticipations.length > id;
    }

    function addTestParticipation(address studentID, uint testID) public {
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address testDB = ContractProvider(MAN).contracts("testdb");
        
        StudentDB(studentDB).addTestParticipationID(studentID, testParticipations.length);
        TestDB(testDB).addTestParticipationID(testID, testParticipations.length);
        
        testParticipations.push(TestParticipation(studentID, testID));
    }

    function getTestParticipation(uint id) public constant returns(address studentID, uint testID) {
        require(exists(id));
        return(testParticipations[id].studentID, testParticipations[id].testID);
    }
}
