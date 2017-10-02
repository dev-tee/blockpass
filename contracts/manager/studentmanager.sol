pragma solidity ^0.4.0;

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
        address studentdb = ContractProvider(MAN).contracts("studentdb");
        require(StudentDB(studentdb).isStudent(msg.sender));
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

    modifier courseExists(uint courseID) {
        address coursedb = ContractProvider(MAN).contracts("coursedb");
        require(CourseDB(coursedb).exists(courseID));
        _;
    }

    modifier testExists(uint testID) {
        address testdb = ContractProvider(MAN).contracts("testdb");
        require(TestDB(testdb).exists(testID));
        _;
    }

    modifier assignmentExists(uint assignmentID) {
        address assignmentdb = ContractProvider(MAN).contracts("assignmentdb");
        require(AssignmentDB(assignmentdb).exists(assignmentID));
        _;
    }

    modifier submissionExists(uint submissionID) {
        address submissiondb = ContractProvider(MAN).contracts("submissiondb");
        require(SubmissionDB(submissiondb).exists(submissionID));
        _;
    }

    function registerForCourse(uint courseID) onlyStudent courseExists(courseID) {
        address courseparticipationdb = ContractProvider(MAN).contracts("courseparticipationdb");
        CourseParticipationDB(courseparticipationdb).addCourseParticipation(msg.sender, courseID);
    }

    function registerForTest(uint testID) onlyStudent testExists(testID) {
        address testparticipationdb = ContractProvider(MAN).contracts("testparticipationdb");
        TestParticipationDB(testparticipationdb).addTestParticipation(msg.sender, testID);
    }

    function uploadSubmission(
        string description,
        uint submittedDate,
        uint referenceType,
        uint referenceID,
        address[] submitters
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
        for (uint i = 0; i < submitters.length; ++i) {
            if (StudentDB(studentdb).isStudent(submitters[i])) {
                StudentSubmissionDB(studentsubmissiondb).addStudentSubmission(submitters[i], submissionID);
            }
        }
        StudentSubmissionDB(studentsubmissiondb).addStudentSubmission(msg.sender, submissionID);
    }

    function getSubmissions(uint page, uint referenceType, uint referenceID)
        constant
        referenceExists(referenceType, referenceID)
        returns (uint count, bool[], uint[])
    {
        /*address submissiondb = ContractProvider(MAN).contracts("submissiondb");*/
        /*address studentdb = ContractProvider(MAN).contracts("studentdb");*/
        /*address studentsubmissiondb = ContractProvider(MAN).contracts("studentsubmissiondb");*/

        count = 0;
        bool[] memory submitted = new bool[](10);
        uint[] memory ids = new uint[](10);

        /*uint numSubmissions = StudentDB(ContractProvider(MAN).contracts("studentdb")).getNumStudentSubmissions(msg.sender);*/
        for (uint i = page * 10; i < StudentDB(ContractProvider(MAN).contracts("studentdb")).getNumStudentSubmissions(msg.sender) && i < (page + 1) * 10; ++i) {
            /*uint studentsubmissionID = StudentDB(ContractProvider(MAN).contracts("studentdb")).getStudentSubmissionAt(msg.sender, i);*/
            var (, submissionID) = StudentSubmissionDB(ContractProvider(MAN).contracts("studentsubmissiondb")).getStudentSubmission(StudentDB(ContractProvider(MAN).contracts("studentdb")).getStudentSubmissionAt(msg.sender, i));
            var (, submissionReferenceType, submissionReferenceID) = SubmissionDB(ContractProvider(MAN).contracts("submissiondb")).getSubmission(submissionID);
            if (submissionReferenceType == referenceType && submissionReferenceID == referenceID) {
                submitted[count] = true;
                ids[count] = submissionID;
                ++count;
            }
        }

        return(count, submitted, ids);
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
            uint assessmentID = SubmissionDB(submissiondb).getAssessmentAt(submissionID, numAssessments - 1);
            var (, assessmentObtainedPoints, assessmentSubmissionID) = AssessmentDB(assessmentdb).getAssessment(assessmentID);

            id = assessmentID;
            obtainedPoints = assessmentObtainedPoints;
            assessed = true;
            numPriorAssessments = numAssessments - 1;

            assert(assessmentSubmissionID == submissionID);
        }
    }
}
