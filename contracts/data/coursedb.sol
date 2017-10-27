pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";


contract CourseDB is ManagedContract {

    struct Course {
        string description;
        uint ectsPoints;
        string name;
        uint[] assignmentIDs;
        uint[] testIDs;
        bytes32[] courseParticipationIDs;
        bytes32[] courseSupervisionIDs;
    }

    Course[] courses;

    function exists(uint id) public constant returns(bool) {
        return courses.length > id;
    }

    function courseParticipationExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && courses[id].courseParticipationIDs.length > refIndex;
    }

    function courseSupervisionExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && courses[id].courseSupervisionIDs.length > refIndex;
    }

    function assignmentExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && courses[id].assignmentIDs.length > refIndex;
    }

    function testExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && courses[id].testIDs.length > refIndex;
    }

    function addCourse(string description, string name, uint ectsPoints) public returns(uint id) {
        id = courses.length++;

        Course storage c = courses[id];
        c.description = description;
        c.name = name;
        c.ectsPoints = ectsPoints;
    }

    function getCourse(uint id) public constant returns(string description, string name, uint ectsPoints) {
        require(exists(id));
        return(courses[id].description, courses[id].name, courses[id].ectsPoints);
    }

    function getNumCourses() public constant returns(uint) {
        return courses.length;
    }

    function addCourseParticipationID(uint courseID, bytes32 id) permission("courseparticipationdb") {
        require(exists(courseID));
        courses[courseID].courseParticipationIDs.push(id);
    }

    function getCourseParticipationIDAt(uint courseID, uint index) public constant returns(bytes32) {
        require(courseParticipationExists(courseID, index));
        return(courses[courseID].courseParticipationIDs[index]);
    }

    function getNumCourseParticipations(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].courseParticipationIDs.length;
    }

    function addCourseSupervisionID(uint courseID, bytes32 id) permission("coursesupervisiondb") {
        require(exists(courseID));
        courses[courseID].courseSupervisionIDs.push(id);
    }

    function getCourseSupervisionIDAt(uint courseID, uint index) public constant returns(bytes32) {
        require(courseSupervisionExists(courseID, index));
        return(courses[courseID].courseSupervisionIDs[index]);
    }

    function getNumCourseSupervisions(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].courseSupervisionIDs.length;
    }

    function addAssignmentID(uint courseID, uint id) permission("assignmentdb") {
        require(exists(courseID));
        courses[courseID].assignmentIDs.push(id);
    }

    function getAssignmentIDAt(uint courseID, uint index) public constant returns(uint) {
        require(assignmentExists(courseID, index));
        return(courses[courseID].assignmentIDs[index]);
    }

    function getNumAssignments(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].assignmentIDs.length;
    }

    function addTestID(uint courseID, uint id) permission("testdb") {
        require(exists(courseID));
        courses[courseID].testIDs.push(id);
    }

    function getTestIDAt(uint courseID, uint index) public constant returns(uint) {
        require(testExists(courseID, index));
        return(courses[courseID].testIDs[index]);
    }

    function getNumTests(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].testIDs.length;
    }
}
