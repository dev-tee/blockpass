pragma solidity ^0.4.0;

import "../manager/contractmanager.sol";
import "./submissiondb.sol";


contract AssessmentDB is ManagedContract {

    struct Assessment {
        bytes32 criteria;
        uint maxPoints;
        uint obtainedPoints;
        uint submissionID;
        uint[] supervisorAssessmentIDs;
    }

    Assessment[] assessments;

    function exists(uint id) public constant returns(bool) {
        return assessments.length > id;
    }

    function supervisorAssessmentExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && assessments[id].supervisorAssessmentIDs.length > refIndex;
    }

    function addAssessment(bytes32 criteria, uint maxPoints, uint obtainedPoints, uint submissionID) public {
        address submissionDB = ContractProvider(MAN).contracts("submissiondb");
        SubmissionDB(submissionDB).addAssessmentID(submissionID, assessments.length);

        Assessment storage assessment = assessments[assessments.length++];
        assessment.criteria = criteria;
        assessment.maxPoints = maxPoints;
        assessment.obtainedPoints = obtainedPoints;
        assessment.submissionID = submissionID;
    }

    function getAssessment(uint id) public constant returns(bytes32 criteria, uint maxPoints, uint obtainedPoints, uint submissionID) {
        require(exists(id));
        return(assessments[id].criteria, assessments[id].maxPoints, assessments[id].obtainedPoints, assessments[id].submissionID);
    }

    function getNumAssessments() public constant returns(uint) {
        return assessments.length;
    }

    function addSupervisorAssessmentID(uint assessmentID, uint id) permission("supervisorassessmentdb") {
        require(exists(assessmentID));
        assessments[assessmentID].supervisorAssessmentIDs.push(id);
    }

    function getSupervisorAssessmentAt(uint assessmentID, uint index) public constant returns(uint) {
        require(supervisorAssessmentExists(assessmentID, index));
        return(assessments[assessmentID].supervisorAssessmentIDs[index]);
    }

    function getNumSupervisorAssessments(uint assessmentID) public constant returns(uint) {
        require(exists(assessmentID));
        return assessments[assessmentID].supervisorAssessmentIDs.length;
    }
}
