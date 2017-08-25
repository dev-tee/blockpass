pragma solidity ^0.4.0;

import "../../contractmanager.sol";
import "../supervisordb.sol";
import "../coursedb.sol";


contract CourseSupervisionDB is ManagedContract {

    struct CourseSupervision {
        address supervisorID;
        uint courseID;
    }

    CourseSupervision[] courseSupervisions;

    function exists(uint id) public constant returns(bool) {
        return courseSupervisions.length > id;
    }

    function addCourseSupervision(address supervisorID, uint courseID) public {
        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address courseDB = ContractProvider(MAN).contracts("coursedb");
        
        SupervisorDB(supervisorDB).addCourseSupervisionID(supervisorID, courseSupervisions.length);
        CourseDB(courseDB).addCourseSupervisionID(courseID, courseSupervisions.length);
        
        courseSupervisions.push(CourseSupervision(supervisorID, courseID));
    }

    function getCourseSupervision(uint id) public constant returns(address supervisorID, uint courseID) {
        require(exists(id));
        return(courseSupervisions[id].supervisorID, courseSupervisions[id].courseID);
    }
}
