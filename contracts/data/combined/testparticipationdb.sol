pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../testdb.sol";

// This contract is responsible for the n-to-n
// relationship between tests and students.
// It represents a student's participation in a test
// and provides functions to get, add and query for values.


contract TestParticipationDB is ManagedContract {

    // This struct saves the relationship and
    // also holds a reference to its own id.
    struct TestParticipation {
        address studentID;
        uint testID;
        uint idIndex;
    }

    // This array holds all ids for the relationships.
    bytes32[] testParticipationIDs;

    // This mapping holds all individual relationships.
    mapping(bytes32 => TestParticipation) testParticipations;

    // Check whether a relationship between
    // a given student and test already exists.
    function exists(address studentID, uint testID) public constant returns(bool) {
        return exists(keccak256(studentID, testID));
    }

    // Use the provided id to check whether it already exits in our database
    // by reading out the value it points to in our mapping.
    // The saved value should point to an id that is identical to the one
    // that was provided if we have actually saved this value beforehand.
    function exists(bytes32 id) internal constant returns(bool) {
        if (testParticipationIDs.length == 0) {
            return false;
        }
        TestParticipation memory savedValue = testParticipations[id];
        uint savedIDindex = savedValue.idIndex;
        bytes32 savedID = testParticipationIDs[savedIDindex];
        return id == savedID;
    }

    // Save a new relationship between a student and a test.
    function addTestParticipation(address studentID, uint testID) public {
        bytes32 id = keccak256(studentID, testID);
        require(!exists(id));

        testParticipations[id].studentID = studentID;
        testParticipations[id].testID = testID;
        testParticipations[id].idIndex = testParticipationIDs.length;
        testParticipationIDs.push(id);

        // Call the respective databases to save this
        // relationship's id for faster access.
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address testDB = ContractProvider(MAN).contracts("testdb");
        StudentDB(studentDB).addTestParticipationID(studentID, id);
        TestDB(testDB).addTestParticipationID(testID, id);
    }

    // Get the student and test of the relationship at the index's position.
    function getTestParticipationAt(uint index) public constant returns(address studentID, uint testID) {
        return getTestParticipation(testParticipationIDs[index]);
    }

    // Use the provided id to find the relationship and return its values.
    function getTestParticipation(bytes32 id) public constant returns(address studentID, uint testID) {
        require(exists(id));
        return(testParticipations[id].studentID, testParticipations[id].testID);
    }
}
