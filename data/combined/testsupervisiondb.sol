pragma solidity ^0.4.0;

import "../../contractmanager.sol";
import "../supervisordb.sol";
import "../testdb.sol";


contract TestSupervisionDB is ManagedContract {

    struct TestSupervision {
        address supervisorID;
        uint testID;
    }

    TestSupervision[] testSupervisions;

    function exists(uint id) public constant returns(bool) {
        return testSupervisions.length > id;
    }

    function addTestSupervision(address supervisorID, uint testID) public {
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address testDB = ContractProvider(MAN).contracts("testdb");
        
        SupervisorDB(supervisorDB).addTestSupervisionID(supervisorID, testSupervisions.length);
        TestDB(testDB).addTestSupervisionID(testID, testSupervisions.length);
        
        testSupervisions.push(TestSupervision(supervisorID, testID));
    }

    function getTestSupervision(uint id) public constant returns(address supervisorID, uint testID) {
        require(exists(id));
        return(testSupervisions[id].supervisorID, testSupervisions[id].testID);
    }
}
