--Propose constraints to ensure a user cannot submit the same assessment more than once.
ALTER TABLE AssessmentSubmissions
ADD CONSTRAINT unique_submission_per_user
UNIQUE (assessment_id, user_id);

--Ensure that assessment scores do not exceed the defined maximum score.
CREATE TRIGGER trg_check_score_limit
ON AssessmentSubmissions
AFTER INSERT, UPDATE
AS
BEGIN
    -- Check if any submitted score exceeds the max_score
    IF EXISTS (
        SELECT 1
        FROM AssessmentSubmissions s
        JOIN Assessments a
          ON s.assessment_id = a.assessment_id
        WHERE s.score > a.max_score
    )
    BEGIN
        RAISERROR ('Score exceeds maximum allowed for this assessment', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Prevent users from enrolling in courses that have no lessons.
CREATE TRIGGER trg_prevent_empty_course_enrollment
ON Enrollments
AFTER INSERT
AS
BEGIN
    -- Check if the course has at least one lesson
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1
            FROM Lessons l
            WHERE l.course_id = i.course_id
        )
    )
    BEGIN
        RAISERROR ('Cannot enroll in a course with no lessons', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Ensure that only instructors can create courses.
CREATE TRIGGER trg_only_instructors_create_course
ON Courses
AFTER INSERT
AS
BEGIN
    -- Check if the user creating the course is an instructor
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Users u
          ON i.instructor_id = u.user_id
        WHERE u.role <> 'instructor'
    )
    BEGIN
        RAISERROR ('Only instructors can create courses', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Describe a safe strategy for deleting courses while preserving historical data.
ALTER TABLE Courses
ADD is_active BIT DEFAULT 1;

UPDATE Courses
SET is_active = 0
WHERE course_id = 101;










