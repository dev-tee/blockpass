pragma solidity ^0.4.0;

import "../manager/contractmanager.sol";
import "./coursedb.sol";


contract AssignmentDB is ManagedContract {

    struct Assignment {
        string description;
        uint dueDate;
        uint courseID;
        uint[] submissionIDs;
    }

    Assignment[] assignments;

    function exists(uint id) public constant returns(bool) {
        return assignments.length > id;
    }

    // Since a submission can reference a test or assignment
    // submissionIDs for either one are not continous.
    // Therefore check validity against last element.
    function submissionExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id)
            && assignments[id].submissionIDs[assignments[id].submissionIDs.length - 1] >= refIndex;
    }

    function addAssignment(string description, uint dueDate, uint courseID) public {
        address courseDB = ContractProvider(MAN).contracts("coursedb");
        CourseDB(courseDB).addAssignmentID(courseID, assignments.length);
        
        assignments[assignments.length].description = description;
        assignments[assignments.length].dueDate = dueDate;
        assignments[assignments.length].courseID = courseID;
        ++assignments.length;
    }

    function getAssignment(uint id) public constant returns(string description, uint dueDate, uint courseID) {
        require(exists(id));
        return(assignments[id].description, assignments[id].dueDate, assignments[id].courseID);
    }

    function addSubmissionID(uint assignmentID, uint id) permission("submissiondb") {
        require(exists(assignmentID));
        assignments[assignmentID].submissionIDs.push(id);
    }

    function getSubmissionAt(uint assignmentID, uint index) public constant returns(uint) {
        require(submissionExists(assignmentID, index));
        return(assignments[assignmentID].submissionIDs[index]);
    }

    function getNumSubmissions(uint assignmentID) public constant returns(uint) {
        require(exists(assignmentID));
        return assignments[assignmentID].submissionIDs.length;
    }
}
