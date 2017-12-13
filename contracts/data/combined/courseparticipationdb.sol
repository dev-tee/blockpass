pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../coursedb.sol";

// This contract is responsible for the n-to-n
// relationship between courses and students.
// It represents a student's participation in a course
// and provides functions to get, add and query for values.


contract CourseParticipationDB is ManagedContract {

    // This struct saves the relationship and
    // also holds a reference to its own id.
    struct CourseParticipation {
        address studentID;
        uint courseID;
        uint idIndex;
    }

    // This array holds all ids for the relationships.
    bytes32[] courseParticipationIDs;

    // This mapping holds all individual relationships.
    mapping(bytes32 => CourseParticipation) courseParticipations;

    // Check whether a relationship between
    // a given student and course already exists.
    function exists(address studentID, uint courseID) public constant returns(bool) {
        return exists(keccak256(studentID, courseID));
    }

    // Use the provided id to check whether it already exits in our database
    // by reading out the value it points to in our mapping.
    // The saved value should point to an id that is identical to the one
    // that was provided if we have actually saved this value beforehand.
    function exists(bytes32 id) internal constant returns(bool) {
        if (courseParticipationIDs.length == 0) {
            return false;
        }
        CourseParticipation memory savedValue = courseParticipations[id];
        uint savedIDIndex = savedValue.idIndex;
        bytes32 savedID = courseParticipationIDs[savedIDIndex];
        return id == savedID;
    }

    // Save a new relationship between a student and a course.
    function addCourseParticipation(address studentID, uint courseID) public {
        bytes32 id = keccak256(studentID, courseID);
        require(!exists(id));

        courseParticipations[id].studentID = studentID;
        courseParticipations[id].courseID = courseID;
        courseParticipations[id].idIndex = courseParticipationIDs.length;
        courseParticipationIDs.push(id);

        // Call the respective databases to save this
        // relationship's id for faster access.
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address courseDB = ContractProvider(MAN).contracts("coursedb");
        StudentDB(studentDB).addCourseParticipationID(studentID, id);
        CourseDB(courseDB).addCourseParticipationID(courseID, id);
    }

    // Get the student and course of the relationship at the index's position.
    function getCourseParticipationAt(uint index) public constant returns(address studentID, uint courseID) {
        return getCourseParticipation(courseParticipationIDs[index]);
    }

    // Use the provided id to find the relationship and return its values.
    function getCourseParticipation(bytes32 id) public constant returns(address studentID, uint courseID) {
        require(exists(id));
        return(courseParticipations[id].studentID, courseParticipations[id].courseID);
    }
}
