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

// This contract is responsible for all data
// that can be accessed by either both
// student and supervisor accounts
// or by the general public.


contract DataManager is ManagedContract {

    // Modifier that ensures that only a registered account
    // - student or supervisor - can call the tagged function.
    modifier onlyRegistered() {
        require(SupervisorDB(ContractProvider(MAN).contracts("supervisordb"))
            .isSupervisor(msg.sender)
            || StudentDB(ContractProvider(MAN).contracts("studentdb"))
            .isStudent(msg.sender)
        );
        _;
    }

    // Modifier that ensures that a given submission exists.
    modifier submissionExists(uint submissionID) {
        require(SubmissionDB(ContractProvider(MAN).contracts("submissiondb"))
            .exists(submissionID));
        _;
    }

    // Return all courses.
    //
    // This might get really large if there are a lot of courses,
    // over time especially so.
    function getAllCourses()
        public
        constant
        returns (uint numCourses, uint[] ids, uint[] ectsPoints)
    {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        numCourses = CourseDB(coursedb).getNumCourses();

        ids = new uint[](numCourses);
        ectsPoints = new uint[](numCourses);

        for (uint i = 0; i < numCourses; ++i) {
            var (, courseECTSPoints) = CourseDB(coursedb).getCourse(i);

            ids[i] = i;
            ectsPoints[i] = courseECTSPoints;
        }
    }

    // Return all tests.
    //
    // This might get really large if there are a lot of tests,
    // over time especially so.
    function getAllTests()
        public
        constant
        returns (uint numTests, uint[] ids, uint[] courseIDs, uint[] dueDates)
    {
        address testdb = ContractProvider(MAN).contracts("testdb");
        numTests = TestDB(testdb).getNumTests();

        ids = new uint[](numTests);
        dueDates = new uint[](numTests);
        courseIDs = new uint[](numTests);

        for (uint i = 0; i < numTests; ++i) {
            var (, testDueDate, testCourseID) = TestDB(testdb).getTest(i);

            ids[i] = i;
            dueDates[i] = testDueDate;
            courseIDs[i] = testCourseID;
        }
    }

    // Return all assignments of a course.
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
            var (/*description*/, /*name*/, assignmentMaxPoints, assignmentDueDate, /*courseID*/) = 
                AssignmentDB(assignmentdb).getAssignment(assignmentID);

            ids[i] = assignmentID;
            maxPoints[i] = assignmentMaxPoints;
            dueDates[i] = assignmentDueDate;
        }
    }

    // Return all tests of a course.
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
            var (/*description*/, /*name*/, testMaxPoints, testDueDate, /*courseID*/) =
                TestDB(testdb).getTest(testID);

            ids[i] = testID;
            maxPoints[i] = testMaxPoints;
            dueDates[i] = testDueDate;
        }
    }

    // Get the information that is connected to a submission.
    // Includes the maximum of obtainable points for the corresponding assignment
    // as well as its due date and the submission time.
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
            (/*description*/, /*name*/, maxPoints, dueDate, /*courseID*/) = 
                AssignmentDB(ContractProvider(MAN).contracts("assignmentdb")).
                getAssignment(referenceID);
        } else if (referenceType == 1) {
            (/*description*/, /*name*/, maxPoints, dueDate, /*courseID*/) = 
                TestDB(ContractProvider(MAN).contracts("testdb")).
                getTest(referenceID);
        }

        submissionDate = submittedDate;
    }

    // Return all courses that the requesting account is associated with.
    // May be courses a student participates in or courses a supervisor oversees.
    function getPersonalCourses()
        public
        constant
        returns (uint numCourses, uint[] ids, uint[] ectsPoints)
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

        ectsPoints = new uint[](numCourses);

        for (uint k = 0; k < numCourses; ++k) {
            (, ectsPoints[k]) = CourseDB(coursedb).getCourse(ids[k]);
        }
    }

    // Return all tests that the requesting account is associated with.
    // May be tests a student signed up for or tests a supervisor oversees.
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

        // Depending on whether the message sender is a student or supervisor account
        // loop through all participations or supervisions of tests to get the ids.
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

        // Use the ids to finally get the test's information.
        for (uint k = 0; k < numTests; ++k) {
            (, maxPoints[k], dueDates[k], courseIDs[k]) = TestDB(testdb).getTest(ids[k]);
        }
    }

    // Get the best assessment for a specific submission.
    function getAssessment(uint submissionID)
        public
        constant
        submissionExists(submissionID)
        returns (bool assessed, uint numPriorAssessments, uint id, uint obtainedPoints)
    {
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");
        address assessmentdb = ContractProvider(MAN).contracts("assessmentdb");

        uint numAssessments = SubmissionDB(submissiondb).getNumAssessments(submissionID);
        if (numAssessments > 0) {

            // Save the very first assessment as the best one.
            id = SubmissionDB(submissiondb).getAssessmentIDAt(submissionID, 0);
            (, obtainedPoints,) = AssessmentDB(assessmentdb).getAssessment(id);

            // Iterate through the remaining assessments to find better ones.
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
}
