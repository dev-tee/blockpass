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

    modifier containsOnlyStudents(address[] acnumSubmissionss) {
        bool valid = true;
        address studentdb = ContractProvider(MAN).contracts("studentdb");

        for(uint i = 0; i < acnumSubmissionss.length; ++i) {
            if (!StudentDB(studentdb).isStudent(acnumSubmissionss[i])) {
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

    function uploadAssignmentSubmission(
        string description,
        uint assignmentID,
        address[] remainingGroupMembers
    )
        public
        onlyStudent
        containsOnlyStudents(remainingGroupMembers)
        assignmentExists(assignmentID)
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

    function getPersonalStudentCourses()
        public
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
