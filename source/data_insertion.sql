USE LMS;

DELETE FROM AssessmentSubmissions;
DELETE FROM UserActivity;
DELETE FROM Enrollments;
DELETE FROM Assessments;
DELETE FROM Lessons;
DELETE FROM Courses;
DELETE FROM Users;


DBCC CHECKIDENT ('AssessmentSubmissions', RESEED, 0);
DBCC CHECKIDENT ('UserActivity', RESEED, 0);
DBCC CHECKIDENT ('Enrollments', RESEED, 0);
DBCC CHECKIDENT ('Assessments', RESEED, 0);
DBCC CHECKIDENT ('Lessons', RESEED, 0);
DBCC CHECKIDENT ('Courses', RESEED, 0);
DBCC CHECKIDENT ('Users', RESEED, 0);

CREATE TABLE Users_Stage (
    user_name VARCHAR(100),
    email VARCHAR(100),
    role VARCHAR(50)
);

BULK INSERT Users_Stage
FROM 'D:\learning_management_system\data_set\users.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

INSERT INTO Users (user_name, email, role)
SELECT user_name, email, role
FROM Users_Stage;

DROP TABLE Users_Stage;

CREATE TABLE Courses_Stage (
    course_name VARCHAR(200),
    description TEXT,
    instructor_id INT
);

BULK INSERT Courses_Stage
FROM 'D:\learning_management_system\data_set\courses.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

INSERT INTO Courses (course_name, description, instructor_id)
SELECT course_name, description, instructor_id
FROM Courses_Stage;

DROP table Courses_Stage

SELECT * FROM Courses


CREATE TABLE Lessons_Stage (
    course_id INT,
    lesson_title VARCHAR(200),
    duration_minutes INT
);

BULK INSERT Lessons_Stage
FROM 'D:\learning_management_system\data_set\lessons.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

INSERT INTO Lessons (course_id, lesson_title, duration_minutes)
SELECT course_id, lesson_title, duration_minutes
FROM Lessons_Stage;

DROP table Lessons_Stage;

SELECT * FROM Lessons

CREATE TABLE Enrollments_Stage (
    user_id INT,
    course_id INT,
    status VARCHAR(20),
    enrollment_date DATE
);

BULK INSERT Enrollments_Stage
FROM 'D:\learning_management_system\data_set\enrollments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

INSERT INTO Enrollments (user_id, course_id, status, enrollment_date)
SELECT user_id, course_id, status, enrollment_date
FROM Enrollments_Stage;

DROP TABLE Enrollments_Stage;

CREATE TABLE UserActivity_Stage (
    user_id INT,
    lesson_id INT,
    activity_type VARCHAR(50),
    activity_timestamp VARCHAR(50) -- temporarily as text
);

BULK INSERT UserActivity_Stage
FROM 'D:\learning_management_system\data_set\user_activity.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n'
);

INSERT INTO UserActivity (user_id, lesson_id, activity_type, activity_timestamp)
SELECT 
    user_id,
    lesson_id,
    activity_type,
    activity_timestamp
FROM UserActivity_Stage;

DROP TABLE UserActivity_Stage;

INSERT INTO UserActivity (user_id, lesson_id, activity_type, activity_timestamp)
SELECT *
FROM OPENROWSET(
    BULK 'D:\Task\DataSet_LMS\UserActivity.csv',
    FORMAT='CSV',
    FIRSTROW = 2
) AS DataFile;


SELECT * FROM UserActivity

CREATE TABLE Assessments_Stage (
    course_id INT,
    title VARCHAR(200),
    max_score INT
);

BULK INSERT Assessments_Stage
FROM 'D:\learning_management_system\data_set\assessments.csv'
WITH (
    FIRSTROW = 2,              -- skip header
    FIELDTERMINATOR = ',',     -- comma separated
    ROWTERMINATOR = '\n',      -- newline separated
    TABLOCK
);

SELECT *
FROM Assessments_Stage
WHERE course_id IS NULL OR max_score IS NULL;

INSERT INTO Assessments (course_id, title, max_score)
SELECT course_id, title, max_score
FROM Assessments_Stage
WHERE course_id IS NOT NULL AND max_score IS NOT NULL;

DROP TABLE Assessments_Stage;

SELECT * FROM Assessments;

CREATE TABLE AssessmentSubmissions_Stage (
    assessment_id INT,
    user_id INT,
    score INT,
    submission_date DATETIME2
);

BULK INSERT AssessmentSubmissions_Stage
FROM 'D:\learning_management_system\data_set\assessment_submissions.csv'
WITH (
    FIRSTROW = 2,              -- skip header row
    FIELDTERMINATOR = ',',     -- comma separated
    ROWTERMINATOR = '\n',      -- newline separated
    TABLOCK
);

SELECT *
FROM AssessmentSubmissions_Stage
WHERE assessment_id IS NULL OR user_id IS NULL OR score IS NULL;

INSERT INTO AssessmentSubmissions (assessment_id, user_id, score, submission_date)
SELECT assessment_id, user_id, score, submission_date
FROM AssessmentSubmissions_Stage;

DROP TABLE AssessmentSubmissions_Stage;

SELECT * FROM AssessmentSubmissions;





