pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";
import "./coursedb.sol";

// This contract is responsible for all assignments.
// It provides functions to get and add assignments
// as well as the ability to link them to submissions.


contract AssignmentDB is ManagedContract {

    // This struct contains data that is relevant for an assignment.
    // Additionally it has references to submissions and a course.
    struct Assignment {
        string description;
        string name;
        uint maxPoints;
        uint dueDate;
        uint courseID;
        uint[] submissionIDs;
    }

    // For convenience all assignments are saved
    // in an array with the index as their id.
    Assignment[] assignments;

    // Check whether an assignment with a given id
    // - a simple index in this case - already exists.
    function exists(uint id) public constant returns(bool) {
        return assignments.length > id;
    }

    // Check whether an assignment with a given id has
    // at least the given amount of connections to submissions.
    //
    // Since a submission can reference a test or assignment
    // submissionIDs for either one are not continous.
    // However, they are sorted in increasing order.
    // Therefore check validity against last element.
    function submissionExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && assignments[id].submissionIDs[assignments[id].submissionIDs.length - 1] >= refIndex;
    }

    // Add a new assignment to our contract.
    function addAssignment(
        string description,
        string name,
        uint maxPoints,
        uint dueDate,
        uint courseID
    )
        public
        returns(uint id)
    {
        id = assignments.length++;

        // Link the new assignment's id to the corresponding course.
        address courseDB = ContractProvider(MAN).contracts("coursedb");
        CourseDB(courseDB).addAssignmentID(courseID, id);

        Assignment storage assignment = assignments[id];
        assignment.description = description;
        assignment.name = name;
        assignment.maxPoints = maxPoints;
        assignment.dueDate = dueDate;
        assignment.courseID = courseID;
    }

    // Get the data of an assignment with a given id.
    function getAssignment(uint id)
        public
        constant
        returns(string description, string name, uint maxPoints, uint dueDate, uint courseID)
    {
        require(exists(id));
        return(assignments[id].description, assignments[id].name, assignments[id].maxPoints, assignments[id].dueDate, assignments[id].courseID);
    }

    // Return the number of assignments saved in the contract.
    function getNumAssignments() public constant returns(uint) {
        return assignments.length;
    }

    // Link a given assignment to a submission.
    // This function can only be called by the contract
    // that is responsible for keeping track of 1-to-n
    // relationships between an assignment and submissions.
    function addSubmissionID(uint assignmentID, uint id) permission("submissiondb") {
        require(exists(assignmentID));
        assignments[assignmentID].submissionIDs.push(id);
    }

    // Get the information about the submission at the
    // index's position that is connected to a given assignment.
    function getSubmissionIDAt(uint assignmentID, uint index) public constant returns(uint) {
        require(submissionExists(assignmentID, index));
        return(assignments[assignmentID].submissionIDs[index]);
    }

    // Return the number of connections a given assignment has to submissions.
    function getNumSubmissions(uint assignmentID) public constant returns(uint) {
        require(exists(assignmentID));
        return assignments[assignmentID].submissionIDs.length;
    }
}
