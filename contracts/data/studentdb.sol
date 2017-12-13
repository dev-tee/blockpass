pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";

// This contract is responsible for all students.
// It provides functions to get and add students
// as well as the ability to link them to
// submissions, courses and tests.


contract StudentDB is ManagedContract {

    // This struct contains data that is relevant for a student.
    // Additionally it has references to tests, courses, submissions and its own id.
    struct Student {
        string name;
        uint matrNr;
        uint index;
        bytes32[] testParticipationIDs;
        bytes32[] courseParticipationIDs;
        bytes32[] studentSubmissionIDs;
    }

    // This array holds all ids for the students.
    address[] indices;

    // This mapping holds all individual students.
    mapping (address => Student) students;

    // Check whether a student with a given id
    // - an ethereum address in this case - already exists.
    function isStudent(address account) public constant returns(bool) {
        return indices.length != 0 && indices[students[account].index] == account;
    }

    // Check whether a student with a given id has
    // at least the given amount of connections to tests.
    function testParticipationExists(address account, uint refIndex) public constant returns(bool) {
        return isStudent(account) && students[account].testParticipationIDs.length > refIndex;
    }

    // Check whether a student with a given id has
    // at least the given amount of connections to courses.
    function courseParticipationExists(address account, uint refIndex) public constant returns(bool) {
        return isStudent(account) && students[account].courseParticipationIDs.length > refIndex;
    }

    // Check whether a student with a given id has
    // at least the given amount of connections to submissions.
    function studentSubmissionExists(address account, uint refIndex) public constant returns(bool) {
        return isStudent(account) && students[account].studentSubmissionIDs.length > refIndex;
    }

    // Add a new student to our contract.
    function addStudent(address account, string name, uint matrNr) public {
        require(!isStudent(account));
        students[account].name = name;
        students[account].matrNr = matrNr;
        students[account].index = indices.length;
        indices.push(account);
    }

    // Get the data of a student with a given id.
    function getStudent(address account) public constant returns(string name, uint matrNr) {
        require(isStudent(account));
        return(students[account].name, students[account].matrNr);
    }

    // Get the data of a student at the index's position.
    function getStudentAt(uint index) public constant returns(string name, uint matrNr) {
        return getStudent(indices[index]);
    }

    // Return the number of students saved in the contract.
    function getNumStudents() public constant returns(uint) {
        return indices.length;
    }

    // Link a given student to a test.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between students and tests.
    function addTestParticipationID(address account, bytes32 id) permission("testparticipationdb") {
        require(isStudent(account));
        students[account].testParticipationIDs.push(id);
    }

    // Get the information about the connection between
    // a given student and a test at the index's position.
    function getTestParticipationIDAt(address account, uint index) public constant returns(bytes32) {
        require(testParticipationExists(account, index));
        return(students[account].testParticipationIDs[index]);
    }

    // Return the number of connections a given student has to tests.
    function getNumTestParticipations(address account) public constant returns(uint) {
        require(isStudent(account));
        return students[account].testParticipationIDs.length;
    }

    // Link a given student to a course.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between students and courses.
    function addCourseParticipationID(address account, bytes32 id) permission("courseparticipationdb") {
        require(isStudent(account));
        students[account].courseParticipationIDs.push(id);
    }

    // Get the information about the connection between
    // a given student and a course at the index's position.
    function getCourseParticipationIDAt(address account, uint index) public constant returns(bytes32) {
        require(courseParticipationExists(account, index));
        return(students[account].courseParticipationIDs[index]);
    }

    // Return the number of connections a given student has to courses.
    function getNumCourseParticipations(address account) public constant returns(uint) {
        require(isStudent(account));
        return students[account].courseParticipationIDs.length;
    }

    // Link a given student to a submission.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between students and submissions.
    function addStudentSubmissionID(address account, bytes32 id) permission("studentsubmissiondb") {
        require(isStudent(account));
        students[account].studentSubmissionIDs.push(id);
    }

    // Get the information about the connection between
    // a given student and a submission at the index's position.
    function getStudentSubmissionIDAt(address account, uint index) public constant returns(bytes32) {
        require(studentSubmissionExists(account, index));
        return(students[account].studentSubmissionIDs[index]);
    }

    // Return the number of connections a given student has to submissions.
    function getNumStudentSubmissions(address account) public constant returns(uint) {
        require(isStudent(account));
        return students[account].studentSubmissionIDs.length;
    }
}
