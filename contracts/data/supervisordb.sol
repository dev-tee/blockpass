pragma solidity ^0.4.3;

import "../manager/contractmanager.sol";


contract SupervisorDB is ManagedContract {

    struct Supervisor {
        bytes32 name;
        bytes32 uaccountID;
        uint index;
        bytes32[] courseSupervisionIDs;
        bytes32[] testSupervisionIDs;
        bytes32[] supervisorAssessmentIDs;
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

    function addSupervisor(address account, bytes32 name, bytes32 uaccountID) public {
        require(!isSupervisor(account));
        supervisors[account].name = name;
        supervisors[account].uaccountID = uaccountID;
        supervisors[account].index = indices.length;
        indices.push(account);
    }

    function getSupervisor(address account) public constant returns(bytes32 name, bytes32 uaccountID) {
        require(isSupervisor(account));
        return(supervisors[account].name, supervisors[account].uaccountID);
    }

    function getSupervisorAt(uint index) public constant returns(bytes32 name, bytes32 uaccountID) {
        return getSupervisor(indices[index]);
    }

    function getNumSupervisors() public constant returns(uint) {
        return indices.length;
    }

    function addCourseSupervisionID(address account, bytes32 id) permission("coursesupervisiondb") {
        require(isSupervisor(account));
        supervisors[account].courseSupervisionIDs.push(id);
    }

    function getCourseSupervisionIDAt(address account, uint index) public constant returns(bytes32) {
        require(courseSupervisionExists(account, index));
        return(supervisors[account].courseSupervisionIDs[index]);
    }

    function getNumCourseSupervisions(address account) public constant returns(uint) {
        require(isSupervisor(account));
        return supervisors[account].courseSupervisionIDs.length;
    }

    function addTestSupervisionID(address account, bytes32 id) permission("testsupervisiondb") {
        require(isSupervisor(account));
        supervisors[account].testSupervisionIDs.push(id);
    }

    function getTestSupervisionIDAt(address account, uint index) public constant returns(bytes32) {
        require(testSupervisionExists(account, index));
        return(supervisors[account].testSupervisionIDs[index]);
    }

    function getNumTestSupervisions(address account) public constant returns(uint) {
        require(isSupervisor(account));
        return supervisors[account].testSupervisionIDs.length;
    }

    function addSupervisorAssessmentID(address account, bytes32 id) permission("supervisorassessmentdb") {
        require(isSupervisor(account));
        supervisors[account].supervisorAssessmentIDs.push(id);
    }

    function getSupervisorAssessmentIDAt(address account, uint index) public constant returns(bytes32) {
        require(supervisorAssessmentExists(account, index));
        return(supervisors[account].supervisorAssessmentIDs[index]);
    }

    function getNumSupervisorAssessments(address account) public constant returns(uint) {
        require(isSupervisor(account));
        return supervisors[account].supervisorAssessmentIDs.length;
    }
}
