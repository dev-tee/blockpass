pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../testdb.sol";


contract TestParticipationDB is ManagedContract {

    struct TestParticipation {
        address studentID;
        uint testID;
        uint idIndex;
    }

    bytes32[] testParticipationIDs;
    mapping(bytes32 => TestParticipation) testParticipations;

    function exists(address studentID, uint testID) public constant returns(bool) {
        return exists(keccak256(studentID, testID));
    }

    function exists(bytes32 id) internal constant returns(bool) {
        if (testParticipationIDs.length == 0) {
            return false;
        }
        TestParticipation memory savedValue = testParticipations[id];
        uint savedIDindex = savedValue.idIndex;
        bytes32 savedID = testParticipationIDs[savedIDindex];
        return id == savedID;
    }

    function addTestParticipation(address studentID, uint testID) public {
        bytes32 id = keccak256(studentID, testID);
        require(!exists(id));

        testParticipations[id].studentID = studentID;
        testParticipations[id].testID = testID;
        testParticipations[id].idIndex = testParticipationIDs.length;
        testParticipationIDs.push(id);

        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address testDB = ContractProvider(MAN).contracts("testdb");

        StudentDB(studentDB).addTestParticipationID(studentID, id);
        TestDB(testDB).addTestParticipationID(testID, id);
    }

    function getTestParticipationAt(uint index) public constant returns(address studentID, uint testID) {
        return getTestParticipation(testParticipationIDs[index]);
    }

    function getTestParticipation(bytes32 id) public constant returns(address studentID, uint testID) {
        require(exists(id));
        return(testParticipations[id].studentID, testParticipations[id].testID);
    }
}
