pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";
import "./coursedb.sol";

// This contract is responsible for all tests.
// It provides functions to get and add tests
// as well as the ability to link them to
// supervisors, students and submissions.


contract TestDB is ManagedContract {

    // This struct contains data that is relevant for a test.
    // Additionally it has references to supervisors, students, submissions and a course.
    struct Test {
        string description;
        uint maxPoints;
        uint dueDate;
        uint courseID;
        uint[] submissionIDs;
        bytes32[] testParticipationIDs;
        bytes32[] testSupervisionIDs;
    }

    // For convenience all tests are saved
    // in an array with the index as their id.
    Test[] tests;

    // Check whether a test with a given id
    // - a simple index in this case - already exists.
    function exists(uint id) public constant returns(bool) {
        return tests.length > id;
    }

    // Check whether a test with a given id has
    // at least the given amount of connections to students.
    function testParticipationExists(uint id, uint referenceIndex) public constant returns(bool) {
        return exists(id) && tests[id].testParticipationIDs.length > referenceIndex;
    }

    // Check whether a test with a given id has
    // at least the given amount of connections to supervisors.
    function testSupervisionExists(uint id, uint referenceIndex) public constant returns(bool) {
        return exists(id) && tests[id].testSupervisionIDs.length > referenceIndex;
    }

    // Check whether a test with a given id has
    // at least the given amount of connections to submissions.
    //
    // Since a submission can reference a test or assignment
    // submissionIDs for either one are not continous.
    // Therefore check validity against last element.
    function submissionExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && tests[id].submissionIDs[tests[id].submissionIDs.length - 1] >= refIndex;
    }

    // Add a new test to our contract.
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

        // Link the new test's id to the corresponding course.
        address courseDB = ContractProvider(MAN).contracts("coursedb");
        CourseDB(courseDB).addTestID(courseID, id);

        Test storage test = tests[id];
        test.description = description;
        test.maxPoints = maxPoints;
        test.dueDate = dueDate;
        test.courseID = courseID;
    }

    // Get the data of a test with a given id.
    function getTest(uint id) public constant returns(string description, uint maxPoints, uint dueDate, uint courseID) {
        require(exists(id));
        return(tests[id].description, tests[id].maxPoints, tests[id].dueDate, tests[id].courseID);
    }

    // Return the number of tests saved in the contract.
    function getNumTests() public constant returns(uint) {
        return tests.length;
    }

    // Link a given test to a student.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between tests and students.
    function addTestParticipationID(uint testID, bytes32 id) permission("testparticipationdb") {
        require(exists(testID));
        tests[testID].testParticipationIDs.push(id);
    }

    // Get the information about the connection between
    // a given test and a student at the index's position.
    function getTestParticipationIDAt(uint testID, uint index) public constant returns(bytes32) {
        require(testParticipationExists(testID, index));
        return(tests[testID].testParticipationIDs[index]);
    }

    // Return the number of connections a given test has to students.
    function getNumTestParticipations(uint testID) public constant returns(uint) {
        require(exists(testID));
        return tests[testID].testParticipationIDs.length;
    }

    // Link a given test to a supervisor.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between tests and supervisors.
    function addTestSupervisionID(uint testID, bytes32 id) permission("testsupervisiondb") {
        require(exists(testID));
        tests[testID].testSupervisionIDs.push(id);
    }

    // Get the information about the connection between
    // a given test and a supervisor at the index's position.
    function getTestSupervisionIDAt(uint testID, uint index) public constant returns(bytes32) {
        require(testSupervisionExists(testID, index));
        return(tests[testID].testSupervisionIDs[index]);
    }

    // Return the number of connections a given test has to supervisors.
    function getNumTestSupervisions(uint testID) public constant returns(uint) {
        require(exists(testID));
        return tests[testID].testSupervisionIDs.length;
    }

    // Link a given test to a submission.
    // This function can only be called by the contract
    // that is responsible for keeping track of 1-to-n
    // relationships between an test and submissions.
    function addSubmissionID(uint testID, uint id) permission("submissiondb") {
        require(exists(testID));
        tests[testID].submissionIDs.push(id);
    }

    // Get the information about the submission at the
    // index's position that is connected to a given test.
    function getSubmissionIDAt(uint testID, uint index) public constant returns(uint) {
        require(submissionExists(testID, index));
        return(tests[testID].submissionIDs[index]);
    }

    // Return the number of connections a given test has to submissions.
    function getNumSubmissions(uint testID) public constant returns(uint) {
        require(exists(testID));
        return tests[testID].submissionIDs.length;
    }
}
