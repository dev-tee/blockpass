pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../supervisordb.sol";
import "../testdb.sol";


contract TestSupervisionDB is ManagedContract {

    struct TestSupervision {
        address supervisorID;
        uint testID;
        uint idIndex;
    }

    bytes32[] testSupervisionIDs;
    mapping(bytes32 => TestSupervision) testSupervisions;

    function exists(address supervisorID, uint testID) public constant returns(bool) {
        return exists(keccak256(supervisorID, testID));
    }

    function exists(bytes32 id) internal constant returns(bool) {
        if (testSupervisionIDs.length == 0) {
            return false;
        }
        TestSupervision memory savedValue = testSupervisions[id];
        uint savedIDIndex = savedValue.idIndex;
        bytes32 savedID = testSupervisionIDs[savedIDIndex];
        return id == savedID;
    }

    function addTestSupervision(address supervisorID, uint testID) public {
        bytes32 id = keccak256(supervisorID, testID);
        require(!exists(id));

        testSupervisions[id].supervisorID = supervisorID;
        testSupervisions[id].testID = testID;
        testSupervisions[id].idIndex = testSupervisionIDs.length;
        testSupervisionIDs.push(id);

        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address testDB = ContractProvider(MAN).contracts("testdb");

        SupervisorDB(supervisorDB).addTestSupervisionID(supervisorID, id);
        TestDB(testDB).addTestSupervisionID(testID, id);
    }

    function getTestSupervisionAt(uint index) public constant returns(address supervisorID, uint testID) {
        return getTestSupervision(testSupervisionIDs[index]);
    }

    function getTestSupervision(bytes32 id) public constant returns(address supervisorID, uint testID) {
        require(exists(id));
        return(testSupervisions[id].supervisorID, testSupervisions[id].testID);
    }

}
