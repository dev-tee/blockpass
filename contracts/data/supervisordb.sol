pragma solidity ^0.4.0;

import "../manager/contractmanager.sol";


contract SupervisorDB is ManagedContract {

    struct Supervisor {
        bytes32 name;
        uint index;
        uint[] courseSupervisionIDs;
        uint[] testSupervisionIDs;
        uint[] supervisorAssessmentIDs;
    }

    address[] indices;
    mapping (address => Supervisor) supervisors;

    function isSupervisor(address account) public constant returns(bool) {
        return indices.length != 0 && indices[supervisors[account].index] == account;
    }

    function courseSupervisionExists(address account, uint refIndex) public constant returns(bool) {
        return isSupervisor(account) && supervisors[account].courseSupervisionIDs.length > refIndex;
    }

    function testSupervisionExists(address account, uint refIndex) public constant returns(bool) {
        return isSupervisor(account) && supervisors[account].testSupervisionIDs.length > refIndex;
    }

    function supervisorAssessmentExists(address account, uint refIndex) public constant returns(bool) {
        return isSupervisor(account) && supervisors[account].supervisorAssessmentIDs.length > refIndex;
    }

    function addSupervisor(address account, bytes32 name) public {
        supervisors[account].name = name;
        supervisors[account].index = indices.length;
        indices.push(account);
    }

    function getSupervisor(address account) public constant returns(bytes32) {
        require(isSupervisor(account));
        return(supervisors[account].name);
    }

    function getSupervisorAt(uint index) public constant returns(bytes32) {
        return getSupervisor(indices[index]);
    }

    function getNumSupervisors() public constant returns(uint) {
        return indices.length;
    }

    function addCourseSupervisionID(address account, uint id) permission("coursesupervisiondb") {
        require(isSupervisor(account));
        supervisors[account].courseSupervisionIDs.push(id);
    }

    function getCourseSupervisionAt(address account, uint index) public constant returns(uint) {
        require(courseSupervisionExists(account, index));
        return(supervisors[account].courseSupervisionIDs[index]);
    }

    function getNumCourseSupervisions(address account) public constant returns(uint) {
        require(isSupervisor(account));
        return supervisors[account].courseSupervisionIDs.length;
    }

    function addTestSupervisionID(address account, uint id) permission("testsupervisiondb") {
        require(isSupervisor(account));
        supervisors[account].testSupervisionIDs.push(id);
    }

    function getTestSupervisionAt(address account, uint index) public constant returns(uint) {
        require(testSupervisionExists(account, index));
        return(supervisors[account].testSupervisionIDs[index]);
    }

    function getNumTestSupervisions(address account) public constant returns(uint) {
        require(isSupervisor(account));
        return supervisors[account].testSupervisionIDs.length;
    }

    function addSupervisorAssessmentID(address account, uint id) permission("supervisorassessmentdb") {
        require(isSupervisor(account));
        supervisors[account].supervisorAssessmentIDs.push(id);
    }

    function getSupervisorAssessmentAt(address account, uint index) public constant returns(uint) {
        require(supervisorAssessmentExists(account, index));
        return(supervisors[account].supervisorAssessmentIDs[index]);
    }

    function getNumSupervisorAssessments(address account) public constant returns(uint) {
        require(isSupervisor(account));
        return supervisors[account].supervisorAssessmentIDs.length;
    }
}
