pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../supervisordb.sol";
import "../assessmentdb.sol";

// This contract is responsible for the n-to-n
// relationship between assessments and supervisors.
// It represents a supervisors's contribution to an assessment
// and provides functions to get, add and query for values.


contract SupervisorAssessmentDB is ManagedContract {

    // This struct saves the relationship and
    // also holds a reference to its own id.
    struct SupervisorAssessment {
        address supervisorID;
        uint assessmentID;
        uint idIndex;
    }

    // This array holds all ids for the relationships.
    bytes32[] supervisorAssessmentIDs;

    // This mapping holds all individual relationships.
    mapping(bytes32 => SupervisorAssessment) supervisorAssessments;

    // Check whether a relationship between
    // a given supervisor and assessment already exists.
    function exists(address supervisorID, uint assessmentID) public constant returns(bool) {
        return exists(keccak256(supervisorID, assessmentID));
    }

    // Use the provided id to check whether it already exits in our database
    // by reading out the value it points to in our mapping.
    // The saved value should point to an id that is identical to the one
    // that was provided if we have actually saved this value beforehand.
    function exists(bytes32 id) internal constant returns(bool) {
        if (supervisorAssessmentIDs.length == 0) {
            return false;
        }
        SupervisorAssessment memory savedValue = supervisorAssessments[id];
        uint savedIDindex = savedValue.idIndex;
        bytes32 savedID = supervisorAssessmentIDs[savedIDindex];
        return id == savedID;
    }

    // Save a new relationship between a supervisor and an assessment.
    function addSupervisorAssessment(address supervisorID, uint assessmentID) public {
        bytes32 id = keccak256(supervisorID, assessmentID);
        require(!exists(id));

        supervisorAssessments[id].supervisorID = supervisorID;
        supervisorAssessments[id].assessmentID = assessmentID;
        supervisorAssessments[id].idIndex = supervisorAssessmentIDs.length;
        supervisorAssessmentIDs.push(id);

        // Call the respective databases to save this
        // relationship's id for faster access.
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address assessmentDB = ContractProvider(MAN).contracts("assessmentdb");
        SupervisorDB(supervisorDB).addSupervisorAssessmentID(supervisorID, id);
        AssessmentDB(assessmentDB).addSupervisorAssessmentID(assessmentID, id);
    }

    // Get the supervisor and assessment of the relationship at the index's position.
    function getSupervisorAssessmentAt(uint index) public constant returns(address supervisorID, uint assessmentID) {
        return getSupervisorAssessment(supervisorAssessmentIDs[index]);
    }

    // Use the provided id to find the relationship and return its values.
    function getSupervisorAssessment(bytes32 id) public constant returns(address supervisorID, uint assessmentID) {
        require(exists(id));
        return(supervisorAssessments[id].supervisorID, supervisorAssessments[id].assessmentID);
    }
}
