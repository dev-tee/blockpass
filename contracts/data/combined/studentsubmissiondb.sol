pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../submissiondb.sol";


contract StudentSubmissionDB is ManagedContract {

    struct StudentSubmission {
        address studentID;
        uint submissionID;
        uint IDindex;
    }

    bytes32[] IDs;
    mapping(bytes32 => StudentSubmission) studentSubmissions;

    function exists(address studentID, uint submissionID) public constant returns(bool) {
        return exists(keccak256(studentID, submissionID));
    }

    function exists(bytes32 ID) internal constant returns(bool) {
        if (IDs.length == 0) {
            return false;
        }
        StudentSubmission memory savedValue = studentSubmissions[ID];
        uint savedIDindex = savedValue.IDindex;
        bytes32 savedID = IDs[savedIDindex];
        return ID == savedID;
    }

    function addStudentSubmission(address studentID, uint submissionID) public {
        bytes32 ID = keccak256(studentID, submissionID);
        require(!exists(ID));

        studentSubmissions[ID].studentID = studentID;
        studentSubmissions[ID].submissionID = submissionID;
        studentSubmissions[ID].IDindex = IDs.length;
        IDs.push(ID);

        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address submissionDB = ContractProvider(MAN).contracts("submissiondb");
        
        StudentDB(studentDB).addStudentSubmissionID(studentID, ID);
        SubmissionDB(submissionDB).addStudentSubmissionID(submissionID, ID);
    }

    function getStudentSubmissionAt(uint index) public constant returns(address studentID, uint submissionID) {
        return getStudentSubmission(IDs[index]);
    }

    function getStudentSubmission(bytes32 ID) public constant returns(address studentID, uint submissionID) {
        require(exists(ID));
        return(studentSubmissions[ID].studentID, studentSubmissions[ID].submissionID);
    }
}
