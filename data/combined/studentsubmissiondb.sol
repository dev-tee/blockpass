pragma solidity ^0.4.0;

import "../../contractmanager.sol";
import "../studentdb.sol";
import "../submissiondb.sol";


contract StudentSubmissionDB is ManagedContract {

    struct StudentSubmission {
        address studentID;
        uint submissionID;
    }

    StudentSubmission[] studentSubmissions;

    function exists(uint id) public constant returns(bool) {
        return studentSubmissions.length > id;
    }

    function addStudentSubmission(address studentID, uint submissionID) public {
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address submissionDB = ContractProvider(MAN).contracts("submissiondb");
        
        StudentDB(studentDB).addStudentSubmissionID(studentID, studentSubmissions.length);
        SubmissionDB(submissionDB).addStudentSubmissionID(submissionID, studentSubmissions.length);
        
        studentSubmissions.push(StudentSubmission(studentID, submissionID));
    }

    function getStudentSubmission(uint id) public constant returns(address studentID, uint submissionID) {
        require(exists(id));
        return(studentSubmissions[id].studentID, studentSubmissions[id].submissionID);
    }
}
