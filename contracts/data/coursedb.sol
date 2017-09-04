pragma solidity ^0.4.0;

import "../manager/contractmanager.sol";


contract CourseDB is ManagedContract {

    struct Course {
        bytes32 name;
        string description;
        uint ectsPoints;
        uint[] assignmentIDs;
        uint[] testIDs;
        uint[] courseParticipationIDs;
        uint[] courseSupervisionIDs;
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

    function addCourse(bytes32 name, string description, uint ectsPoints) public returns(uint id) {
        id = courses.length++;

        Course storage c = courses[id];
        c.name = name;
        c.description = description;
        c.ectsPoints = ectsPoints;
    }

    function getCourse(uint id) public constant returns(bytes32 name, string description, uint ectsPoints) {
        require(exists(id));
        return(courses[id].name, courses[id].description, courses[id].ectsPoints);
    }

    function getNumCourses() public constant returns(uint) {
        return courses.length;
    }

    function addCourseParticipationID(uint courseID, uint id) permission("courseparticipationdb") {
        require(exists(courseID));
        courses[courseID].courseParticipationIDs.push(id);
    }

    function getCourseParticipationAt(uint courseID, uint index) public constant returns(uint) {
        require(courseParticipationExists(courseID, index));
        return(courses[courseID].courseParticipationIDs[index]);
    }

    function getNumCourseParticipations(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].courseParticipationIDs.length;
    }

    function addCourseSupervisionID(uint courseID, uint id) permission("coursesupervisiondb") {
        require(exists(courseID));
        courses[courseID].courseSupervisionIDs.push(id);
    }

    function getCourseSupervisionAt(uint courseID, uint index) public constant returns(uint) {
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

    function getAssignmentAt(uint courseID, uint index) public constant returns(uint) {
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

    function getTestAt(uint courseID, uint index) public constant returns(uint) {
        require(testExists(courseID, index));
        return(courses[courseID].testIDs[index]);
    }

    function getNumTests(uint courseID) public constant returns(uint) {
        require(exists(courseID));
        return courses[courseID].testIDs.length;
    }
}
