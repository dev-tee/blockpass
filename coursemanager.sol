pragma solidity ^0.4.0;

import "./contractmanager.sol";


contract CourseManager is ManagedContract {

    // TODO: implement actual check of userType
    modifier onlySupervisor() {
        require(true);
        _;
    }

    // TODO: implement actual check of userType
    modifier onlyStudent() {
        require(true);
        _;
    }

    // TODO: implement actual check of existence
    modifier courseExists(uint courseNumber) {
        require(true);
        _;
    }

    event Created(uint courseNumber, bytes32 courseName, uint courseECTSPoints);
    event Registered(uint courseNumber, bytes32 courseName);

    /// Create a new course named $(courseName) with a description, a number and a worth of $(courseECTSPoints) ECTS.
    function createCourse(bytes32 courseName, string courseDescription, uint courseNumber, uint courseECTSPoints) onlySupervisor {
    }

    /// Register for course $(courseNumber).
    function registerStudentForCourse(uint courseID) onlyStudent courseExists(courseID) {
    }
}
