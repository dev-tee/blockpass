pragma solidity ^0.4.0;

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
        address supervisordb = ContractProvider(MAN).contracts("supervisordb");
        require(SupervisorDB(supervisordb).isSupervisor(msg.sender));
        _;
    }

    modifier courseExists(uint courseID) {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        require(CourseDB(coursedb).exists(courseID));
        _;
    }

    modifier submissionExists(uint submissionID) {
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");
        require(SubmissionDB(submissiondb).exists(submissionID));
        _;
    }

    modifier isOwnCourse(uint courseID) {
        /*address supervisordb = ContractProvider(MAN).contracts("supervisordb");*/
        /*address coursesupervisiondb = ContractProvider(MAN).contracts("coursesupervisiondb");*/

        bool supervision;
        /*uint numSupervisions = SupervisorDB(supervisordb).getNumCourseSupervisions(msg.sender);*/
        for (uint i = 0; i < SupervisorDB(ContractProvider(MAN).contracts("supervisordb")).getNumCourseSupervisions(msg.sender); ++i) {
            /*uint supervisionID = SupervisorDB(ContractProvider(MAN).contracts("supervisordb")).getCourseSupervisionAt(msg.sender, i);*/
            var (, supervisionCourseID) = CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb")).getCourseSupervision(SupervisorDB(ContractProvider(MAN).contracts("supervisordb")).getCourseSupervisionAt(msg.sender, i));
            if (courseID == supervisionCourseID) {
                supervision = true;
                break;
            }
        }
        require(supervision);
        _;
    }

    modifier referenceExists(uint referenceType, uint referenceID) {
        if (referenceType == 0) {
            /*address assignmentdb = ContractProvider(MAN).contracts("assignmentdb");*/
            require(AssignmentDB(ContractProvider(MAN).contracts("assignmentdb")).exists(referenceID));
        } else if (referenceType == 1) {
            /*address testdb = ContractProvider(MAN).contracts("testdb");*/
            require(TestDB(ContractProvider(MAN).contracts("testdb")).exists(referenceID));
        }
        _;
    }

    /// Create a new course named $(courseName) with a description, a number and a worth of $(courseECTSPoints) ECTS.
    function createCourse(
        bytes32 name,
        string description,
        uint ectsPoints,
        address[] supervisors
    )
        onlySupervisor
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        uint courseID = CourseDB(coursedb).addCourse(name, description, ectsPoints);

        address supervisordb = ContractProvider(MAN).contracts("supervisordb");
        address coursesupervisiondb = ContractProvider(MAN).contracts("coursesupervisiondb");
        for (uint i = 0; i < supervisors.length; ++i) {
            if (SupervisorDB(supervisordb).isSupervisor(supervisors[i])) {
                CourseSupervisionDB(coursesupervisiondb).addCourseSupervision(supervisors[i], courseID);
            }
        }
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
        uint dueDate,
        uint maxPoints,
        uint courseID,
        address[] supervisors
    )
        onlySupervisor
        isOwnCourse(courseID)
    {
        /*address testdb = ContractProvider(MAN).contracts("testdb");*/
        uint testID = TestDB(ContractProvider(MAN).contracts("testdb")).addTest(description, dueDate, maxPoints, courseID);

        address supervisordb = ContractProvider(MAN).contracts("supervisordb");
        address testsupervisiondb = ContractProvider(MAN).contracts("testsupervisiondb");
        for (uint i = 0; i < supervisors.length; ++i) {
            if (SupervisorDB(supervisordb).isSupervisor(supervisors[i])) {
                TestSupervisionDB(testsupervisiondb).addTestSupervision(supervisors[i], testID);
            }
        }
    }

    // TODO: implement actual check of userType
    function assessmentAllowed(uint submissionID) returns (bool supervision) {

        address coursedb = ContractProvider(MAN).contracts("coursedb");
        address testdb = ContractProvider(MAN).contracts("testdb");
        address testsupervisiondb = ContractProvider(MAN).contracts("testsupervisiondb");
        address coursesupervisiondb = ContractProvider(MAN).contracts("coursesupervisiondb");

        uint numSupervisions;
        var (, submissionReferenceType, submissionReferenceID) = SubmissionDB(ContractProvider(MAN).contracts("submissiondb")).getSubmission(submissionID);
        if (submissionReferenceType == 0) {
            var (, assignmentCourseID) = AssignmentDB(ContractProvider(MAN).contracts("assignmentdb")).getAssignment(submissionReferenceID);
            numSupervisions = CourseDB(coursedb).getNumCourseSupervisions(assignmentCourseID);
        } else if (submissionReferenceType == 1) {
            numSupervisions = TestDB(testdb).getNumTestSupervisions(submissionReferenceID);
        }
        for (uint i = 0; i < numSupervisions; ++i) {
            uint supervisionID = submissionReferenceType == 0 ? CourseDB(coursedb).getCourseSupervisionAt(assignmentCourseID, i) : TestDB(testdb).getTestSupervisionAt(submissionReferenceID, i);
            var (supervisionSupervisorID,) = submissionReferenceType == 0 ?  CourseSupervisionDB(coursesupervisiondb).getCourseSupervision(supervisionID) : TestSupervisionDB(testsupervisiondb).getTestSupervision(supervisionID);
            if (supervisionSupervisorID == msg.sender) {
                supervision = true;
                break;
            }
        }
    }

    function assess(string comment, uint obtainedPoints, uint submissionID)
        onlySupervisor
    {
        require(assessmentAllowed(submissionID));
        address assessmentdb = ContractProvider(MAN).contracts("assessmentdb");
        uint assessmentID = AssessmentDB(assessmentdb).addAssessment(comment, obtainedPoints, submissionID);

        address supervisorassessmentdb = ContractProvider(MAN).contracts("supervisorassessmentdb");
        SupervisorAssessmentDB(supervisorassessmentdb).addSupervisorAssessment(msg.sender, assessmentID);
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
                submissionID = AssignmentDB(assignmentdb).getSubmissionAt(referenceID, i);
                numAssessments = SubmissionDB(submissiondb).getNumAssessments(submissionID);
                ids[i] = submissionID;
                assessed[i] = numAssessments > 0 ? true : false;
            }
        } else if (referenceType == 1) {
            numSubmissions = TestDB(testdb).getNumSubmissions(referenceID);
            ids = new uint[](numSubmissions);
            assessed = new bool[](numSubmissions);
            for (uint k = 0; k < numSubmissions; ++k) {
                submissionID = AssignmentDB(assignmentdb).getSubmissionAt(referenceID, k);
                numAssessments = SubmissionDB(submissiondb).getNumAssessments(submissionID);
                ids[k] = submissionID;
                assessed[k] = numAssessments > 0 ? true : false;
            }
        }
    }
}
