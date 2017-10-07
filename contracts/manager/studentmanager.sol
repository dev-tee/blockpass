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

    function registerForCourse(uint courseID) onlyStudent courseExists(courseID) {
        CourseParticipationDB(ContractProvider(MAN).contracts("courseparticipationdb"))
            .addCourseParticipation(msg.sender, courseID);
    }

    function registerForTest(uint testID) onlyStudent testExists(testID) {
        TestParticipationDB(ContractProvider(MAN).contracts("testparticipationdb"))
            .addTestParticipation(msg.sender, testID);
    }

    function uploadSubmission(
        string description,
        uint submittedDate,
        uint referenceType,
        uint referenceID,
        address[] remainingGroupMembers
    )
        onlyStudent
        referenceExists(referenceType, referenceID)
    {
        uint submissionID = SubmissionDB(ContractProvider(MAN).contracts("submissiondb")).addSubmission(
            description,
            submittedDate,
            referenceType,
            referenceID
        );

        address studentdb = ContractProvider(MAN).contracts("studentdb");
        address studentsubmissiondb = ContractProvider(MAN).contracts("studentsubmissiondb");
        for (uint i = 0; i < remainingGroupMembers.length; ++i) {
            if (StudentDB(studentdb).isStudent(remainingGroupMembers[i])) {
                StudentSubmissionDB(studentsubmissiondb).addStudentSubmission(remainingGroupMembers[i], submissionID);
            }
        }
        StudentSubmissionDB(studentsubmissiondb).addStudentSubmission(msg.sender, submissionID);
    }

    function getAssignmentSubmissions(uint assignmentID)
        public
        constant
        assignmentExists(assignmentID)
        onlyStudent
        returns (uint count, uint[] assignmentSubmissionIDs)
    {
        return getSubmissions(0, assignmentID);
    }

    function getTestSubmissions(uint testID)
        public
        constant
        testExists(testID)
        onlyStudent
        returns (uint count, uint[] testSubmissionIDs)
    {
        return getSubmissions(1, testID);
    }

    function getSubmissions(uint referenceType, uint referenceID)
        internal
        constant
        returns (uint count, uint[] ids)
    {
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");
        address studentdb = ContractProvider(MAN).contracts("studentdb");
        address studentsubmissiondb = ContractProvider(MAN).contracts("studentsubmissiondb");

        uint numSubmissions = StudentDB(studentdb).getNumStudentSubmissions(msg.sender);
        count = 0;
        ids = new uint[](numSubmissions);

        for (uint i = 0; i < numSubmissions; ++i) {
            bytes32 studentsubmissionID = StudentDB(studentdb).getStudentSubmissionIDAt(msg.sender, i);
            var (, submissionID) = StudentSubmissionDB(studentsubmissiondb).getStudentSubmission(studentsubmissionID);
            var (, submissionReferenceType, submissionReferenceID) = SubmissionDB(submissiondb).getSubmission(submissionID);
            if (submissionReferenceType == referenceType && submissionReferenceID == referenceID) {
                ids[count] = submissionID;
                ++count;
            }
        }
    }

    function getAssessment(uint submissionID)
        constant
        onlyStudent
        submissionExists(submissionID)
        returns (bool assessed, uint numPriorAssessments, uint id, uint obtainedPoints)
    {
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");
        address assessmentdb = ContractProvider(MAN).contracts("assessmentdb");

        uint numAssessments = SubmissionDB(submissiondb).getNumAssessments(submissionID);
        if (numAssessments > 0) {
            uint assessmentID = SubmissionDB(submissiondb).getAssessmentIDAt(submissionID, numAssessments - 1);
            var (, assessmentObtainedPoints, assessmentSubmissionID) = AssessmentDB(assessmentdb).getAssessment(assessmentID);

            id = assessmentID;
            obtainedPoints = assessmentObtainedPoints;
            assessed = true;
            numPriorAssessments = numAssessments - 1;

            assert(assessmentSubmissionID == submissionID);
        }
    }

    function getStudentCourses()
        constant
        onlyStudent
        returns (uint numCourses, uint[] ids, bytes32[] names, uint[] ectsPoints)
    {
        address studentdb = ContractProvider(MAN).contracts("studentdb");
        address courseparticipationdb = ContractProvider(MAN).contracts("courseparticipationdb");
        address coursedb = ContractProvider(MAN).contracts("coursedb");

        numCourses = StudentDB(studentdb).getNumCourseParticipations(msg.sender);

        ids = new uint[](numCourses);
        names = new bytes32[](numCourses);
        ectsPoints = new uint[](numCourses);
        
        for (uint i = 0; i < numCourses; ++i) {
            bytes32 participationID = StudentDB(studentdb).getCourseParticipationIDAt(msg.sender, i);
            var (, participationCourseID) = CourseParticipationDB(courseparticipationdb).getCourseParticipation(participationID);
            var (, courseName, courseECTSPoints) = CourseDB(coursedb).getCourse(participationCourseID);
            
            ids[i] = participationCourseID;
            names[i] = courseName;
            ectsPoints[i] = courseECTSPoints;
        }
    }
}
