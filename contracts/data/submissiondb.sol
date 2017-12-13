pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";
import "./assignmentdb.sol";
import "./testdb.sol";

// This contract is responsible for all submissions.
// It provides functions to get and add submissions
// as well as the ability to link them to
// students, assessments and assignments or tests.


contract SubmissionDB is ManagedContract {

    // This struct contains data that is relevant for a submission.
    // Additionally it has references to students, assessments and
    // either an assignments or a test.
    struct Submission {
        string description;
        uint submittedDate;
        uint ref; //0 - ASSIGNMENT; 1 - TEST
        uint referenceID;
        uint[] assessmentIDs;
        bytes32[] studentSubmissionIDs;
    }

    // For convenience all submissions are saved
    // in an array with the index as their id.
    Submission[] submissions;

    // Check whether a submission with a given id
    // - a simple index in this case - already exists.
    function exists(uint id) public constant returns(bool) {
        return submissions.length > id;
    }

    // Check whether a submission with a given id has
    // at least the given amount of connections to students.
    function studentSubmissionExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && submissions[id].studentSubmissionIDs.length > refIndex;
    }

    // Check whether a submission with a given id has
    // at least the given amount of connections to assessments.
    function assessmentExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && submissions[id].assessmentIDs.length > refIndex;
    }

    // Add a new submission to our contract.
    function addSubmission(
        string description,
        uint submittedDate,
        uint ref,
        uint referenceID
    )
        public
        returns(uint id)
    {
        id = submissions.length++;

        // Link the new submission's id to the corresponding assignment or test.
        if (ref == 0 ) { //ASSIGNMENT
            address assignmentDB = ContractProvider(MAN).contracts("assignmentdb");
            AssignmentDB(assignmentDB).addSubmissionID(referenceID, id);
        } else if (ref == 1) { //TEST
            address testDB = ContractProvider(MAN).contracts("testdb");
            TestDB(testDB).addSubmissionID(referenceID, id);
        }

        Submission storage submission = submissions[id];
        submission.description = description;
        submission.submittedDate = submittedDate;
        submission.ref = ref;
        submission.referenceID = referenceID;
    }

    // Get the data of a submission with a given id.
    function getSubmission(uint id)
        public
        constant
        returns(string description, uint submittedDate, uint ref, uint referenceID)
    {
        require(exists(id));
        return(submissions[id].description, submissions[id].submittedDate, submissions[id].ref, submissions[id].referenceID);
    }

    // Return the number of submissions saved in the contract.
    function getNumSubmissions() public constant returns(uint) {
        return submissions.length;
    }

    // Link a given submission to a student.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between submissions and students.
    function addStudentSubmissionID(uint submissionID, bytes32 id) permission("studentsubmissiondb") {
        require(exists(submissionID));
        submissions[submissionID].studentSubmissionIDs.push(id);
    }

    // Get the information about the connection between
    // a given submission and a student at the index's position.
    function getStudentSubmissionIDAt(uint submissionID, uint index) public constant returns(bytes32) {
        require(studentSubmissionExists(submissionID, index));
        return(submissions[submissionID].studentSubmissionIDs[index]);
    }

    // Return the number of connections a given submission has to students.
    function getNumStudentSubmissions(uint submissionID) public constant returns(uint) {
        require(exists(submissionID));
        return submissions[submissionID].studentSubmissionIDs.length;
    }

    // Link a given submission to an assessment.
    // This function can only be called by the contract
    // that is responsible for keeping track of 1-to-n
    // relationships between a submission and assessments.
    function addAssessmentID(uint submissionID, uint id) permission("assessmentdb") {
        require(exists(submissionID));
        submissions[submissionID].assessmentIDs.push(id);
    }

    // Get the information about the assessment at the
    // index's position that is connected to a given submission.
    function getAssessmentIDAt(uint submissionID, uint index) public constant returns(uint) {
        require(assessmentExists(submissionID, index));
        return(submissions[submissionID].assessmentIDs[index]);
    }

    // Return the number of connections a given submission has to assignments.
    function getNumAssessments(uint submissionID) public constant returns(uint) {
        require(exists(submissionID));
        return submissions[submissionID].assessmentIDs.length;
    }
}
