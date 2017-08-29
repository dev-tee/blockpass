pragma solidity ^0.4.0;

import "../manager/contractmanager.sol";


contract StudentDB is ManagedContract {

    struct Student {
        bytes32 name;
        uint matrNr;
        uint index;
        uint[] testParticipationIDs;
        uint[] courseParticipationIDs;
        uint[] studentSubmissionIDs;
    }

    address[] indices;
    mapping (address => Student) students;

    function isStudent(address account) public constant returns(bool) {
        return indices.length != 0
            && indices[students[account].index] == account;
    }

    function testParticipationExists(address account, uint refIndex) public constant returns(bool) {
        return isStudent(account) && students[account].testParticipationIDs.length > refIndex;
    }
    
    function courseParticipationExists(address account, uint refIndex) public constant returns(bool) {
        return isStudent(account) && students[account].courseParticipationIDs.length > refIndex;
    }
    
    function studentSubmissionExists(address account, uint refIndex) public constant returns(bool) {
        return isStudent(account) && students[account].studentSubmissionIDs.length > refIndex;
    }

    function addStudent(address account, bytes32 name, uint matrNr) public {
        students[account].name = name;
        students[account].matrNr = matrNr;
        students[account].index = indices.length;
        indices.push(account);
    }

    function getStudent(address account) public constant returns(bytes32, uint) {
        require(isStudent(account));
        return(students[account].name, students[account].matrNr);
    }

    function getStudentAt(uint index) public constant returns(bytes32, uint) {
        return getStudent(indices[index]);
    }

    function getNumStudents() public constant returns(uint) {
        return indices.length;
    }

    function addTestParticipationID(address account, uint id) permission("testparticipationdb") {
        require(isStudent(account));
        students[account].testParticipationIDs.push(id);
    }

    function getTestParticipationAt(address account, uint index) public constant returns(uint) {
        require(testParticipationExists(account, index));
        return(students[account].testParticipationIDs[index]);
    }

    function getNumTestParticipations(address account) public constant returns(uint) {
        require(isStudent(account));
        return students[account].testParticipationIDs.length;
    }

    function addCourseParticipationID(address account, uint id) permission("courseparticipationdb") {
        require(isStudent(account));
        students[account].courseParticipationIDs.push(id);
    }

    function getCourseParticipationAt(address account, uint index) public constant returns(uint) {
        require(courseParticipationExists(account, index));
        return(students[account].courseParticipationIDs[index]);
    }

    function getNumCourseParticipations(address account) public constant returns(uint) {
        require(isStudent(account));
        return students[account].courseParticipationIDs.length;
    }

    function addStudentSubmissionID(address account, uint id) permission("studentsubmissiondb") {
        require(isStudent(account));
        students[account].studentSubmissionIDs.push(id);
    }

    function getStudentSubmissionAt(address account, uint index) public constant returns(uint) {
        require(studentSubmissionExists(account, index));
        return(students[account].studentSubmissionIDs[index]);
    }

    function getNumStudentSubmissions(address account) public constant returns(uint) {
        require(isStudent(account));
        return students[account].studentSubmissionIDs.length;
    }
}
