pragma solidity ^0.4.3;

import "./contractmanager.sol";
import "../data/coursedb.sol";
import "../data/assignmentdb.sol";
import "../data/testdb.sol";
import "../data/assessmentdb.sol";
import "../data/combined/coursesupervisiondb.sol";
import "../data/combined/testsupervisiondb.sol";
import "../data/combined/supervisorassessmentdb.sol";


contract SupervisorManager is ManagedContract {

    modifier onlySupervisor() {
        require(SupervisorDB(ContractProvider(MAN).contracts("supervisordb"))
            .isSupervisor(msg.sender));
        _;
    }

    modifier courseExists(uint courseID) {
        require(CourseDB(ContractProvider(MAN).contracts("coursedb"))
            .exists(courseID));
        _;
    }

    modifier submissionExists(uint submissionID) {
        require(SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
            .exists(submissionID));
        _;
    }

    modifier isOwnCourse(uint courseID) {
        require(CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb"))
            .exists(msg.sender, courseID));
        _;
    }


    modifier assessmentAllowed(uint submissionID) {
        var (, submissionReferenceType, submissionReferenceID) = SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
                                                                    .getSubmission(submissionID);
        if (submissionReferenceType == 0) {
            var (, assignmentCourseID) = AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
                                            .getAssignment(submissionReferenceID);
            require(CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb"))
                .exists(msg.sender, assignmentCourseID));
        } else if (submissionReferenceType == 1) {
            require(TestSupervisionDB(ContractProvider(MAN).contracts("testsupervisiondb"))
                .exists(msg.sender, submissionReferenceID));
        }
        _;
    }

    modifier referenceExists(uint referenceType, uint referenceID) {
        if (referenceType == 0) {
            require(AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
                .exists(referenceID));
        } else if (referenceType == 1) {
            require(TestDB(ContractProvider(MAN).contracts("testdb"))
                .exists(referenceID));
        }
        _;
    }

    /// Create a new course named $(courseName) with a description, a number and a worth of $(courseECTSPoints) ECTS.
    function createCourse(
        string description,
        bytes32 name,
        uint ectsPoints,
        address[] helpingSupervisors
    )
        onlySupervisor
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        uint courseID = CourseDB(coursedb).addCourse(description, name, ectsPoints);

        address supervisordb = ContractProvider(MAN).contracts("supervisordb");
        address coursesupervisiondb = ContractProvider(MAN).contracts("coursesupervisiondb");
        for (uint i = 0; i < helpingSupervisors.length; ++i) {
            if (SupervisorDB(supervisordb).isSupervisor(helpingSupervisors[i])) {
                CourseSupervisionDB(coursesupervisiondb).addCourseSupervision(helpingSupervisors[i], courseID);
            }
        }
        CourseSupervisionDB(coursesupervisiondb).addCourseSupervision(msg.sender, courseID);
    }

    function createAssignment(
        string description,
        uint dueDate,
        uint maxPoints,
        uint courseID
    )
        onlySupervisor
        isOwnCourse(courseID)
    {
        address assignmentdb = ContractProvider(MAN).contracts("assignmentdb");
        AssignmentDB(assignmentdb).addAssignment(description, dueDate, maxPoints, courseID);
    }

    function createTest(
        string description,
        uint maxPoints,
        uint dueDate,
        uint courseID,
        address[] helpingSupervisors
    )
        onlySupervisor
        isOwnCourse(courseID)
    {
        uint testID = TestDB(ContractProvider(MAN).contracts("testdb"))
            .addTest(description, maxPoints, dueDate, courseID);

        address supervisordb = ContractProvider(MAN).contracts("supervisordb");
        address testsupervisiondb = ContractProvider(MAN).contracts("testsupervisiondb");
        for (uint i = 0; i < helpingSupervisors.length; ++i) {
            if (SupervisorDB(supervisordb).isSupervisor(helpingSupervisors[i])) {
                TestSupervisionDB(testsupervisiondb).addTestSupervision(helpingSupervisors[i], testID);
            }
        }
        TestSupervisionDB(testsupervisiondb).addTestSupervision(msg.sender, testID);
    }

    function assess(string description, uint obtainedPoints, uint submissionID)
        onlySupervisor
        assessmentAllowed(submissionID)
    {
        uint assessmentID = AssessmentDB(ContractProvider(MAN).contracts("assessmentdb"))
            .addAssessment(description, obtainedPoints, submissionID);

        SupervisorAssessmentDB(ContractProvider(MAN).contracts("supervisorassessmentdb"))
            .addSupervisorAssessment(msg.sender, assessmentID);
    }

    function getAssignmentSubmissionIDs(uint assignmentID)
        constant
        returns (uint[] ids, bool[] assessed)
    {
        return getSubmissionIDs(0, assignmentID);
    }

    function getTesttSubmissionIDs(uint testID)
        constant
        returns (uint[] ids, bool[] assessed)
    {
        return getSubmissionIDs(1, testID);
    }

    function getSubmissionIDs(uint referenceType, uint referenceID)
        constant
        referenceExists(referenceType, referenceID)
        returns (uint[] ids, bool[] assessed)
    {
        address testdb = ContractProvider(MAN).contracts("testdb");
        address assignmentdb = ContractProvider(MAN).contracts("assignmentdb");
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");

        uint numSubmissions;
        uint numAssessments;
        uint submissionID;
        if (referenceType == 0) {
            numSubmissions = AssignmentDB(assignmentdb).getNumSubmissions(referenceID);
            ids = new uint[](numSubmissions);
            assessed = new bool[](numSubmissions);
            for (uint i = 0; i < numSubmissions; ++i) {
                submissionID = AssignmentDB(assignmentdb).getSubmissionIDAt(referenceID, i);
                numAssessments = SubmissionDB(submissiondb).getNumAssessments(submissionID);
                ids[i] = submissionID;
                assessed[i] = numAssessments > 0 ? true : false;
            }
        } else if (referenceType == 1) {
            numSubmissions = TestDB(testdb).getNumSubmissions(referenceID);
            ids = new uint[](numSubmissions);
            assessed = new bool[](numSubmissions);
            for (uint k = 0; k < numSubmissions; ++k) {
                submissionID = TestDB(testdb).getSubmissionIDAt(referenceID, k);
                numAssessments = SubmissionDB(submissiondb).getNumAssessments(submissionID);
                ids[k] = submissionID;
                assessed[k] = numAssessments > 0 ? true : false;
            }
        }
    }

    function getPersonalSupervisorCourses()
        constant
        onlySupervisor
        returns (uint numCourses, uint[] ids, bytes32[] names, uint[] ectsPoints)
    {
        address supervisordb = ContractProvider(MAN).contracts("supervisordb");
        address coursesupervisiondb = ContractProvider(MAN).contracts("coursesupervisiondb");
        address coursedb = ContractProvider(MAN).contracts("coursedb");

        numCourses = SupervisorDB(supervisordb).getNumCourseSupervisions(msg.sender);

        ids = new uint[](numCourses);
        names = new bytes32[](numCourses);
        ectsPoints = new uint[](numCourses);

        for (uint j = 0; j < numCourses; ++j) {
            bytes32 supervisionID = SupervisorDB(supervisordb).getCourseSupervisionIDAt(msg.sender, j);
            var (, supervisionCourseID) = CourseSupervisionDB(coursesupervisiondb).getCourseSupervision(supervisionID);
            var (, courseName, courseECTSPoints) = CourseDB(coursedb).getCourse(supervisionCourseID);

            ids[j] = supervisionCourseID;
            names[j] = courseName;
            ectsPoints[j] = courseECTSPoints;
        }
    }
}
