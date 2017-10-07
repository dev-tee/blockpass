pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../testdb.sol";


contract TestParticipationDB is ManagedContract {

    struct TestParticipation {
        address studentID;
        uint testID;
        uint IDindex;
    }

    bytes32[] IDs;
    mapping(bytes32 => TestParticipation) testParticipations;

    function exists(address studentID, uint testID) public constant returns(bool) {
        return exists(keccak256(studentID, testID));
    }

    function exists(bytes32 ID) internal constant returns(bool) {
        if (IDs.length == 0) {
            return false;
        }
        TestParticipation memory savedValue = testParticipations[ID];
        uint savedIDindex = savedValue.IDindex;
        bytes32 savedID = IDs[savedIDindex];
        return ID == savedID;
    }

    function addTestParticipation(address studentID, uint testID) public {
        bytes32 ID = keccak256(studentID, testID);
        require(!exists(ID));

        testParticipations[ID].studentID = studentID;
        testParticipations[ID].testID = testID;
        testParticipations[ID].IDindex = IDs.length;
        IDs.push(ID);

        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address testDB = ContractProvider(MAN).contracts("testdb");
        
        StudentDB(studentDB).addTestParticipationID(studentID, ID);
        TestDB(testDB).addTestParticipationID(testID, ID);
    }

    function getTestParticipationAt(uint index) public constant returns(address studentID, uint testID) {
        return getTestParticipation(IDs[index]);
    }

    function getTestParticipation(bytes32 ID) internal constant returns(address studentID, uint testID) {
        require(exists(ID));
        return(testParticipations[ID].studentID, testParticipations[ID].testID);
    }
}
