pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../submissiondb.sol";

// This contract is responsible for the n-to-n
// relationship between submissions and students.
// It represents a student's contribution to a submission
// and provides functions to get, add and query for values.


contract StudentSubmissionDB is ManagedContract {

    // This struct saves the relationship and
    // also holds a reference to its own id.
    struct StudentSubmission {
        address studentID;
        uint submissionID;
        uint idIndex;
    }

    // This array holds all ids for the relationships.
    bytes32[] studentSubmissionIDs;

    // This mapping holds all individual relationships.
    mapping(bytes32 => StudentSubmission) studentSubmissions;

    // Check whether a relationship between
    // a given student and submission already exists.
    function exists(address studentID, uint submissionID) public constant returns(bool) {
        return exists(keccak256(studentID, submissionID));
    }

    // Use the provided id to check whether it already exits in our database
    // by reading out the value it points to in our mapping.
    // The saved value should point to an id that is identical to the one
    // that was provided if we have actually saved this value beforehand.
    function exists(bytes32 id) internal constant returns(bool) {
        if (studentSubmissionIDs.length == 0) {
            return false;
        }
        StudentSubmission memory savedValue = studentSubmissions[id];
        uint savedIDindex = savedValue.idIndex;
        bytes32 savedID = studentSubmissionIDs[savedIDindex];
        return id == savedID;
    }

    // Save a new relationship between a student and a submission.
    function addStudentSubmission(address studentID, uint submissionID) public {
        bytes32 id = keccak256(studentID, submissionID);
        require(!exists(id));

        studentSubmissions[id].studentID = studentID;
        studentSubmissions[id].submissionID = submissionID;
        studentSubmissions[id].idIndex = studentSubmissionIDs.length;
        studentSubmissionIDs.push(id);

        // Call the respective databases to save this
        // relationship's id for faster access.
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address submissionDB = ContractProvider(MAN).contracts("submissiondb");
        StudentDB(studentDB).addStudentSubmissionID(studentID, id);
        SubmissionDB(submissionDB).addStudentSubmissionID(submissionID, id);
    }

    // Get the student and submission of the relationship at the index's position.
    function getStudentSubmissionAt(uint index) public constant returns(address studentID, uint submissionID) {
        return getStudentSubmission(studentSubmissionIDs[index]);
    }

    // Use the provided id to find the relationship and return its values.
    function getStudentSubmission(bytes32 id) public constant returns(address studentID, uint submissionID) {
        require(exists(id));
        return(studentSubmissions[id].studentID, studentSubmissions[id].submissionID);
    }
}
