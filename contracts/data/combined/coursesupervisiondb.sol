pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../supervisordb.sol";
import "../coursedb.sol";


contract CourseSupervisionDB is ManagedContract {

    struct CourseSupervision {
        address supervisorID;
        uint courseID;
        uint idIndex;
    }

    bytes32[] courseSupervisionIDs;
    mapping(bytes32 => CourseSupervision) courseSupervisions;

    function exists(address supervisorID, uint courseID) public constant returns(bool) {
        return exists(keccak256(supervisorID, courseID));
    }

    function exists(bytes32 id) internal constant returns(bool) {
        if (courseSupervisionIDs.length == 0) {
            return false;
        }
        CourseSupervision memory savedValue = courseSupervisions[id];
        uint savedIDindex = savedValue.idIndex;
        bytes32 savedID = courseSupervisionIDs[savedIDindex];
        return id == savedID;
    }

    function addCourseSupervision(address supervisorID, uint courseID) public {
        bytes32 id = keccak256(supervisorID, courseID);
        require(!exists(id));

        courseSupervisions[id].supervisorID = supervisorID;
        courseSupervisions[id].courseID = courseID;
        courseSupervisions[id].idIndex = courseSupervisionIDs.length;
        courseSupervisionIDs.push(id);

        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address courseDB = ContractProvider(MAN).contracts("coursedb");

        SupervisorDB(supervisorDB).addCourseSupervisionID(supervisorID, id);
        CourseDB(courseDB).addCourseSupervisionID(courseID, id);
    }

    function getCourseSupervisionAt(uint index) public constant returns(address supervisorID, uint courseID) {
        return getCourseSupervision(courseSupervisionIDs[index]);
    }

    function getCourseSupervision(bytes32 id) public constant returns(address supervisorID, uint courseID) {
        require(exists(id));
        return(courseSupervisions[id].supervisorID, courseSupervisions[id].courseID);
    }

}
