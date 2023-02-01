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

CREATE OR REPLACE VIEw Registrations AS (
  SELECT student, course, 'registered' AS status FROM Registered
  UNION 
  SELECT student, course, 'waiting' AS status FROM WaitingList
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

-- Välj mängden av alla kurser man kan läsa i en branch = A
-- Välj möngden av alla kurser man MÅSTE läsa i en branch = B
-- A EXCEPT B
CREATE OR REPLACE VIEW RecommendedCourses AS(
  -- alla kurser man har läst
  -- Cartesisk INTERSECT
  -- alla kurser som ska läsa
  SELECT student, PassedCourses.course, credits
  FROM PassedCourses
  JOIN BasicInformation ON PassedCourses.student=BasicInformation.idnr
  JOIN RecommendedBranch ON RecommendedBranch.course = PassedCourses.course
  AND RecommendedBranch.program=BasicInformation.program
  AND RecommendedBranch.branch = BasicInformation.branch
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

CREATE OR REPLACE VIEW TotalCredits AS (
  SELECT student, SUM(credits) AS totalCredits
  FROM PassedCourses
  GROUP BY student
);

CREATE OR REPLACE VIEW MandatoryLeft AS (
  SELECT student, COUNT(course) AS mandatoryLeft
  FROM UnreadMandatory
  GROUP BY student
);

CREATE OR REPLACE VIEW MathCredits AS (
  SELECT student, SUM(credits) AS mathCredits
  FROM PassedCourses
  JOIN Classified USING (course)
  WHERE classification='math'
  GROUP BY student, classification
);

CREATE OR REPLACE VIEW ResearchCredits AS (
  SELECT student, SUM(credits) AS researchCredits
  FROM PassedCourses
  JOIN Classified USING (course)
  WHERE classification='research'
  GROUP BY student, classification
);

CREATE OR REPLACE VIEW SeminarCourses AS (
  SELECT student, COUNT(course) AS seminarCourses
  FROM PassedCourses
  JOIN Classified USING (course)
  WHERE classification='seminar'
  GROUP BY student, classification
);

CREATE OR REPLACE VIEW RecommendedBranchCredits AS (
  SELECT student, SUM(credits) AS recommendedBranchCredits
  FROM RecommendedCourses
  GROUP BY student
);

--PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified)
CREATE OR REPLACE VIEW PathToGraduation AS(
  SELECT idnr AS student, 
  COALESCE(totalCredits, 0) AS totalCredits, 
  COALESCE(mandatoryLeft, 0) AS mandatoryLeft, 
  COALESCE(mathCredits, 0) AS mathCredits,
  COALESCE(researchCredits, 0) AS researchCredits,
  COALESCE(seminarCourses, 0) AS seminarCourses,
  BasicInformation.branch IS NOT NULL
  AND COALESCE(mandatoryLeft, 0) = 0
  AND COALESCE(recommendedBranchCredits, 0) >= 10
  AND COALESCE(mathCredits, 0) >= 20
  AND COALESCE(researchCredits, 0) >= 10
  AND COALESCE(seminarCourses, 0) >= 1
  AS qualified
  FROM BasicInformation
  LEFT JOIN TotalCredits ON idnr=TotalCredits.student
  LEFT JOIN MandatoryLeft ON idnr=MandatoryLeft.student
  LEFT JOIN MathCredits ON idnr=MathCredits.student
  LEFT JOIN ResearchCredits ON idnr=ResearchCredits.student
  LEFT JOIN SeminarCourses ON idnr=SeminarCourses.student
  LEFT JOIN RecommendedBranchCredits ON idnr=RecommendedBranchCredits.student
);