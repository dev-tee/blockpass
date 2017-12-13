pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";

// This contract is responsible for all supervisors.
// It provides functions to get and add supervisors
// as well as the ability to link them to
// assessments, tests and courses.


contract SupervisorDB is ManagedContract {

    // This struct contains data that is relevant for a supervisor.
    // Additionally it has references to tests, courses, assessments and its own id.
    struct Supervisor {
        string name;
        string uaccountID;
        uint index;
        bytes32[] courseSupervisionIDs;
        bytes32[] testSupervisionIDs;
        bytes32[] supervisorAssessmentIDs;
    }

    // This array holds all ids for the supervisors.
    address[] indices;

    // This mapping holds all individual supervisors.
    mapping (address => Supervisor) supervisors;

    // Check whether a supervisor with a given id
    // - an ethereum address in this case - already exists.
    function isSupervisor(address account) public constant returns(bool) {
        return indices.length != 0 && indices[supervisors[account].index] == account;
    }

    // Check whether a supervisor with a given id has
    // at least the given amount of connections to courses.
    function courseSupervisionExists(address account, uint refIndex) public constant returns(bool) {
        return isSupervisor(account) && supervisors[account].courseSupervisionIDs.length > refIndex;
    }

    // Check whether a supervisor with a given id has
    // at least the given amount of connections to tests.
    function testSupervisionExists(address account, uint refIndex) public constant returns(bool) {
        return isSupervisor(account) && supervisors[account].testSupervisionIDs.length > refIndex;
    }

    // Check whether a supervisor with a given id has
    // at least the given amount of connections to assessments.
    function supervisorAssessmentExists(address account, uint refIndex) public constant returns(bool) {
        return isSupervisor(account) && supervisors[account].supervisorAssessmentIDs.length > refIndex;
    }

    // Add a new supervisor to our contract.
    function addSupervisor(address account, string name, string uaccountID) public {
        require(!isSupervisor(account));
        supervisors[account].name = name;
        supervisors[account].uaccountID = uaccountID;
        supervisors[account].index = indices.length;
        indices.push(account);
    }

    // Get the data of a supervisor with a given id.
    function getSupervisor(address account) public constant returns(string name, string uaccountID) {
        require(isSupervisor(account));
        return(supervisors[account].name, supervisors[account].uaccountID);
    }

    // Get the data of a supervisor at the index's position.
    function getSupervisorAt(uint index) public constant returns(string name, string uaccountID) {
        return getSupervisor(indices[index]);
    }

    // Return the number of supervisors saved in the contract.
    function getNumSupervisors() public constant returns(uint) {
        return indices.length;
    }

    // Link a given supervisor to a course.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between supervisors and courses.
    function addCourseSupervisionID(address account, bytes32 id) permission("coursesupervisiondb") {
        require(isSupervisor(account));
        supervisors[account].courseSupervisionIDs.push(id);
    }

    // Get the information about the connection between
    // a given supervisor and a course at the index's position.
    function getCourseSupervisionIDAt(address account, uint index) public constant returns(bytes32) {
        require(courseSupervisionExists(account, index));
        return(supervisors[account].courseSupervisionIDs[index]);
    }

    // Return the number of connections a given supervisor has to courses.
    function getNumCourseSupervisions(address account) public constant returns(uint) {
        require(isSupervisor(account));
        return supervisors[account].courseSupervisionIDs.length;
    }

    // Link a given supervisor to a test.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between supervisors and tests.
    function addTestSupervisionID(address account, bytes32 id) permission("testsupervisiondb") {
        require(isSupervisor(account));
        supervisors[account].testSupervisionIDs.push(id);
    }

    // Get the information about the connection between
    // a given supervisor and a test at the index's position.
    function getTestSupervisionIDAt(address account, uint index) public constant returns(bytes32) {
        require(testSupervisionExists(account, index));
        return(supervisors[account].testSupervisionIDs[index]);
    }

    // Return the number of connections a given supervisor has to tests.
    function getNumTestSupervisions(address account) public constant returns(uint) {
        require(isSupervisor(account));
        return supervisors[account].testSupervisionIDs.length;
    }

    // Link a given supervisor to an assessment.
    // This function can only be called by the contract
    // that is responsible for keeping track of n-to-n
    // relationships between supervisors and assessments.
    function addSupervisorAssessmentID(address account, bytes32 id) permission("supervisorassessmentdb") {
        require(isSupervisor(account));
        supervisors[account].supervisorAssessmentIDs.push(id);
    }

    // Get the information about the connection between
    // a given supervisor and an assessment at the index's position.
    function getSupervisorAssessmentIDAt(address account, uint index) public constant returns(bytes32) {
        require(supervisorAssessmentExists(account, index));
        return(supervisors[account].supervisorAssessmentIDs[index]);
    }

    // Return the number of connections a given supervisor has to assessments.
    function getNumSupervisorAssessments(address account) public constant returns(uint) {
        require(isSupervisor(account));
        return supervisors[account].supervisorAssessmentIDs.length;
    }
}
