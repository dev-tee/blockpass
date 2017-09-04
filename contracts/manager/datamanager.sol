pragma solidity ^0.4.0;

import "./contractmanager.sol";
import "../data/coursedb.sol";
import "../data/testdb.sol";
import "../data/assignmentdb.sol";
import "../data/studentdb.sol";
import "../data/supervisordb.sol";
import "../data/combined/courseparticipationdb.sol";
import "../data/combined/coursesupervisiondb.sol";


contract DataManager is ManagedContract {

    function getAllCourses() constant returns (uint[] ids, bytes32[] names, uint[] ectsPoints) {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        uint numCourses = CourseDB(coursedb).getNumCourses();

        ids = new uint[](numCourses);
        names = new bytes32[](numCourses);
        ectsPoints = new uint[](numCourses);

        for (uint i = 0; i < numCourses; ++i) {
            var (courseName, courseDescription, courseECTSPoints) = CourseDB(coursedb).getCourse(i);

            ids[i] = i;
            names[i] = courseName;
            ectsPoints[i] = courseECTSPoints;
        }
    }

    function getAllTests() constant returns (uint[] ids, bytes32[] courseNames, uint[] dueDates) {
        address testdb = ContractProvider(MAN).contracts("testdb");
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        uint numTests = TestDB(testdb).getNumTests();

        ids = new uint[](numTests);
        courseNames = new bytes32[](numTests);
        dueDates = new uint[](numTests);

        for (uint i = 0; i < numTests; ++i) {
            var (testDescription, testDueDate, testMaxPoints, testCourseID) = TestDB(testdb).getTest(i);
            var (courseName, courseDescription, courseECTSPoints) = CourseDB(coursedb).getCourse(testCourseID);

            ids[i] = i;
            courseNames[i] = courseName;
            dueDates[i] = testDueDate;
        }
    }

    function getCourseAssignments(uint courseID) constant returns (uint[] ids, uint[] dueDates, uint[] maxPoints) {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        address assignmentdb = ContractProvider(MAN).contracts("assignmentdb");
        uint numAssignments = CourseDB(coursedb).getNumAssignments(courseID);

        ids = new uint[](numAssignments);
        dueDates = new uint[](numAssignments);
        maxPoints = new uint[](numAssignments);

        for (uint i = 0; i < numAssignments; ++i) {
            uint assignmentID = CourseDB(coursedb).getAssignmentAt(courseID, i);
            var (assignmentDescription, assignmentDueDate, assignmentMaxPoints, assignmentCourseID) = AssignmentDB(assignmentdb).getAssignment(assignmentID);

            ids[i] = assignmentID;
            dueDates[i] = assignmentDueDate;
            maxPoints[i] = assignmentMaxPoints;
        }
    }

    function getCourseTests(uint courseID) constant returns (uint[] ids, uint[] dueDates, uint[] maxPoints) {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        address testdb = ContractProvider(MAN).contracts("testdb");
        uint numTests = CourseDB(coursedb).getNumTests(courseID);

        ids = new uint[](numTests);
        dueDates = new uint[](numTests);
        maxPoints = new uint[](numTests);

        for (uint i = 0; i < numTests; ++i) {
            uint testID = CourseDB(coursedb).getTestAt(courseID, i);
            var (testDescription, testDueDate, testMaxPoints, testCourseID) = TestDB(testdb).getTest(testID);

            ids[i] = testID;
            dueDates[i] = testDueDate;
            maxPoints[i] = testMaxPoints;
        }
    }

    modifier restrictCourseIDs(uint[] ids) {
        /*address studentdb = ContractProvider(MAN).contracts("studentdb");*/
        /*address supervisordb = ContractProvider(MAN).contracts("supervisordb");*/
        /*address courseparticipationdb = ContractProvider(MAN).contracts("courseparticipationdb");*/
        /*address coursesupervisiondb = ContractProvider(MAN).contracts("coursesupervisiondb");*/

        if (StudentDB(ContractProvider(MAN).contracts("studentdb")).isStudent(msg.sender)) {
            /*uint numParticipations = StudentDB(ContractProvider(MAN).contracts("studentdb")).getNumCourseParticipations(msg.sender);*/
            ids = new uint[](StudentDB(ContractProvider(MAN).contracts("studentdb")).getNumCourseParticipations(msg.sender));
            for (uint i = 0; i < StudentDB(ContractProvider(MAN).contracts("studentdb")).getNumCourseParticipations(msg.sender); ++i) {
                /*uint participationID = StudentDB(ContractProvider(MAN).contracts("studentdb")).getCourseParticipationAt(msg.sender, i);*/
                var (, participationCourseID) = CourseParticipationDB(ContractProvider(MAN).contracts("courseparticipationdb")).getCourseParticipation(StudentDB(ContractProvider(MAN).contracts("studentdb")).getCourseParticipationAt(msg.sender, i));
                ids[i] = participationCourseID;
            }

        } else if (SupervisorDB(ContractProvider(MAN).contracts("supervisordb")).isSupervisor(msg.sender)) {
            /*uint numSupervisions = SupervisorDB(ContractProvider(MAN).contracts("supervisordb")).getNumCourseSupervisions(msg.sender);*/
            ids = new uint[](SupervisorDB(ContractProvider(MAN).contracts("supervisordb")).getNumCourseSupervisions(msg.sender));
            for (uint j = 0; j < SupervisorDB(ContractProvider(MAN).contracts("supervisordb")).getNumCourseSupervisions(msg.sender); ++j) {
                /*uint supervisionID = SupervisorDB(ContractProvider(MAN).contracts("supervisordb")).getCourseSupervisionAt(msg.sender, j);*/
                var (, supervisionCourseID) = CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb")).getCourseSupervision(SupervisorDB(ContractProvider(MAN).contracts("supervisordb")).getCourseSupervisionAt(msg.sender, j));
                ids[j] = supervisionCourseID;
            }
        }
        _;
    }

    function getPersonalCourses() constant restrictCourseIDs(ids) returns (uint[] ids, bytes32[] names, uint[] ectsPoints) {
        /*address coursedb = ContractProvider(MAN).contracts("coursedb");*/

        uint numCourses = ids.length;
        names = new bytes32[](numCourses);
        ids = new uint[](numCourses);

        for (uint k = 0; k < numCourses; ++k) {
            var (courseName, courseDescription, courseECTSPoints) = CourseDB(ContractProvider(MAN).contracts("coursedb")).getCourse(ids[k]);

            names[k] = courseName;
            ectsPoints[k] = courseECTSPoints;
        }
    }


}
