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

CREATE OR REPLACE VIEW Registrations AS (
  SELECT student, course, 'waiting' FROM WaitingList
  UNION
  SELECT student, course, 'registered' FROM Registered
);

CREATE OR REPLACE VIEW UnreadMandatory AS (
  (
  SELECT student, course
  FROM Students
  UNION
  SELECT course, branch, program
  FROM MandatoryBranch
  UNION
  SELECT course, program 
  FROM MandatoryProgram
  )
  MINUS 
  SELECT course
  FROM PassedCourses



);