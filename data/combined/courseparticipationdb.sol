pragma solidity ^0.4.0;

import "../../contractmanager.sol";
import "../studentdb.sol";
import "../coursedb.sol";


contract CourseParticipationDB is ManagedContract {

    struct CourseParticipation {
        address studentID;
        uint courseID;
    }

    CourseParticipation[] courseParticipations;

    function exists(uint id) public constant returns(bool) {
        return courseParticipations.length > id;
    }

    function addCourseParticipation(address studentID, uint courseID) public {
        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address courseDB = ContractProvider(MAN).contracts("coursedb");
        
        StudentDB(studentDB).addCourseParticipationID(studentID, courseParticipations.length);
        CourseDB(courseDB).addCourseParticipationID(courseID, courseParticipations.length);
        
        courseParticipations.push(CourseParticipation(studentID, courseID));
    }

    function getCourseParticipation(uint id) public constant returns(address studentID, uint courseID) {
        require(exists(id));
        return(courseParticipations[id].studentID, courseParticipations[id].courseID);
    }
}
