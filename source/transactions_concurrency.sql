--Design a transaction flow for enrolling a user into a course.
BEGIN TRANSACTION;

IF EXISTS (SELECT 1 FROM Courses WHERE course_id = @CourseId)
   AND NOT EXISTS (SELECT 1 FROM Enrollments WHERE user_id = @UserId AND course_id = @CourseId)
BEGIN
    INSERT INTO Enrollments (user_id, course_id, enrollment_date, status)
    VALUES (@UserId, @CourseId, GETDATE(), 'active');
    COMMIT TRANSACTION;
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
END

--Explain how to handle concurrent assessment submissions safely.

ALTER TABLE AssessmentSubmissions
ADD CONSTRAINT unique_submission UNIQUE (assessment_id, user_id);

BEGIN TRANSACTION;

-- Lock the row for this user/assessment
SELECT * 
FROM AssessmentSubmissions WITH (UPDLOCK, HOLDLOCK)
WHERE assessment_id = @AssessmentId AND user_id = @UserId;

-- Safe insert
INSERT INTO AssessmentSubmissions (assessment_id, user_id, score, submission_date)
VALUES (@AssessmentId, @UserId, @Score, GETDATE());

COMMIT TRANSACTION;

--Describe how partial failures should be handled during assessment submission.
BEGIN TRANSACTION;

BEGIN TRY
    -- Insert the submission into AssessmentSubmissions
    INSERT INTO AssessmentSubmissions (assessment_id, user_id, score, submission_date)
    VALUES (@AssessmentId, @UserId, @Score, GETDATE());

    -- Record the activity in UserActivity
    INSERT INTO UserActivity (user_id, lesson_id, activity_type, activity_timestamp)
    VALUES (@UserId, @LessonId, 'assessment_submission', GETDATE());

    -- If both inserts succeed, commit the transaction
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- If any error occurs, rollback the transaction
    ROLLBACK TRANSACTION;

    -- Log error details (example: insert into an error log table)
    INSERT INTO ErrorLog (error_message, error_time)
    VALUES (ERROR_MESSAGE(), GETDATE());
END CATCH;

