pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";
import "./submissiondb.sol";

// This contract is responsible for all assessments.
// It provides functions to get and add assessments
// as well as the ability to link them to supervisors.


contract AssessmentDB is ManagedContract {

    // This struct contains data that is relevant for an assessment.
    // Additionally it has references to supervisors and a submission.
    struct Assessment {
        string description;
        uint obtainedPoints;
        uint submissionID;
        bytes32[] supervisorAssessmentIDs;
    }

    // For convenience all assessments are saved
    // in an array with the index as their id.
    Assessment[] assessments;

    // Check whether an assessment with a given id
    // - a simple index in this case - already exists.
    function exists(uint id) public constant returns(bool) {
        return assessments.length > id;
    }

    // Check whether an assessment with a given id has
    // at least the given amount of connections to supervisors.
    function supervisorAssessmentExists(uint id, uint refIndex) public constant returns(bool) {
        return exists(id) && assessments[id].supervisorAssessmentIDs.length > refIndex;
    }

    // Add a new assessment to our contract.
    function addAssessment(string description, uint obtainedPoints, uint submissionID) public returns(uint id) {
        id = assessments.length++;

        // Link the new assessment's id to the corresponding submission.
        address submissionDB = ContractProvider(MAN).contracts("submissiondb");
        SubmissionDB(submissionDB).addAssessmentID(submissionID, id);

        Assessment storage assessment = assessments[id];
        assessment.description = description;
        assessment.obtainedPoints = obtainedPoints;
        assessment.submissionID = submissionID;
    }

    // Get the data of an assessment with a given id.
    function getAssessment(uint id) public constant returns(string description, uint obtainedPoints, uint submissionID) {
        require(exists(id));
        return(assessments[id].description, assessments[id].obtainedPoints, assessments[id].submissionID);
    }

    // Return the number of assessments saved in the contract.
    function getNumAssessments() public constant returns(uint) {
        return assessments.length;
    }

    // Link a given assessment to a supervisor.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between assessments and supervisors.
    function addSupervisorAssessmentID(uint assessmentID, bytes32 id) permission("supervisorassessmentdb") {
        require(exists(assessmentID));
        assessments[assessmentID].supervisorAssessmentIDs.push(id);
    }

    // Get the information about the connection between
    // a given assessment and a supervisor at the index's position.
    function getSupervisorAssessmentIDAt(uint assessmentID, uint index) public constant returns(bytes32) {
        require(supervisorAssessmentExists(assessmentID, index));
        return(assessments[assessmentID].supervisorAssessmentIDs[index]);
    }

    // Return the number of connections a given assessment has to supervisors.
    function getNumSupervisorAssessments(uint assessmentID) public constant returns(uint) {
        require(exists(assessmentID));
        return assessments[assessmentID].supervisorAssessmentIDs.length;
    }
}
