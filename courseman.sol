pragma solidity ^0.4.0;


library AddressMap {
    struct Data {
        address[] data;
        mapping (address => uint) indices;
    }

    function add(Data storage self, address value) {
        uint index = self.data.length++;
        self.indices[value] = index;
        self.data[index] = value;
    }

    function contains(Data storage self, address value) constant returns(bool) {
        uint index = self.indices[value];
        if (index == 0 && (self.data.length == 0 || self.data[index] != value)) {
            return false;
        } else {
            return true;
        }
    }
}


contract CourseMan {

    using AddressMap for AddressMap.Data;
    struct Course {
        string name;
        uint number;
        uint ectsPoints;

        address supervisor;
        AddressMap.Data participators;
    }

    Course[] courses;

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

    modifier courseExists(uint courseNumber) {
        require(courses.length > courseNumber);
        _;
    }

    event Created(uint courseNumber, string courseName, uint courseECTSPoints);
    event Registered(uint courseNumber, string courseName);

    /// Create a new course named $(courseName) and worth $(courseECTSPoints).
    function createCourse(string courseName, uint courseECTSPoints) onlySupervisor {
        uint courseNumber = courses.length++;

        // Reference/rename "new" course in list for convenience
        // and write all values
        Course storage c = courses[courseNumber];
        c.name = courseName;
        c.number = courseNumber;
        c.ectsPoints = courseECTSPoints;
        c.supervisor = msg.sender;

        Created(c.number, c.name, c.ectsPoints);
    }

    /// Register for course $(courseNumber).
    function registerStudentForCourse(uint courseNumber) onlyStudent courseExists(courseNumber) {
        Course storage c = courses[courseNumber];
        if (c.participators.contains(msg.sender) == false) {
            c.participators.add(msg.sender);

            Registered(c.number, c.name);
        }
    }

    /// Displays the number of all available courses.
    /// Call getCourseDetails with a number between 0 and the returned value
    /// to get more information on a specific course.
    function getNumberOfCourses() constant returns(uint) {
        return courses.length;
    }

    /// Show details for course $(courseNumber).
    function getCourseDetails(uint courseNumber) courseExists(courseNumber) constant returns(string, uint, uint, address, address[]) {
        Course storage c = courses[courseNumber];
        return (c.name, c.number, c.ectsPoints, c.supervisor, c.participators.data);
    }
}
