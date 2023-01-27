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

-- Välj (alla kurser som en elev har läst) SNITT (alla kurser en elev måste läsa) = A SNITT B = C
-- B = (B1 UNION B2)
-- Alla kurser som man måste läsa i sin program UNION alla kurser man måste läsa i sin master
-- Välj (alla kurser en måste läsa) FÖRUTOM SNITTET C = B \ C = 
-- B \ (A snitt B)
-- som en elev måste läsa och 
-- 
CREATE OR REPLACE VIEW MandatoryCourse(
  SELECT MandatoryBranch.course, MandatoryBranch.branch, MandatoryBranch.program
  FROM MandatoryBranch
  FULL OUTER JOIN MandatoryProgram ON (MandatoryBranch.course=MandatoryProgram.course 
  AND MandatoryBranch.program = MandatoryProgram.program)
);


CREATE OR REPLACE VIEW Registrations AS (
  SELECT student, course, 'waiting' AS status FROM WaitingList
  UNION
  SELECT student, course, 'registered' AS status FROM Registered
);

-- Step 1: Create a Cartesian product of PassedCourse, MandatoryProgram and MandatoryBranch

/*
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
*/