pragma solidity ^0.4.3;

import "./contractmanager.sol";
import "../data/combined/courseparticipationdb.sol";
import "../data/combined/testparticipationdb.sol";
import "../data/submissiondb.sol";
import "../data/coursedb.sol";
import "../data/testdb.sol";
import "../data/assignmentdb.sol";
import "../data/assessmentdb.sol";
import "../data/combined/studentsubmissiondb.sol";
import "../manager/datamanager.sol";

// This contract is responsible for all data
// that can be accessed by student accounts.


contract StudentManager is ManagedContract {

    // Modifier that ensures that only a registered
    // student account is calling the tagged function.
    modifier onlyStudent() {
        require(StudentDB(ContractProvider(MAN).contracts("studentdb"))
            .isStudent(msg.sender));
        _;
    }

    // Modifier that ensures that a student hasn't
    // already made a submission for a given test.
    modifier notSubmittedYet(uint testID) {
        var (numTestSubmissions, ) = getTestSubmissionIDs(testID);
        require(numTestSubmissions == 0);
        _;
    }

    // Modifier that ensures that a student can't
    // make a submission after the deadline.
    modifier inTime(uint referenceType, uint referenceID) {
        if (referenceType == 0) {
            var (, assignmentDueDate, assignmentCourseID) = AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
                                                            .getAssignment(referenceID);
            require(assignmentDueDate >= now);
        } else if (referenceType == 1) {
            var (, testDueDate, testCourseID) = TestDB(ContractProvider(MAN).contracts("testdb"))
                                                .getTest(referenceID);
            require(testDueDate >= now);
        }
        _;
    }

    // Modifier that ensures that the student accounts are
    // registered for the course the assignment belongs to.
    modifier containsOnlyParticipatingStudents(address[] accounts, uint assignmentID) {
        var (, assignmentCourseID) = AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
                                        .getAssignment(assignmentID);

        for(uint i = 0; i < accounts.length; ++i) {
            require(StudentDB(ContractProvider(MAN).contracts("studentdb"))
                    .isStudent(accounts[i])
                && CourseParticipationDB(ContractProvider(MAN).contracts("courseparticipationdb"))
                    .exists(accounts[i], assignmentCourseID));
        }
        _;
    }

    // Modifier that ensures that a given course exists.
    modifier courseExists(uint courseID) {
        require(CourseDB(ContractProvider(MAN).contracts("coursedb"))
            .exists(courseID));
        _;
    }

    // Modifier that ensures that a given test exists.
    modifier testExists(uint testID) {
        require(TestDB(ContractProvider(MAN).contracts("testdb"))
            .exists(testID));
        _;
    }

    // Modifier that ensures that a given assignment exists.
    modifier assignmentExists(uint assignmentID) {
        require(AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
            .exists(assignmentID));
        _;
    }

    // Modifier that ensures that a given submission exists.
    modifier submissionExists(uint submissionID) {
        require(SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
            .exists(submissionID));
        _;
    }

    // Modifier that ensures that a student is registered
    // for the course the assignment belongs to.
    modifier courseParticipationExists(uint assignmentID) {
        var (, assignmentCourseID) = AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
                                        .getAssignment(assignmentID);
        require(CourseParticipationDB(ContractProvider(MAN).contracts("courseparticipationdb"))
            .exists(msg.sender, assignmentCourseID));
        _;
    }

    // Modifier that ensures that a student is not registered
    // for this course yet.
    modifier courseParticipationDoesntExistYet(uint courseID) {
        require(!CourseParticipationDB(ContractProvider(MAN).contracts("courseparticipationdb"))
            .exists(msg.sender, courseID));
        _;
    }

    // Modifier that ensures that a student is registered for this test.
    modifier testParticipationExists(uint testID) {
        require(TestParticipationDB(ContractProvider(MAN).contracts("testparticipationdb"))
            .exists(msg.sender, testID));
        _;
    }

    // Modifier that ensures that a student is not registered
    // for this test yet.
    modifier testParticipationDoesntExistYet(uint testID) {
        require(!TestParticipationDB(ContractProvider(MAN).contracts("testparticipationdb"))
            .exists(msg.sender, testID));
        _;
    }

    // Register a student for a course.
    function registerForCourse(uint courseID) onlyStudent courseExists(courseID) courseParticipationDoesntExistYet(courseID) {
        CourseParticipationDB(ContractProvider(MAN).contracts("courseparticipationdb"))
            .addCourseParticipation(msg.sender, courseID);
    }

    // Register a student for a test.
    function registerForTest(uint testID) onlyStudent testExists(testID) testParticipationDoesntExistYet(testID) {
        TestParticipationDB(ContractProvider(MAN).contracts("testparticipationdb"))
            .addTestParticipation(msg.sender, testID);
    }

    // Upload a submission for an assignment with the option
    // to add students that collaborated on this submission.
    function uploadAssignmentSubmission(
        string description,
        uint assignmentID,
        address[] remainingGroupMembers
    )
        public
        onlyStudent
        assignmentExists(assignmentID)
        courseParticipationExists(assignmentID)
        containsOnlyParticipatingStudents(remainingGroupMembers, assignmentID)
    {
        uint submissionID = uploadSubmission(description, now, 0, assignmentID);

        // Link the submission to the other students as well.
        address studentsubmissiondb = ContractProvider(MAN).contracts("studentsubmissiondb");
        for (uint i = 0; i < remainingGroupMembers.length; ++i) {
            StudentSubmissionDB(studentsubmissiondb).addStudentSubmission(remainingGroupMembers[i], submissionID);
        }
    }

    // Upload a submission for a test.
    function uploadTestSubmission(
        string description,
        uint testID
    )
        public
        onlyStudent
        testExists(testID)
        testParticipationExists(testID)
        notSubmittedYet(testID)
    {
        uploadSubmission(description, now, 1, testID);
    }

    // Type-agnostic internal implementation of submission upload
    // that is called by the public upload functions.
    function uploadSubmission(
        string description,
        uint submittedDate,
        uint referenceType,
        uint referenceID
    )
        internal
        inTime(referenceType, referenceID)
        returns(uint submissionID)
    {
        submissionID = SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
                        .addSubmission(description, submittedDate, referenceType, referenceID);

        StudentSubmissionDB(ContractProvider(MAN).contracts("studentsubmissiondb"))
            .addStudentSubmission(msg.sender, submissionID);
    }

    // Get the information about a student's every submission for a specific assignment.
    function getAssignmentSubmissionIDs(uint assignmentID)
        public
        constant
        onlyStudent
        assignmentExists(assignmentID)
        returns (uint numAssignmentSubmissions, uint[] assignmentSubmissionIDs)
    {
        return getSubmissionIDs(0, assignmentID);
    }

    // Get the information about a student's every submission for a specific test.
    function getTestSubmissionIDs(uint testID)
        public
        constant
        onlyStudent
        testExists(testID)
        returns (uint numTestSubmissions, uint[] testSubmissionIDs)
    {
        return getSubmissionIDs(1, testID);
    }

    // Type-agnostic internal implementation of the function for getting
    // a student's every submission for a specific task - assignment, or test.
    //
    // The number of relevant values needs to be inferred from numReferencedSubmissions
    // since the array of ids is oversized because of some return value limitations.
    function getSubmissionIDs(uint referenceType, uint referenceID)
        internal
        constant
        returns (uint numReferencedSubmissions, uint[] ids)
    {
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");
        address studentdb = ContractProvider(MAN).contracts("studentdb");
        address studentsubmissiondb = ContractProvider(MAN).contracts("studentsubmissiondb");

        // Create an oversized array but provide a way
        // to check for the actual number of relevant values.
        uint totalSubmissions = StudentDB(studentdb).getNumStudentSubmissions(msg.sender);
        ids = new uint[](totalSubmissions);
        numReferencedSubmissions = 0;

        // Look through all submissions from the student and return the requested ones.
        for (uint i = 0; i < totalSubmissions; ++i) {
            bytes32 studentsubmissionID = StudentDB(studentdb).getStudentSubmissionIDAt(msg.sender, i);

            var (, submissionID) = StudentSubmissionDB(studentsubmissiondb).getStudentSubmission(studentsubmissionID);
            var (, submissionReferenceType, submissionReferenceID) = SubmissionDB(submissiondb).getSubmission(submissionID);

            if (submissionReferenceType == referenceType && submissionReferenceID == referenceID) {
                ids[numReferencedSubmissions] = submissionID;
                ++numReferencedSubmissions;
            }
        }
    }

    // Check whether a student has passed a specific course.
    function passedCourse(uint courseID)
        public
        constant
        onlyStudent
        courseExists(courseID)
        returns(bool)
    {
        return passedCourseAssignments(courseID) && passedCourseTests(courseID);
    }

    // Check whether a student has passed the assignment portion of a specific course.
    // Currently requires passing >=50% of the course's assignments.
    function passedCourseAssignments(uint courseID)
        internal
        constant
        returns(bool passed)
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");

        uint numAssignments = CourseDB(coursedb).getNumAssignments(courseID);
        uint numPassed = 0;

        if (numAssignments == 0) {
            passed = true;
        }

        for (uint i = 0; i < numAssignments; ++i) {
            uint assignmentID = CourseDB(coursedb).getAssignmentIDAt(courseID, i);

            if (passedAssignment(assignmentID)) {
                ++numPassed;
            }

            if (numPassed * 2 >= numAssignments) {
                passed = true;
                break;
            }
        }
    }

    // Check whether a student has passed the test portion of a specific course.
    // Currently requires passing >=50% of the course's tests.
    function passedCourseTests(uint courseID)
        internal
        constant
        returns(bool passed)
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");

        uint numTests = CourseDB(coursedb).getNumTests(courseID);
        uint numPassed = 0;

        if (numTests == 0) {
            passed = true;
        }

        for (uint j = 0; j < numTests; ++j) {
            uint testID = CourseDB(coursedb).getTestIDAt(courseID, j);

            if (passedTest(testID)) {
                ++numPassed;
            }

            if (numPassed * 2 >= numTests) {
                passed = true;
                break;
            }
        }
    }

    // Check whether a student has passed a specific assignment.
    // Currently requires having >=50% of the obtainable points.
    function passedAssignment(uint assignmentID)
        public
        constant
        onlyStudent
        assignmentExists(assignmentID)
        returns(bool passed)
    {
        var (/*description*/, maxPoints, /*dueDate*/, /*courseID*/) =
            AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
            .getAssignment(assignmentID);
        uint obtainedPoints = getAssignmentPerformance(assignmentID);

        if (obtainedPoints * 2 >= maxPoints) {
            passed = true;
        }
    }

    // Check whether a student has passed a specific test.
    // Currently requires having >=50% of the obtainable points.
    function passedTest(uint testID)
        public
        constant
        onlyStudent
        testExists(testID)
        returns(bool passed)
    {
        var (/*description*/, maxPoints, /*dueDate*/, /*courseID*/) =
            TestDB(ContractProvider(MAN).contracts("testdb"))
            .getTest(testID);
        uint obtainedPoints = getTestPerformance(testID);

        if (obtainedPoints * 2 >= maxPoints) {
            passed = true;
        }
    }

    // Get the student's performance - points obtained - for a specific assignment.
    function getAssignmentPerformance(uint assignmentID)
        public
        constant
        onlyStudent
        assignmentExists(assignmentID)
        returns(uint obtainedPoints)
    {
        address datamanager = ContractProvider(MAN).contracts("datamanager");

        var(numAssignmentSubmissions, assignmentSubmissionIDs) = getAssignmentSubmissionIDs(assignmentID);
        for (uint i = 0; i < numAssignmentSubmissions; ++i) {
            var (assessed, /* numPriorAssessments */, /* id */, assignmentObtainedPoints) = DataManager(datamanager).getAssessment(assignmentSubmissionIDs[i]);
            if (assessed && assignmentObtainedPoints > obtainedPoints) {
                obtainedPoints = assignmentObtainedPoints;
            }
        }
    }

    // Get the student's performance - points obtained - for a specific test.
    function getTestPerformance(uint testID)
        public
        constant
        onlyStudent
        testExists(testID)
        returns(uint obtainedPoints)
    {
        address datamanager = ContractProvider(MAN).contracts("datamanager");

        var(numTestSubmissions, testSubmissionIDs) = getTestSubmissionIDs(testID);
        for (uint i = 0; i < numTestSubmissions; ++i) {
            var (assessed, /* numPriorAssessments */, /* id */, testObtainedPoints) = DataManager(datamanager).getAssessment(testSubmissionIDs[i]);
            if (assessed && testObtainedPoints > obtainedPoints) {
                obtainedPoints = testObtainedPoints;
            }
        }
    }
}
