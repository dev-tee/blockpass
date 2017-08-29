pragma solidity ^0.4.0;

import "../manager/contractmanager.sol";
import "./assignmentdb.sol";
import "./testdb.sol";


contract SubmissionDB is ManagedContract {

    struct Submission {
        string description;
        uint submittedDate;
        uint ref; //0 - ASSIGNMENT; 1 - TEST
        uint referenceID;
        uint[] assessmentIDs;
        uint[] studentSubmissionIDs;
    }

    Submission[] submissions;

    function exists(uint id) public constant returns(bool) {
        return submissions.length > id;
    }

    function studentSubmissionExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && submissions[id].studentSubmissionIDs.length > refIndex;
    }

    function assessmentExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && submissions[id].assessmentIDs.length > refIndex;
    }

    function addSubmission(string description, uint submittedDate, uint ref, uint referenceID) public {
        if (ref == 0 ) { //ASSIGNMENT
            address assignmentDB = ContractProvider(MAN).contracts("assignmentdb");
            AssignmentDB(assignmentDB).addSubmissionID(referenceID, submissions.length);
        } else if (ref == 1) { //TEST
            address testDB = ContractProvider(MAN).contracts("testdb");
            TestDB(testDB).addSubmissionID(referenceID, submissions.length);
        }

        Submission storage submission = submissions[submissions.length++];
        submission.description = description;
        submission.submittedDate = submittedDate;
        submission.ref = ref;
        submission.referenceID = referenceID;
    }

    function getSubmission(uint id) public constant returns(string description, uint submittedDate, uint ref, uint referenceID) {
        require(exists(id));
        return(submissions[id].description, submissions[id].submittedDate, submissions[id].ref, submissions[id].referenceID);
    }

    function getNumSubmissions() public constant returns(uint) {
        return submissions.length;
    }

    function addStudentSubmissionID(uint submissionID, uint id) permission("studentsubmissiondb") {
        require(exists(submissionID));
        submissions[submissionID].studentSubmissionIDs.push(id);
    }

    function getStudentSubmissionAt(uint submissionID, uint index) public constant returns(uint) {
        require(studentSubmissionExists(submissionID, index));
        return(submissions[submissionID].studentSubmissionIDs[index]);
    }

    function getNumStudentSubmissions(uint submissionID) public constant returns(uint) {
        require(exists(submissionID));
        return submissions[submissionID].studentSubmissionIDs.length;
    }

    function addAssessmentID(uint submissionID, uint id) permission("assessmentdb") {
        require(exists(submissionID));
        submissions[submissionID].assessmentIDs.push(id);
    }

    function getAssessmentAt(uint submissionID, uint index) public constant returns(uint) {
        require(assessmentExists(submissionID, index));
        return(submissions[submissionID].assessmentIDs[index]);
    }

    function getNumAssessments(uint submissionID) public constant returns(uint) {
        require(exists(submissionID));
        return submissions[submissionID].assessmentIDs.length;
    }
}
