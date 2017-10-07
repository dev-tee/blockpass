pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";
import "./submissiondb.sol";


contract AssessmentDB is ManagedContract {

    struct Assessment {
        string description;
        uint obtainedPoints;
        uint submissionID;
        bytes32[] supervisorAssessmentIDs;
    }

    Assessment[] assessments;

    function exists(uint id) public constant returns(bool) {
        return assessments.length > id;
    }

    function supervisorAssessmentExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && assessments[id].supervisorAssessmentIDs.length > refIndex;
    }

    function addAssessment(string description, uint obtainedPoints, uint submissionID) public returns(uint id) {
        id = assessments.length++;

        address submissionDB = ContractProvider(MAN).contracts("submissiondb");
        SubmissionDB(submissionDB).addAssessmentID(submissionID, id);

        Assessment storage assessment = assessments[id];
        assessment.description = description;
        assessment.obtainedPoints = obtainedPoints;
        assessment.submissionID = submissionID;
    }

    function getAssessment(uint id) public constant returns(string description, uint obtainedPoints, uint submissionID) {
        require(exists(id));
        return(assessments[id].description, assessments[id].obtainedPoints, assessments[id].submissionID);
    }

    function getNumAssessments() public constant returns(uint) {
        return assessments.length;
    }

    function addSupervisorAssessmentID(uint assessmentID, bytes32 id) permission("supervisorassessmentdb") {
        require(exists(assessmentID));
        assessments[assessmentID].supervisorAssessmentIDs.push(id);
    }

    function getSupervisorAssessmentIDAt(uint assessmentID, uint index) public constant returns(bytes32) {
        require(supervisorAssessmentExists(assessmentID, index));
        return(assessments[assessmentID].supervisorAssessmentIDs[index]);
    }

    function getNumSupervisorAssessments(uint assessmentID) public constant returns(uint) {
        require(exists(assessmentID));
        return assessments[assessmentID].supervisorAssessmentIDs.length;
    }
}
