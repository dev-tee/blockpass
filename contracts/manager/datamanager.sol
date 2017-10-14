pragma solidity ^0.4.3;

import "./contractmanager.sol";
import "../data/coursedb.sol";
import "../data/testdb.sol";
import "../data/assignmentdb.sol";
import "../data/submissiondb.sol";
import "../data/assessmentdb.sol";
import "../data/studentdb.sol";
import "../data/supervisordb.sol";
import "../data/combined/courseparticipationdb.sol";
import "../data/combined/testparticipationdb.sol";
import "../data/combined/coursesupervisiondb.sol";
import "../data/combined/testsupervisiondb.sol";


contract DataManager is ManagedContract {

    modifier onlyRegistered() {
        require(SupervisorDB(ContractProvider(MAN).contracts("supervisordb"))
            .isSupervisor(msg.sender)
            || StudentDB(ContractProvider(MAN).contracts("studentdb"))
            .isStudent(msg.sender)
        );
        _;
    }

    modifier submissionExists(uint submissionID) {
        require(SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
            .exists(submissionID));
        _;
    }

    function getAllCourses()
        public
        constant
        returns (uint numCourses, uint[] ids, bytes32[] courseNames, uint[] ectsPoints)
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        numCourses = CourseDB(coursedb).getNumCourses();

        ids = new uint[](numCourses);
        courseNames = new bytes32[](numCourses);
        ectsPoints = new uint[](numCourses);

        for (uint i = 0; i < numCourses; ++i) {
            var (, courseName, courseECTSPoints) = CourseDB(coursedb).getCourse(i);

            ids[i] = i;
            courseNames[i] = courseName;
            ectsPoints[i] = courseECTSPoints;
        }
    }

    function getAllTests()
        public
        constant
        returns (uint numTests, uint[] ids, bytes32[] courseNames, uint[] dueDates)
    {
        address testdb = ContractProvider(MAN).contracts("testdb");
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        numTests = TestDB(testdb).getNumTests();

        ids = new uint[](numTests);
        courseNames = new bytes32[](numTests);
        dueDates = new uint[](numTests);

        for (uint i = 0; i < numTests; ++i) {
            var (, testDueDate, testCourseID) = TestDB(testdb).getTest(i);
            var (, courseName,) = CourseDB(coursedb).getCourse(testCourseID);

            ids[i] = i;
            courseNames[i] = courseName;
            dueDates[i] = testDueDate;
        }
    }

    function getCourseAssignments(uint courseID)
        public
        constant
        returns (uint numAssignments, uint[] ids, uint[] maxPoints, uint[] dueDates)
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        address assignmentdb = ContractProvider(MAN).contracts("assignmentdb");
        numAssignments = CourseDB(coursedb).getNumAssignments(courseID);

        ids = new uint[](numAssignments);
        dueDates = new uint[](numAssignments);
        maxPoints = new uint[](numAssignments);

        for (uint i = 0; i < numAssignments; ++i) {
            uint assignmentID = CourseDB(coursedb).getAssignmentIDAt(courseID, i);
            var (, assignmentMaxPoints, assignmentDueDate,) = AssignmentDB(assignmentdb).getAssignment(assignmentID);

            ids[i] = assignmentID;
            maxPoints[i] = assignmentMaxPoints;
            dueDates[i] = assignmentDueDate;
        }
    }

    function getCourseTests(uint courseID)
        public
        constant
        returns (uint numTests, uint[] ids, uint[] maxPoints, uint[] dueDates)
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        address testdb = ContractProvider(MAN).contracts("testdb");
        numTests = CourseDB(coursedb).getNumTests(courseID);

        ids = new uint[](numTests);
        dueDates = new uint[](numTests);
        maxPoints = new uint[](numTests);

        for (uint i = 0; i < numTests; ++i) {
            uint testID = CourseDB(coursedb).getTestIDAt(courseID, i);
            var (, testMaxPoints, testDueDate,) = TestDB(testdb).getTest(testID);

            ids[i] = testID;
            maxPoints[i] = testMaxPoints;
            dueDates[i] = testDueDate;
        }
    }

    function getSubmissionRelatedInfo(uint submissionID)
        public
        constant
        onlyRegistered
        submissionExists(submissionID)
        returns (uint maxPoints, uint submissionDate, uint dueDate)
    {
        var (, submittedDate, referenceType, referenceID) = SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
                                                .getSubmission(submissionID);
        if (referenceType == 0) {
            (, maxPoints, dueDate,) = AssignmentDB(ContractProvider(MAN).contracts("assignmentdb")).
                                        getAssignment(referenceID);
        } else if (referenceType == 1) {
            (, maxPoints, dueDate,) = TestDB(ContractProvider(MAN).contracts("testdb")).
                                        getTest(referenceID);
        }

        submissionDate = submittedDate;
    }

    function getPersonalCourses()
        public
        constant
        returns (uint numCourses, uint[] ids, bytes32[] names, uint[] ectsPoints)
    {
        address studentdb = ContractProvider(MAN).contracts("studentdb");
        address supervisordb = ContractProvider(MAN).contracts("supervisordb");
        address courseparticipationdb = ContractProvider(MAN).contracts("courseparticipationdb");
        address coursesupervisiondb = ContractProvider(MAN).contracts("coursesupervisiondb");
        address coursedb = ContractProvider(MAN).contracts("coursedb");

        if (StudentDB(studentdb).isStudent(msg.sender)) {
            numCourses = StudentDB(studentdb).getNumCourseParticipations(msg.sender);
            ids = new uint[](numCourses);
            for (uint i = 0; i < numCourses; ++i) {
                bytes32 participationID = StudentDB(studentdb).getCourseParticipationIDAt(msg.sender, i);
                (, ids[i]) = CourseParticipationDB(courseparticipationdb).getCourseParticipation(participationID);
            }
        } else if (SupervisorDB(supervisordb).isSupervisor(msg.sender)) {
            numCourses = SupervisorDB(supervisordb).getNumCourseSupervisions(msg.sender);
            ids = new uint[](numCourses);
            for (uint j = 0; j < numCourses; ++j) {
                bytes32 supervisionID = SupervisorDB(supervisordb).getCourseSupervisionIDAt(msg.sender, j);
                (, ids[j]) = CourseSupervisionDB(coursesupervisiondb).getCourseSupervision(supervisionID);
            }
        }

        names = new bytes32[](numCourses);
        ectsPoints = new uint[](numCourses);

        for (uint k = 0; k < numCourses; ++k) {
            (, names[k], ectsPoints[k]) = CourseDB(coursedb).getCourse(ids[k]);
        }
    }

    function getPersonalTests()
        public
        constant
        returns (uint numTests, uint[] ids, uint[] maxPoints, uint[] dueDates, uint[] courseIDs)
    {
        address studentdb = ContractProvider(MAN).contracts("studentdb");
        address supervisordb = ContractProvider(MAN).contracts("supervisordb");
        address testparticipationdb = ContractProvider(MAN).contracts("testparticipationdb");
        address testsupervisiondb = ContractProvider(MAN).contracts("testsupervisiondb");
        address testdb = ContractProvider(MAN).contracts("testdb");

        if (StudentDB(studentdb).isStudent(msg.sender)) {
            numTests = StudentDB(studentdb).getNumTestParticipations(msg.sender);
            ids = new uint[](numTests);
            for (uint i = 0; i < numTests; ++i) {
                bytes32 participationID = StudentDB(studentdb).getTestParticipationIDAt(msg.sender, i);
                (, ids[i]) = TestParticipationDB(testparticipationdb).getTestParticipation(participationID);
            }
        } else if (SupervisorDB(supervisordb).isSupervisor(msg.sender)) {
            numTests = SupervisorDB(supervisordb).getNumTestSupervisions(msg.sender);
            ids = new uint[](numTests);
            for (uint j = 0; j < numTests; ++j) {
                bytes32 supervisionID = SupervisorDB(supervisordb).getTestSupervisionIDAt(msg.sender, j);
                (, ids[j]) = TestSupervisionDB(testsupervisiondb).getTestSupervision(supervisionID);
            }
        }

        maxPoints = new uint[](numTests);
        dueDates = new uint[](numTests);
        courseIDs = new uint[](numTests);

        for (uint k = 0; k < numTests; ++k) {
            (, maxPoints[k], dueDates[k], courseIDs[k]) = TestDB(testdb).getTest(ids[k]);
        }
    }

}
