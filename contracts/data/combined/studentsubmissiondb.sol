pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../submissiondb.sol";


contract StudentSubmissionDB is ManagedContract {

    struct StudentSubmission {
        address studentID;
        uint submissionID;
        uint idIndex;
    }

    bytes32[] studentSubmissionIDs;
    mapping(bytes32 => StudentSubmission) studentSubmissions;

    function exists(address studentID, uint submissionID) public constant returns(bool) {
        return exists(keccak256(studentID, submissionID));
    }

    function exists(bytes32 id) internal constant returns(bool) {
        if (studentSubmissionIDs.length == 0) {
            return false;
        }
        StudentSubmission memory savedValue = studentSubmissions[id];
        uint savedIDindex = savedValue.idIndex;
        bytes32 savedID = studentSubmissionIDs[savedIDindex];
        return id == savedID;
    }

    function addStudentSubmission(address studentID, uint submissionID) public {
        bytes32 id = keccak256(studentID, submissionID);
        require(!exists(id));

        studentSubmissions[id].studentID = studentID;
        studentSubmissions[id].submissionID = submissionID;
        studentSubmissions[id].idIndex = studentSubmissionIDs.length;
        studentSubmissionIDs.push(id);

        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address submissionDB = ContractProvider(MAN).contracts("submissiondb");

        StudentDB(studentDB).addStudentSubmissionID(studentID, id);
        SubmissionDB(submissionDB).addStudentSubmissionID(submissionID, id);
    }

    function getStudentSubmissionAt(uint index) public constant returns(address studentID, uint submissionID) {
        return getStudentSubmission(studentSubmissionIDs[index]);
    }

    function getStudentSubmission(bytes32 id) public constant returns(address studentID, uint submissionID) {
        require(exists(id));
        return(studentSubmissions[id].studentID, studentSubmissions[id].submissionID);
    }
}
