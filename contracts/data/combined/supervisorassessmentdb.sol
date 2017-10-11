pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../supervisordb.sol";
import "../assessmentdb.sol";


contract SupervisorAssessmentDB is ManagedContract {

    struct SupervisorAssessment {
        address supervisorID;
        uint assessmentID;
        uint idIndex;
    }

    bytes32[] supervisorAssessmentIDs;
    mapping(bytes32 => SupervisorAssessment) supervisorAssessments;

    function exists(address supervisorID, uint assessmentID) public constant returns(bool) {
        return exists(keccak256(supervisorID, assessmentID));
    }

    function exists(bytes32 id) internal constant returns(bool) {
        if (supervisorAssessmentIDs.length == 0) {
            return false;
        }
        SupervisorAssessment memory savedValue = supervisorAssessments[id];
        uint savedIDindex = savedValue.idIndex;
        bytes32 savedID = supervisorAssessmentIDs[savedIDindex];
        return id == savedID;
    }

    function addSupervisorAssessment(address supervisorID, uint assessmentID) public {
        bytes32 id = keccak256(supervisorID, assessmentID);
        require(!exists(id));

        supervisorAssessments[id].supervisorID = supervisorID;
        supervisorAssessments[id].assessmentID = assessmentID;
        supervisorAssessments[id].idIndex = supervisorAssessmentIDs.length;
        supervisorAssessmentIDs.push(id);

        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address assessmentDB = ContractProvider(MAN).contracts("assessmentdb");

        SupervisorDB(supervisorDB).addSupervisorAssessmentID(supervisorID, id);
        AssessmentDB(assessmentDB).addSupervisorAssessmentID(assessmentID, id);
    }

    function getSupervisorAssessmentAt(uint index) public constant returns(address supervisorID, uint assessmentID) {
        return getSupervisorAssessment(supervisorAssessmentIDs[index]);
    }

    function getSupervisorAssessment(bytes32 id) internal constant returns(address supervisorID, uint assessmentID) {
        require(exists(id));
        return(supervisorAssessments[id].supervisorID, supervisorAssessments[id].assessmentID);
    }
}
