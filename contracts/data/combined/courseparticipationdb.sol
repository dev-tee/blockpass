pragma solidity ^0.4.3;

import "../../manager/contractmanager.sol";
import "../studentdb.sol";
import "../coursedb.sol";


contract CourseParticipationDB is ManagedContract {

    struct CourseParticipation {
        address studentID;
        uint courseID;
        uint idIndex;
    }

    bytes32[] courseParticipationIDs;
    mapping(bytes32 => CourseParticipation) courseParticipations;

    function exists(address studentID, uint courseID) public constant returns(bool) {
        return exists(keccak256(studentID, courseID));
    }

    function exists(bytes32 id) internal constant returns(bool) {
        if (courseParticipationIDs.length == 0) {
            return false;
        }
        CourseParticipation memory savedValue = courseParticipations[id];
        uint savedIDIndex = savedValue.idIndex;
        bytes32 savedID = courseParticipationIDs[savedIDIndex];
        return id == savedID;
    }

    function addCourseParticipation(address studentID, uint courseID) public {
        bytes32 id = keccak256(studentID, courseID);
        require(!exists(id));

        courseParticipations[id].studentID = studentID;
        courseParticipations[id].courseID = courseID;
        courseParticipations[id].idIndex = courseParticipationIDs.length;
        courseParticipationIDs.push(id);

        address studentDB = ContractProvider(MAN).contracts("studentdb");
        address courseDB = ContractProvider(MAN).contracts("coursedb");

        StudentDB(studentDB).addCourseParticipationID(studentID, id);
        CourseDB(courseDB).addCourseParticipationID(courseID, id);
    }

    function getCourseParticipationAt(uint index) public constant returns(address studentID, uint courseID) {
        return getCourseParticipation(courseParticipationIDs[index]);
    }

    function getCourseParticipation(bytes32 id) public constant returns(address studentID, uint courseID) {
        require(exists(id));
        return(courseParticipations[id].studentID, courseParticipations[id].courseID);
    }
}
