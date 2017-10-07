pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../supervisordb.sol";
import "../coursedb.sol";


contract CourseSupervisionDB is ManagedContract {

    struct CourseSupervision {
        address supervisorID;
        uint courseID;
        uint IDindex;
    }

    bytes32[] IDs;
    mapping (bytes32 => CourseSupervision) courseSupervisions;

    function exists(address supervisorID, uint courseID) public constant returns(bool) {
        return exists(keccak256(supervisorID, courseID));
    }

    function exists(bytes32 ID) internal constant returns(bool) {
        if (IDs.length == 0) {
            return false;
        }
        CourseSupervision memory savedValue = courseSupervisions[ID];
        uint savedIDindex = savedValue.IDindex;
        bytes32 savedID = IDs[savedIDindex];
        return ID == savedID;
    }

    function addCourseSupervision(address supervisorID, uint courseID) public {
        bytes32 ID = keccak256(supervisorID, courseID);
        require(!exists(ID));

        courseSupervisions[ID].supervisorID = supervisorID;
        courseSupervisions[ID].courseID = courseID;
        courseSupervisions[ID].IDindex = IDs.length;
        IDs.push(ID);

        address supervisorDB = ContractProvider(MAN).contracts("supervisordb");
        address courseDB = ContractProvider(MAN).contracts("coursedb");
        
        SupervisorDB(supervisorDB).addCourseSupervisionID(supervisorID, ID);
        CourseDB(courseDB).addCourseSupervisionID(courseID, ID);
    }

    function getCourseSupervisionAt(uint index) public constant returns(address supervisorID, uint courseID) {
        return getCourseSupervision(IDs[index]);
    }

    function getCourseSupervision(bytes32 ID) public constant returns(address supervisorID, uint courseID) {
        require(exists(ID));
        return(courseSupervisions[ID].supervisorID, courseSupervisions[ID].courseID);
    }

}
