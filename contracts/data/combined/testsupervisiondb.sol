pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../supervisordb.sol";
import "../testdb.sol";

// This contract is responsible for the n-to-n
// relationship between tests and supervisors.
// It represents a supervisors's supervision of a test
// and provides functions to get, add and query for values.


contract TestSupervisionDB is ManagedContract {

    // This struct saves the relationship and
    // also holds a reference to its own id.
    struct TestSupervision {
        address supervisorID;
        uint testID;
        uint idIndex;
    }

    // This array holds all ids for the relationships.
    bytes32[] testSupervisionIDs;

    // This mapping holds all individual relationships.
    mapping(bytes32 => TestSupervision) testSupervisions;

    // Check whether a relationship between
    // a given supervisor and test already exists.
    function exists(address supervisorID, uint testID) public constant returns(bool) {
        return exists(keccak256(supervisorID, testID));
    }

    // Use the provided id to check whether it already exits in our database
    // by reading out the value it points to in our mapping.
    // The saved value should point to an id that is identical to the one
    // that was provided if we have actually saved this value beforehand.
    function exists(bytes32 id) internal constant returns(bool) {
        if (testSupervisionIDs.length == 0) {
            return false;
        }
        TestSupervision memory savedValue = testSupervisions[id];
        uint savedIDIndex = savedValue.idIndex;
        bytes32 savedID = testSupervisionIDs[savedIDIndex];
        return id == savedID;
    }

    // Save a new relationship between a supervisor and a test.
    function addTestSupervision(address supervisorID, uint testID) public {
        bytes32 id = keccak256(supervisorID, testID);
        require(!exists(id));

        testSupervisions[id].supervisorID = supervisorID;
        testSupervisions[id].testID = testID;
        testSupervisions[id].idIndex = testSupervisionIDs.length;
        testSupervisionIDs.push(id);

        // Call the respective databases to save this
        // relationship's id for faster access.
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address testDB = ContractProvider(MAN).contracts("testdb");
        SupervisorDB(supervisorDB).addTestSupervisionID(supervisorID, id);
        TestDB(testDB).addTestSupervisionID(testID, id);
    }

    // Get the supervisor and test of the relationship at the index's position.
    function getTestSupervisionAt(uint index) public constant returns(address supervisorID, uint testID) {
        return getTestSupervision(testSupervisionIDs[index]);
    }

    // Use the provided id to find the relationship and return its values.
    function getTestSupervision(bytes32 id) public constant returns(address supervisorID, uint testID) {
        require(exists(id));
        return(testSupervisions[id].supervisorID, testSupervisions[id].testID);
    }
}
