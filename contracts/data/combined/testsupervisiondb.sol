pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../supervisordb.sol";
import "../testdb.sol";


contract TestSupervisionDB is ManagedContract {

    struct TestSupervision {
        address supervisorID;
        uint testID;
        uint IDindex;
    }

    bytes32[] IDs;
    mapping(bytes32 => TestSupervision) testSupervisions;

    function exists(address supervisorID, uint testID) public constant returns(bool) {
        return exists(keccak256(supervisorID, testID));
    }

    function exists(bytes32 ID) internal constant returns(bool) {
        if (IDs.length == 0) {
            return false;
        }
        TestSupervision memory savedValue = testSupervisions[ID];
        uint savedIDindex = savedValue.IDindex;
        bytes32 savedID = IDs[savedIDindex];
        return ID == savedID;
    }

    function addTestSupervision(address supervisorID, uint testID) public {
        bytes32 ID = keccak256(supervisorID, testID);
        require(!exists(ID));

        testSupervisions[ID].supervisorID = supervisorID;
        testSupervisions[ID].testID = testID;
        testSupervisions[ID].IDindex = IDs.length;
        IDs.push(ID);

        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address testDB = ContractProvider(MAN).contracts("testdb");
        
        SupervisorDB(supervisorDB).addTestSupervisionID(supervisorID, ID);
        TestDB(testDB).addTestSupervisionID(testID, ID);
    }

    function getTestSupervisionAt(uint index) public constant returns(address supervisorID, uint testID) {
        return getTestSupervision(IDs[index]);
    }

    function getTestSupervision(bytes32 ID) public constant returns(address supervisorID, uint testID) {
        require(exists(ID));
        return(testSupervisions[ID].supervisorID, testSupervisions[ID].testID);
    }

}
