pragma solidity ^0.4.0;

import "../manager/contractmanager.sol";
import "../data/assessmentdb.sol";
import "../data/assignmentdb.sol";
import "../data/coursedb.sol";
import "../data/studentdb.sol";
import "../data/submissiondb.sol";
import "../data/supervisordb.sol";
import "../data/testdb.sol";
import "../data/combined/courseparticipationdb.sol";
import "../data/combined/coursesupervisiondb.sol";
import "../data/combined/studentsubmissiondb.sol";
import "../data/combined/supervisorassessmentdb.sol";
import "../data/combined/testparticipationdb.sol";
import "../data/combined/testsupervisiondb.sol";


contract UniTester {
    address contractManagerAddress;
    
    address assessmentDBAddress;
    address assignmentDBAddress;
    address courseDBAddress;
    address studentDBAddress;
    address submissionDBAddress;
    address supervisorDBAddress;
    address testDBAddress;
    
    address courseParticipationDBAddress;
    address courseSupervisionDBAddress;
    address studentSubmissionDBAddress;
    address supervisorAssessmentDBAddress;
    address testParticipationDBAddress;
    address testSupervisionDBAddress;

    function UniTester() {
        contractManagerAddress = new ContractManager();

        assessmentDBAddress = new AssessmentDB();
        assignmentDBAddress = new AssignmentDB();
        courseDBAddress = new CourseDB();
        studentDBAddress = new StudentDB();
        submissionDBAddress = new SubmissionDB();
        supervisorDBAddress = new SupervisorDB();
        testDBAddress = new TestDB();
        
        courseParticipationDBAddress = new CourseParticipationDB();
        courseSupervisionDBAddress = new CourseSupervisionDB();
        studentSubmissionDBAddress = new StudentSubmissionDB();
        supervisorAssessmentDBAddress = new SupervisorAssessmentDB();
        testParticipationDBAddress = new TestParticipationDB();
        testSupervisionDBAddress = new TestSupervisionDB();
    }

    function setContractManager() {
        AssessmentDB(assessmentDBAddress).setContractManagerAddress(contractManagerAddress);
        AssignmentDB(assignmentDBAddress).setContractManagerAddress(contractManagerAddress);
        CourseDB(courseDBAddress).setContractManagerAddress(contractManagerAddress);
        StudentDB(studentDBAddress).setContractManagerAddress(contractManagerAddress);
        SubmissionDB(submissionDBAddress).setContractManagerAddress(contractManagerAddress);
        SupervisorDB(supervisorDBAddress).setContractManagerAddress(contractManagerAddress);
        TestDB(testDBAddress).setContractManagerAddress(contractManagerAddress);

        CourseParticipationDB(courseParticipationDBAddress).setContractManagerAddress(contractManagerAddress);
        CourseSupervisionDB(courseSupervisionDBAddress).setContractManagerAddress(contractManagerAddress);
        StudentSubmissionDB(studentSubmissionDBAddress).setContractManagerAddress(contractManagerAddress);
        SupervisorAssessmentDB(supervisorAssessmentDBAddress).setContractManagerAddress(contractManagerAddress);
        TestParticipationDB(testParticipationDBAddress).setContractManagerAddress(contractManagerAddress);
        TestSupervisionDB(testSupervisionDBAddress).setContractManagerAddress(contractManagerAddress);
    }

    function registerContracts() {
        ContractManager(contractManagerAddress).addContract("assessmentdb", assessmentDBAddress);
        ContractManager(contractManagerAddress).addContract("assignmentdb", assignmentDBAddress);
        ContractManager(contractManagerAddress).addContract("coursedb", courseDBAddress);
        ContractManager(contractManagerAddress).addContract("studentdb", studentDBAddress);
        ContractManager(contractManagerAddress).addContract("submissiondb", submissionDBAddress);
        ContractManager(contractManagerAddress).addContract("supervisordb", supervisorDBAddress);
        ContractManager(contractManagerAddress).addContract("testdb", testDBAddress);
        
        ContractManager(contractManagerAddress).addContract("courseparticipationdb", courseParticipationDBAddress);
        ContractManager(contractManagerAddress).addContract("coursesupervisiondb", courseSupervisionDBAddress);
        ContractManager(contractManagerAddress).addContract("studentsubmissiondb", studentSubmissionDBAddress);
        ContractManager(contractManagerAddress).addContract("supervisorassessmentdb", supervisorAssessmentDBAddress);
        ContractManager(contractManagerAddress).addContract("testparticipationdb", testParticipationDBAddress);
        ContractManager(contractManagerAddress).addContract("testsupervisiondb", testSupervisionDBAddress);
    }
}
