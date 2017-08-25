pragma solidity ^0.4.0;

import "../../contractmanager.sol";
import "../supervisordb.sol";
import "../assessmentdb.sol";


contract SupervisorAssessmentDB is ManagedContract {

    struct SupervisorAssessment {
        address supervisorID;
        uint assessmentID;
    }

    SupervisorAssessment[] supervisorAssessments;

    function exists(uint id) public constant returns(bool) {
        return supervisorAssessments.length > id;
    }

    function addSupervisorAssessment(address supervisorID, uint assessmentID) public {
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address assessmentDB = ContractProvider(MAN).contracts("assessmentdb");
        
        SupervisorDB(supervisorDB).addSupervisorAssessmentID(supervisorID, supervisorAssessments.length);
        AssessmentDB(assessmentDB).addSupervisorAssessmentID(assessmentID, supervisorAssessments.length);
        
        supervisorAssessments.push(SupervisorAssessment(supervisorID, assessmentID));
    }

    function getSupervisorAssessment(uint id) public constant returns(address supervisorID, uint assessmentID) {
        require(exists(id));
        return(supervisorAssessments[id].supervisorID, supervisorAssessments[id].assessmentID);
    }
}
