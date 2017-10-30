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


contract StudentManager is ManagedContract {

    modifier onlyStudent() {
        require(StudentDB(ContractProvider(MAN).contracts("studentdb"))
            .isStudent(msg.sender));
        _;
    }

    modifier notSubmittedYet(uint testID) {
        var (numTestSubmissions, ) = getTestSubmissionIDs(testID);
        require(numTestSubmissions == 0);
        _;
    }

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

    modifier courseExists(uint courseID) {
        require(CourseDB(ContractProvider(MAN).contracts("coursedb"))
            .exists(courseID));
        _;
    }

    modifier testExists(uint testID) {
        require(TestDB(ContractProvider(MAN).contracts("testdb"))
            .exists(testID));
        _;
    }

    modifier assignmentExists(uint assignmentID) {
        require(AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
            .exists(assignmentID));
        _;
    }

    modifier submissionExists(uint submissionID) {
        require(SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
            .exists(submissionID));
        _;
    }

    modifier courseParticipationExists(uint assignmentID) {
        var (, assignmentCourseID) = AssignmentDB(ContractProvider(MAN).contracts("assignmentdb"))
                                        .getAssignment(assignmentID);
        require(CourseParticipationDB(ContractProvider(MAN).contracts("courseparticipationdb"))
            .exists(msg.sender, assignmentCourseID));
        _;
    }

    modifier testParticipationExists(uint testID) {
        require(TestParticipationDB(ContractProvider(MAN).contracts("testparticipationdb"))
            .exists(msg.sender, testID));
        _;
    }

    function registerForCourse(uint courseID) onlyStudent courseExists(courseID) {
        CourseParticipationDB(ContractProvider(MAN).contracts("courseparticipationdb"))
            .addCourseParticipation(msg.sender, courseID);
    }

    function registerForTest(uint testID) onlyStudent testExists(testID) {
        TestParticipationDB(ContractProvider(MAN).contracts("testparticipationdb"))
            .addTestParticipation(msg.sender, testID);
    }

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

        address studentsubmissiondb = ContractProvider(MAN).contracts("studentsubmissiondb");
        for (uint i = 0; i < remainingGroupMembers.length; ++i) {
            StudentSubmissionDB(studentsubmissiondb).addStudentSubmission(remainingGroupMembers[i], submissionID);
        }
    }

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

    function getAssignmentSubmissionIDs(uint assignmentID)
        public
        constant
        onlyStudent
        assignmentExists(assignmentID)
        returns (uint numAssignmentSubmissions, uint[] assignmentSubmissionIDs)
    {
        return getSubmissionIDs(0, assignmentID);
    }

    function getTestSubmissionIDs(uint testID)
        public
        constant
        onlyStudent
        testExists(testID)
        returns (uint numTestSubmissions, uint[] testSubmissionIDs)
    {
        return getSubmissionIDs(1, testID);
    }

    function getSubmissionIDs(uint referenceType, uint referenceID)
        internal
        constant
        returns (uint numReferencedSubmissions, uint[] ids)
    {
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");
        address studentdb = ContractProvider(MAN).contracts("studentdb");
        address studentsubmissiondb = ContractProvider(MAN).contracts("studentsubmissiondb");

        uint totalSubmissions = StudentDB(studentdb).getNumStudentSubmissions(msg.sender);
        ids = new uint[](totalSubmissions);
        numReferencedSubmissions = 0;

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

    function getAssessment(uint submissionID)
        public
        constant
        onlyStudent
        submissionExists(submissionID)
        returns (bool assessed, uint numPriorAssessments, uint id, uint obtainedPoints)
    {
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");
        address assessmentdb = ContractProvider(MAN).contracts("assessmentdb");

        uint numAssessments = SubmissionDB(submissiondb).getNumAssessments(submissionID);
        if (numAssessments > 0) {
            id = SubmissionDB(submissiondb).getAssessmentIDAt(submissionID, 0);
            (, obtainedPoints,) = AssessmentDB(assessmentdb).getAssessment(id);

            for (uint i = 1; i < numAssessments; ++i) {
                uint assessmentID = SubmissionDB(submissiondb).getAssessmentIDAt(submissionID, i);
                var (, assessmentObtainedPoints,) = AssessmentDB(assessmentdb).getAssessment(assessmentID);

                if (assessmentObtainedPoints > obtainedPoints) {
                    obtainedPoints = assessmentObtainedPoints;
                    id = assessmentID;
                }
            }

            assessed = true;
            numPriorAssessments = numAssessments - 1;

            var (, assessmentSubmissionID) = AssessmentDB(assessmentdb).getAssessment(id);
            assert(assessmentSubmissionID == submissionID);
        }
    }

    function passedCourse(uint courseID)
        public
        constant
        onlyStudent
        courseExists(courseID)
        returns(bool)
    {
        return passedCourseAssignments(courseID) && passedCourseTests(courseID);
    }

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

    function getAssignmentPerformance(uint assignmentID)
        public
        constant
        onlyStudent
        assignmentExists(assignmentID)
        returns(uint obtainedPoints)
    {
        var(numAssignmentSubmissions, assignmentSubmissionIDs) = getAssignmentSubmissionIDs(assignmentID);
        for (uint i = 0; i < numAssignmentSubmissions; ++i) {
            var (assessed, /* numPriorAssessments */, /* id */, assignmentObtainedPoints) = getAssessment(assignmentSubmissionIDs[i]);
            if (assessed && assignmentObtainedPoints > obtainedPoints) {
                obtainedPoints = assignmentObtainedPoints;
            }
        }
    }

    function getTestPerformance(uint testID)
        public
        constant
        onlyStudent
        testExists(testID)
        returns(uint obtainedPoints)
    {
        var(numTestSubmissions, testSubmissionIDs) = getTestSubmissionIDs(testID);
        for (uint i = 0; i < numTestSubmissions; ++i) {
            var (assessed, /* numPriorAssessments */, /* id */, testObtainedPoints) = getAssessment(testSubmissionIDs[i]);
            if (assessed && testObtainedPoints > obtainedPoints) {
                obtainedPoints = testObtainedPoints;
            }
        }
    }
}
