CREATE TABLE Students(
    idnr CHAR(10),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(idnr)
);

CREATE TABLE Branches(
    name TEXT,
    program TEXT,
    PRIMARY KEY(name, program)
);

CREATE TABLE Courses(
    code CHAR(6),
    name TEXT NOT NULL,
    credits FLOAT NOT NULL CHECK (credits > 0),
    department TEXT NOT NULL,
    PRIMARY KEY(code)
);

CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY,
    capacity INT NOT NULL CHECK (capacity > 0),
    FOREIGN KEY(code) REFERENCES Courses
);

CREATE TABLE StudentBranches(
    student CHAR(10) PRIMARY KEY,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY(student) REFERENCES Students,
    FOREIGN KEY(branch, program) REFERENCES Branches
);

CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified(
    course CHAR(6),
    classification TEXT,
    PRIMARY KEY(course, classification)
    FOREIGN KEY(course) REFERENCES Courses,
    FOREIGN KEY(classification) REFERENCES Classifications
);

CREATE TABLE MandatoryProgram(
    course CHAR(6),
    program TEXT,
    PRIMARY KEY(course, program)
    FOREIGN KEY(course) REFERENCES Courses
);

CREATE TABLE MandatoryBranch(
    course CHAR(6),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course, branch, program)
    FOREIGN KEY(course) REFERENCES Courses
    FOREIGN KEY(branch, program) REFERENCES Branches
);

CREATE TABLE RecommendedBranch(
    course CHAR(6),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course, branch, program)
    FOREIGN KEY(course) REFERENCES Courses
    FOREIGN KEY(branch, program) REFERENCES Branches
);

CREATE TABLE Registered(
    student CHAR(10),
    course CHAR(6),
    PRIMARY KEY(student, course)
    FOREIGN KEY(student) REFERENCES Students
    FOREIGN KEY(course) REFERENCES Courses
);

CREATE TABLE Taken(
    student CHAR(10),
    course CHAR(6),
    grade CHAR(1),
    PRIMARY KEY(student, course)
    CONSTRAINT okgrade CHECK (grade IN ('U','3','4','5'))
    FOREIGN KEY(student) REFERENCES Students
    FOREIGN KEY(course) REFERENCES Courses
);

CREATE TABLE WaitingList (
    student TEXT,
    course CHAR(6),
    position SERIAL UNIQUE,
    PRIMARY KEY(student, course),
    FOREIGN KEY(student) REFERENCES Students,
    FOREIGN KEY(course) REFERENCES Limitedcourses,
);