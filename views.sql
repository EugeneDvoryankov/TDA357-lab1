CREATE OR REPLACE VIEW BasicInformation AS (
  SELECT idnr, name, login, students.program, branch
  FROM students
  LEFT JOIN studentbranches ON idnr=student
);

CREATE OR REPLACE VIEW FinishedCourses AS (
  SELECT student, course, grade, credits
  FROM students
  JOIN taken ON idnr=student
  JOIN courses ON code=course
);

CREATE OR REPLACE VIEW PassedCourses AS (
  SELECT student, course, credits
  FROM FinishedCourses
  WHERE grade != 'U'
);

/*
VIEW MandatoryCourses:
1.  (Choose all courses a student can read) INTERSECT (All courses a student must read in a BRANCH) 
    (A cartesian intersect B) 
2. (Choose all courses a student can read) INTERSECT (All courses a student must read in a PROGRAM)
    (A cartesian intersect P)
3.  (Choose all courses a student must read with a branch and within program)
    (A cartesian intersect B) UNION (A cartesian intersect P)
*/
CREATE OR REPLACE VIEW MandatoryCourses AS(
  SELECT BasicInformation.idnr, BasicInformation.branch, BasicInformation.program, course
  FROM BasicInformation
  JOIN MandatoryBranch USING (branch, program)
  UNION
  SELECT BasicInformation.idnr, BasicInformation.branch, BasicInformation.program, course
  FROM BasicInformation
  JOIN MandatoryProgram USING (program)
);

/**
Choose all the courses a student must read
EXCEPT for 
all the courses a student have passed
**/
CREATE OR REPLACE VIEW UnreadMandatory AS (
  SELECT students.idnr AS student, course
  FROM Students
  JOIN MandatoryCourses USING (idnr)
  EXCEPT
  SELECT student, course
  FROM PassedCourses
);
