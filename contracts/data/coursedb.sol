pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";

// This contract is responsible for all courses.
// It provides functions to get and add assessments
// as well as the ability to link them to
// supervisors, students, tests and assignments.


contract CourseDB is ManagedContract {

    // This struct contains data that is relevant for a course.
    // Additionally it has references to assignments, tests, students and supervisors.
    struct Course {
        string description;
        string name;
        uint ectsPoints;
        uint[] assignmentIDs;
        uint[] testIDs;
        bytes32[] courseParticipationIDs;
        bytes32[] courseSupervisionIDs;
    }

    // For convenience all courses are saved
    // in an array with the index as their id.
    Course[] courses;

    // Check whether a course with a given id
    // - a simple index in this case - already exists.
    function exists(uint id) public constant returns(bool) {
        return courses.length > id;
    }

    // Check whether a course with a given id has
    // at least the given amount of connections to students.
    function courseParticipationExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && courses[id].courseParticipationIDs.length > refIndex;
    }

    // Check whether a course with a given id has
    // at least the given amount of connections to supervisors.
    function courseSupervisionExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && courses[id].courseSupervisionIDs.length > refIndex;
    }

    // Check whether a course with a given id has
    // at least the given amount of connections to assignments.
    function assignmentExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && courses[id].assignmentIDs.length > refIndex;
    }

    // Check whether a course with a given id has
    // at least the given amount of connections to tests.
    function testExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && courses[id].testIDs.length > refIndex;
    }

    // Add a new course to our contract.
    function addCourse(string description, string name, uint ectsPoints) public returns(uint id) {
        id = courses.length++;

        Course storage c = courses[id];
        c.description = description;
        c.name = name;
        c.ectsPoints = ectsPoints;
    }

    // Get the data of a course with a given id.
    function getCourse(uint id) public constant returns(string description, string name, uint ectsPoints) {
        require(exists(id));
        return(courses[id].description, courses[id].name, courses[id].ectsPoints);
    }

    // Return the number of courses saved in the contract.
    function getNumCourses() public constant returns(uint) {
        return courses.length;
    }

    // Link a given course to a student.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between courses and students.
    function addCourseParticipationID(uint courseID, bytes32 id) permission("courseparticipationdb") {
        require(exists(courseID));
        courses[courseID].courseParticipationIDs.push(id);
    }

    // Get the information about the connection between
    // a given course and a student at the index's position.
    function getCourseParticipationIDAt(uint courseID, uint index) public constant returns(bytes32) {
        require(courseParticipationExists(courseID, index));
        return(courses[courseID].courseParticipationIDs[index]);
    }

    // Return the number of connections a given course has to students.
    function getNumCourseParticipations(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].courseParticipationIDs.length;
    }

    // Link a given course to a supervisor.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between courses and supervisors.
    function addCourseSupervisionID(uint courseID, bytes32 id) permission("coursesupervisiondb") {
        require(exists(courseID));
        courses[courseID].courseSupervisionIDs.push(id);
    }

    // Get the information about the connection between
    // a given course and a supervisor at the index's position.
    function getCourseSupervisionIDAt(uint courseID, uint index) public constant returns(bytes32) {
        require(courseSupervisionExists(courseID, index));
        return(courses[courseID].courseSupervisionIDs[index]);
    }

    // Return the number of connections a given course has to supervisors.
    function getNumCourseSupervisions(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].courseSupervisionIDs.length;
    }

    // Link a given course to a assignment.
    // This function can only be called by the contract
    // that is responsible for keeping track of 1-to-n
    // relationships between a course and assignments.
    function addAssignmentID(uint courseID, uint id) permission("assignmentdb") {
        require(exists(courseID));
        courses[courseID].assignmentIDs.push(id);
    }

    // Get the information about the assignment at the
    // index's position that is connected to a given course.
    function getAssignmentIDAt(uint courseID, uint index) public constant returns(uint) {
        require(assignmentExists(courseID, index));
        return(courses[courseID].assignmentIDs[index]);
    }

    // Return the number of connections a given course has to assignments.
    function getNumAssignments(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].assignmentIDs.length;
    }

    // Link a given course to a test.
    // This function can only be called by the contract
    // that is responsible for keeping track of 1-to-n
    // relationships between a course and tests.
    function addTestID(uint courseID, uint id) permission("testdb") {
        require(exists(courseID));
        courses[courseID].testIDs.push(id);
    }

    // Get the information about the test at the
    // index's position that is connected to a given course.
    function getTestIDAt(uint courseID, uint index) public constant returns(uint) {
        require(testExists(courseID, index));
        return(courses[courseID].testIDs[index]);
    }

    // Return the number of connections a given course has to tests.
    function getNumTests(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].testIDs.length;
    }
}
