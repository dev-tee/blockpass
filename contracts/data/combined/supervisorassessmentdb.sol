pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../supervisordb.sol";
import "../assessmentdb.sol";


contract SupervisorAssessmentDB is ManagedContract {

    struct SupervisorAssessment {
        address supervisorID;
        uint assessmentID;
        uint IDindex;
    }

    bytes32[] IDs;
    mapping(bytes32 => SupervisorAssessment) supervisorAssessments;

    function exists(address supervisorID, uint assessmentID) public constant returns(bool) {
        return exists(keccak256(supervisorID, assessmentID));
    }

    function exists(bytes32 ID) internal constant returns(bool) {
        if (IDs.length == 0) {
            return false;
        }
        SupervisorAssessment memory savedValue = supervisorAssessments[ID];
        uint savedIDindex = savedValue.IDindex;
        bytes32 savedID = IDs[savedIDindex];
        return ID == savedID;
    }

    function addSupervisorAssessment(address supervisorID, uint assessmentID) public {
        bytes32 ID = keccak256(supervisorID, assessmentID);
        require(!exists(ID));
        
        supervisorAssessments[ID].supervisorID = supervisorID;
        supervisorAssessments[ID].assessmentID = assessmentID;
        supervisorAssessments[ID].IDindex = IDs.length;
        IDs.push(ID);

        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address assessmentDB = ContractProvider(MAN).contracts("assessmentdb");
        
        SupervisorDB(supervisorDB).addSupervisorAssessmentID(supervisorID, ID);
        AssessmentDB(assessmentDB).addSupervisorAssessmentID(assessmentID, ID);
    }

    function getSupervisorAssessmentAt(uint index) public constant returns(address supervisorID, uint assessmentID) {
        return getSupervisorAssessment(IDs[index]);
    }

    function getSupervisorAssessment(bytes32 ID) internal constant returns(address supervisorID, uint assessmentID) {
        require(exists(ID));
        return(supervisorAssessments[ID].supervisorID, supervisorAssessments[ID].assessmentID);
    }
}
