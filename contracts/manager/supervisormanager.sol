pragma solidity ^0.4.3;

import "./contractmanager.sol";
import "../data/coursedb.sol";
import "../data/assignmentdb.sol";
import "../data/testdb.sol";
import "../data/assessmentdb.sol";
import "../data/combined/coursesupervisiondb.sol";
import "../data/combined/testsupervisiondb.sol";
import "../data/combined/supervisorassessmentdb.sol";

// This contract is responsible for all data
// that can be accessed by supervisor accounts.

contract SupervisorManager is ManagedContract {

    // Modifier that ensures that only a registered
    // supervisor account is calling the tagged function.
    modifier onlySupervisor() {
        require(SupervisorDB(ContractProvider(MAN).contracts("supervisordb"))
            .isSupervisor(msg.sender));
        _;
    }

    // Modifier that ensures that all the accounts are supervisor accounts.
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

    // Modifier that ensures that a supervisor is
    // actually responsible for a specific course.
    modifier isOwnCourse(uint courseID) {
        require(CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb"))
            .exists(msg.sender, courseID));
        _;
    }

    // Modifier that ensures that a supervisor is
    // actually allowed to assess a submission
    // by ensuring that the supervisors is actually
    // in charge of the test, assignment or course.
    // It is also only possible after the deadline
    // has passed.
    modifier assessmentAllowed(uint submissionID) {
        var (, submissionReferenceType, submissionReferenceID) = SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
                                                                                    .getSubmission(submissionID);
        if (submissionReferenceType == 0) {
            var (, assignmentDueDate, assignmentCourseID) = AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
                                            .getAssignment(submissionReferenceID);
            require(assignmentDueDate <= now);
            require(CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb"))
                .exists(msg.sender, assignmentCourseID));
        } else if (submissionReferenceType == 1) {
            var (, testDueDate, testCourseID) = TestDB(ContractProvider(MAN).contracts("testdb"))
                                            .getTest(submissionReferenceID);
            require(testDueDate <= now);
            require(TestSupervisionDB(ContractProvider(MAN).contracts("testsupervisiondb"))
                .exists(msg.sender, submissionReferenceID)
                || CourseSupervisionDB(ContractProvider(MAN).contracts("coursesupervisiondb"))
                .exists(msg.sender, testCourseID));
        }
        _;
    }

    // Modifier that ensures that the referenced task
    // - assignment or test - actually exists.
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

    // Create a new course with the option to add
    // other supervisors that oversee the course.
    function createCourse(
        string description,
        string name,
        uint ectsPoints,
        address[] helpingSupervisors
    )
        public
        onlySupervisor
        containsOnlySupervisors(helpingSupervisors)
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        uint courseID = CourseDB(coursedb).addCourse(description, name, ectsPoints);

        // Link the course to the other supervisors as well.
        address coursesupervisiondb = ContractProvider(MAN).contracts("coursesupervisiondb");
        for (uint i = 0; i < helpingSupervisors.length; ++i) {
            CourseSupervisionDB(coursesupervisiondb).addCourseSupervision(helpingSupervisors[i], courseID);
        }
        CourseSupervisionDB(coursesupervisiondb).addCourseSupervision(msg.sender, courseID);
    }

    // Create a new assignment for a specific course.
    function createAssignment(
        string description,
        string name,
        uint maxPoints,
        uint dueDate,
        uint courseID
    )
        public
        onlySupervisor
        isOwnCourse(courseID)
    {
        AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
            .addAssignment(description, name, maxPoints, dueDate, courseID);
    }

    // Create a new test for a specific course with the option
    // to add other supervisors that oversee the test.
    function createTest(
        string description,
        string name,
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
            .addTest(description, name, maxPoints, dueDate, courseID);

        // Link the test to the other supervisors as well.
        address testsupervisiondb = ContractProvider(MAN).contracts("testsupervisiondb");
        for (uint i = 0; i < helpingSupervisors.length; ++i) {
            TestSupervisionDB(testsupervisiondb).addTestSupervision(helpingSupervisors[i], testID);
        }
        TestSupervisionDB(testsupervisiondb).addTestSupervision(msg.sender, testID);
    }

    // Create an assessment - points obtained and text - for a specific submission.
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

    // Get the information about all submissions for a specific assignment.
    function getAssignmentSubmissionIDs(uint assignmentID)
        public
        constant
        returns (uint numAssignmentSubmissions, uint[] ids, bool[] assessed)
    {
        return getSubmissionIDs(0, assignmentID);
    }

    // Get the information about all submissions for a specific test.
    function getTestSubmissionIDs(uint testID)
        public
        constant
        returns (uint numTestSubmissions, uint[] ids, bool[] assessed)
    {
        return getSubmissionIDs(1, testID);
    }

    // Type-agnostic internal implementation of the function for getting
    // all submission for a specific task - assignment, or test.
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

        // Depending on the referenced type, loop through either all assignments or all tests
        // and return all submissions as well as whether they have already been assessed.
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
