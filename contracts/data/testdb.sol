pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";
import "./coursedb.sol";


contract TestDB is ManagedContract {

    struct Test {
        string description;
        uint maxPoints;
        uint dueDate;
        uint courseID;
        uint[] submissionIDs;
        bytes32[] testParticipationIDs;
        bytes32[] testSupervisionIDs;
    }

    Test[] tests;

    function exists(uint id) public constant returns(bool) {
        return tests.length > id;
    }

    function testParticipationExists(uint id, uint referenceIndex) public constant returns(bool) {
        return exists(id) && tests[id].testParticipationIDs.length > referenceIndex;
    }

    function testSupervisionExists(uint id, uint referenceIndex) public constant returns(bool) {
        return exists(id) && tests[id].testSupervisionIDs.length > referenceIndex;
    }

    // Since a submission can reference a test or assignment
    // submissionIDs for either one are not continous.
    // Therefore check validity against last element.
    function submissionExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && tests[id].submissionIDs[tests[id].submissionIDs.length - 1] >= refIndex;
    }

    function addTest(
        string description,
        uint maxPoints,
        uint dueDate,
        uint courseID
    )
        public
        returns(uint id)
    {
        id = tests.length++;

        address courseDB = ContractProvider(MAN).contracts("coursedb");
        CourseDB(courseDB).addTestID(courseID, id);

        Test storage test = tests[id];
        test.description = description;
        test.maxPoints = maxPoints;
        test.dueDate = dueDate;
        test.courseID = courseID;
    }

    function getTest(uint id) public constant returns(string description, uint maxPoints, uint dueDate, uint courseID) {
        require(exists(id));
        return(tests[id].description, tests[id].maxPoints, tests[id].dueDate, tests[id].courseID);
    }

    function getNumTests() public constant returns(uint) {
        return tests.length;
    }

    function addTestParticipationID(uint testID, bytes32 id) permission("testparticipationdb") {
        require(exists(testID));
        tests[testID].testParticipationIDs.push(id);
    }

    function getTestParticipationIDAt(uint testID, uint index) public constant returns(bytes32) {
        require(testParticipationExists(testID, index));
        return(tests[testID].testParticipationIDs[index]);
    }

    function getNumTestParticipations(uint testID) public constant returns(uint) {
        require(exists(testID));
        return tests[testID].testParticipationIDs.length;
    }

    function addTestSupervisionID(uint testID, bytes32 id) permission("testsupervisiondb") {
        require(exists(testID));
        tests[testID].testSupervisionIDs.push(id);
    }

    function getTestSupervisionIDAt(uint testID, uint index) public constant returns(bytes32) {
        require(testSupervisionExists(testID, index));
        return(tests[testID].testSupervisionIDs[index]);
    }

    function getNumTestSupervisions(uint testID) public constant returns(uint) {
        require(exists(testID));
        return tests[testID].testSupervisionIDs.length;
    }

    function addSubmissionID(uint testID, uint id) permission("submissiondb") {
        require(exists(testID));
        tests[testID].submissionIDs.push(id);
    }

    function getSubmissionIDAt(uint testID, uint index) public constant returns(uint) {
        require(submissionExists(testID, index));
        return(tests[testID].submissionIDs[index]);
    }

    function getNumSubmissions(uint testID) public constant returns(uint) {
        require(exists(testID));
        return tests[testID].submissionIDs.length;
    }
}
