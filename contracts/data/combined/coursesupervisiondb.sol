pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../supervisordb.sol";
import "../coursedb.sol";

// This contract is responsible for the n-to-n
// relationship between courses and supervisors.
// It represents a supervisors's supervision of a course
// and provides functions to get, add and query for values.


contract CourseSupervisionDB is ManagedContract {

    // This struct saves the relationship and
    // also holds a reference to its own id.
    struct CourseSupervision {
        address supervisorID;
        uint courseID;
        uint idIndex;
    }

    // This array holds all ids for the relationships.
    bytes32[] courseSupervisionIDs;

    // This mapping holds all individual relationships.
    mapping(bytes32 => CourseSupervision) courseSupervisions;

    // Check whether a relationship between
    // a given supervisor and course already exists.
    function exists(address supervisorID, uint courseID) public constant returns(bool) {
        return exists(keccak256(supervisorID, courseID));
    }

    // Use the provided id to check whether it already exits in our database
    // by reading out the value it points to in our mapping.
    // The saved value should point to an id that is identical to the one
    // that was provided if we have actually saved this value beforehand.
    function exists(bytes32 id) internal constant returns(bool) {
        if (courseSupervisionIDs.length == 0) {
            return false;
        }
        CourseSupervision memory savedValue = courseSupervisions[id];
        uint savedIDindex = savedValue.idIndex;
        bytes32 savedID = courseSupervisionIDs[savedIDindex];
        return id == savedID;
    }

    // Save a new relationship between a supervisor and a course.
    function addCourseSupervision(address supervisorID, uint courseID) public {
        bytes32 id = keccak256(supervisorID, courseID);
        require(!exists(id));

        courseSupervisions[id].supervisorID = supervisorID;
        courseSupervisions[id].courseID = courseID;
        courseSupervisions[id].idIndex = courseSupervisionIDs.length;
        courseSupervisionIDs.push(id);

        // Call the respective databases to save this
        // relationship's id for faster access.
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address courseDB = ContractProvider(MAN).contracts("coursedb");
        SupervisorDB(supervisorDB).addCourseSupervisionID(supervisorID, id);
        CourseDB(courseDB).addCourseSupervisionID(courseID, id);
    }

    // Get the supervisor and course of the relationship at the index's position.
    function getCourseSupervisionAt(uint index) public constant returns(address supervisorID, uint courseID) {
        return getCourseSupervision(courseSupervisionIDs[index]);
    }

    // Use the provided id to find the relationship and return its values.
    function getCourseSupervision(bytes32 id) public constant returns(address supervisorID, uint courseID) {
        require(exists(id));
        return(courseSupervisions[id].supervisorID, courseSupervisions[id].courseID);
    }
}
