pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../coursedb.sol";


contract CourseParticipationDB is ManagedContract {

    struct CourseParticipation {
        address studentID;
        uint courseID;
        uint IDindex;
    }

    bytes32[] IDs;
    mapping(bytes32 => CourseParticipation) courseParticipations;

    function exists(address studentID, uint courseID) public constant returns(bool) {
        return exists(keccak256(studentID, courseID));
    }

    function exists(bytes32 ID) internal constant returns(bool) {
        if (IDs.length == 0) {
            return false;
        }
        CourseParticipation memory savedValue = courseParticipations[ID];
        uint savedIDindex = savedValue.IDindex;
        bytes32 savedID = IDs[savedIDindex];
        return ID == savedID;
    }

    function addCourseParticipation(address studentID, uint courseID) public {
        bytes32 ID = keccak256(studentID, courseID);
        require(!exists(ID));

        courseParticipations[ID].studentID = studentID;
        courseParticipations[ID].courseID = courseID;
        courseParticipations[ID].IDindex = IDs.length;
        IDs.push(ID);

        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address courseDB = ContractProvider(MAN).contracts("coursedb");

        StudentDB(studentDB).addCourseParticipationID(studentID, ID);
        CourseDB(courseDB).addCourseParticipationID(courseID, ID);
    }

    function getCourseParticipationAt(uint index) public constant returns(address studentID, uint courseID) {
        return getCourseParticipation(IDs[index]);
    }

    function getCourseParticipation(bytes32 ID) public constant returns(address studentID, uint courseID) {
        require(exists(ID));
        return(courseParticipations[ID].studentID, courseParticipations[ID].courseID);
    }
}
