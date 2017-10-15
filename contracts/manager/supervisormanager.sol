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

    modifier containsOnlySupervisors(address[] accounts) {
        bool valid = true;
        address supervisordb = ContractProvider(MAN).contracts("supervisordb");

        for(uint i = 0; i < accounts.length; ++i) {
            if (!SupervisorDB(supervisordb).isSupervisor(accounts[i])) {
                valid = false;
                break;
            }
        }

        require(valid);
        _;
    }

    modifier courseExists(uint courseID) {
        require(CourseDB(ContractProvider(MAN).contracts("coursedb"))
            .exists(courseID));
        _;
    }

    modifier isOwnCourse(uint courseID) {
        require(CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb"))
            .exists(msg.sender, courseID));
        _;
    }

    event AssignmentID(uint id);
    event TestID(uint id);
    event TestDateCheck(uint duedate, uint current);
    event AssignmentDateCheck(uint duedate, uint current);
    modifier assessmentAllowed(uint submissionID) {
        var (, submissionReferenceType, submissionReferenceID) = SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
                                                                                    .getSubmission(submissionID);
        if (submissionReferenceType == 0) {
            var (, assignmentDueDate, assignmentCourseID) = AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
                                            .getAssignment(submissionReferenceID);
            AssignmentID(assignmentCourseID);
            require(assignmentDueDate <= now);
            AssignmentDateCheck(assignmentDueDate, now);
            require(CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb"))
                .exists(msg.sender, assignmentCourseID));
        } else if (submissionReferenceType == 1) {
            var (, testDueDate, testCourseID) = TestDB(ContractProvider(MAN).contracts("testdb"))
                                            .getTest(submissionReferenceID);
            TestID(testCourseID);
            require(testDueDate <= now);
            TestDateCheck(assignmentDueDate, now);
            require(TestSupervisionDB(ContractProvider(MAN).contracts("testsupervisiondb"))
                .exists(msg.sender, submissionReferenceID)
                || CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb"))
                .exists(msg.sender, testCourseID));
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
        public
        onlySupervisor
        containsOnlySupervisors(helpingSupervisors)
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        uint courseID = CourseDB(coursedb).addCourse(description, name, ectsPoints);

        address coursesupervisiondb = ContractProvider(MAN).contracts("coursesupervisiondb");
        for (uint i = 0; i < helpingSupervisors.length; ++i) {
            CourseSupervisionDB(coursesupervisiondb).addCourseSupervision(helpingSupervisors[i], courseID);
        }
        CourseSupervisionDB(coursesupervisiondb).addCourseSupervision(msg.sender, courseID);
    }

    function createAssignment(
        string description,
        uint maxPoints,
        uint dueDate,
        uint courseID
    )
        public
        onlySupervisor
        isOwnCourse(courseID)
    {
        AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
            .addAssignment(description, maxPoints, dueDate, courseID);
    }

    function createTest(
        string description,
        uint maxPoints,
        uint dueDate,
        uint courseID,
        address[] helpingSupervisors
    )
        public
        onlySupervisor
        isOwnCourse(courseID)
        containsOnlySupervisors(helpingSupervisors)
    {
        uint testID = TestDB(ContractProvider(MAN).contracts("testdb"))
            .addTest(description, maxPoints, dueDate, courseID);

        address testsupervisiondb = ContractProvider(MAN).contracts("testsupervisiondb");
        for (uint i = 0; i < helpingSupervisors.length; ++i) {
            TestSupervisionDB(testsupervisiondb).addTestSupervision(helpingSupervisors[i], testID);
        }
        TestSupervisionDB(testsupervisiondb).addTestSupervision(msg.sender, testID);
    }

    function assess(string description, uint obtainedPoints, uint submissionID)
        public
        onlySupervisor
        assessmentAllowed(submissionID)
    {
        uint assessmentID = AssessmentDB(ContractProvider(MAN).contracts("assessmentdb"))
            .addAssessment(description, obtainedPoints, submissionID);

        SupervisorAssessmentDB(ContractProvider(MAN).contracts("supervisorassessmentdb"))
            .addSupervisorAssessment(msg.sender, assessmentID);
    }

    function getAssignmentSubmissionIDs(uint assignmentID)
        public
        constant
        returns (uint numAssignmentSubmissions, uint[] ids, bool[] assessed)
    {
        return getSubmissionIDs(0, assignmentID);
    }

    function getTestSubmissionIDs(uint testID)
        public
        constant
        returns (uint numTestSubmissions, uint[] ids, bool[] assessed)
    {
        return getSubmissionIDs(1, testID);
    }

    function getSubmissionIDs(uint referenceType, uint referenceID)
        internal
        constant
        referenceExists(referenceType, referenceID)
        returns (uint numSubmissions, uint[] ids, bool[] assessed)
    {
        address testdb = ContractProvider(MAN).contracts("testdb");
        address assignmentdb = ContractProvider(MAN).contracts("assignmentdb");
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");

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
}
