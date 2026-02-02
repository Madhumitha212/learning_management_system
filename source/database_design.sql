--Propose schema changes to support course completion certificates.

CREATE TABLE Certificates (
    CertificateID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CourseID INT NOT NULL,
    IssuedDate DATE DEFAULT GETDATE(),
    CertificateURL VARCHAR(255),

    CONSTRAINT FK_Cert_User
        FOREIGN KEY (UserID) REFERENCES Users(UserID),

    CONSTRAINT FK_Cert_Course
        FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),

    CONSTRAINT UQ_User_Course
        UNIQUE (UserID, CourseID)
);

CREATE PROCEDURE IssueCertificate
    @UserID INT,
    @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @TotalLessons INT,
        @CompletedLessons INT,
        @TotalAssessments INT,
        @CompletedAssessments INT;

    -- 1. Total lessons in course
    SELECT @TotalLessons = COUNT(*)
    FROM Lessons
    WHERE CourseID = @CourseID;

    -- 2. Lessons accessed by user
    SELECT @CompletedLessons = COUNT(DISTINCT UA.LessonID)
    FROM UserActivity UA
    JOIN Lessons L ON UA.LessonID = L.LessonID
    WHERE UA.UserID = @UserID
      AND L.CourseID = @CourseID;

    -- 3. Total assessments in course
    SELECT @TotalAssessments = COUNT(*)
    FROM Assessments
    WHERE CourseID = @CourseID;

    -- 4. Assessments submitted by user
    SELECT @CompletedAssessments = COUNT(DISTINCT S.AssessmentID)
    FROM AssessmentSubmissions S
    JOIN Assessments A ON S.AssessmentID = A.AssessmentID
    WHERE S.UserID = @UserID
      AND A.CourseID = @CourseID;

    -- 5. Check completion condition
    IF @CompletedLessons = @TotalLessons
       AND @CompletedAssessments = @TotalAssessments
    BEGIN
        -- 6. Insert certificate if not exists
        IF NOT EXISTS (
            SELECT 1 
            FROM Certificates 
            WHERE UserID = @UserID 
              AND CourseID = @CourseID
        )
        BEGIN
            INSERT INTO Certificates (UserID, CourseID, CertificateURL)
            VALUES (
                @UserID,
                @CourseID,
                CONCAT(
                    'https://lms.com/certificates/',
                    @UserID, '_', @CourseID
                )
            );

            PRINT 'Certificate issued successfully';
        END
        ELSE
            PRINT 'Certificate already exists';
    END
    ELSE
        PRINT 'Course not yet completed';
END;

EXEC IssueCertificate @UserID = 101, @CourseID = 5;

--Describe how you would track video progress efficiently at scale.
/* =========================================================
   VIDEO PROGRESS TRACKING – SCALABLE LMS DESIGN (MSSQL)
   ========================================================= */

------------------------------------------------------------
-- 1. Create VideoProgress Table
------------------------------------------------------------
CREATE TABLE VideoProgress (
    ProgressID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    LessonID INT NOT NULL,
    ProgressPercent DECIMAL(5,2)
        CHECK (ProgressPercent BETWEEN 0 AND 100),
    LastUpdated DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Video_User
        FOREIGN KEY (UserID) REFERENCES Users(UserID),

    CONSTRAINT FK_Video_Lesson
        FOREIGN KEY (LessonID) REFERENCES Lessons(LessonID),

    CONSTRAINT UQ_User_Lesson
        UNIQUE (UserID, LessonID)
);
GO

------------------------------------------------------------
-- 2. Create Index for Performance
------------------------------------------------------------
CREATE INDEX idx_videoprogress_user_lesson
ON VideoProgress (UserID, LessonID);
GO

------------------------------------------------------------
-- 3. Insert Initial Progress (First Time Watching)
------------------------------------------------------------
INSERT INTO VideoProgress (UserID, LessonID, ProgressPercent)
VALUES (101, 12, 10.00);
GO

------------------------------------------------------------
-- 4. Update Video Progress (Resume / Pause / Seek)
------------------------------------------------------------
UPDATE VideoProgress
SET ProgressPercent = 65.50,
    LastUpdated = GETDATE()
WHERE UserID = 101
  AND LessonID = 12;
GO

------------------------------------------------------------
-- 5. Mark Lesson as Completed
------------------------------------------------------------
UPDATE VideoProgress
SET ProgressPercent = 100.00,
    LastUpdated = GETDATE()
WHERE UserID = 101
  AND LessonID = 12;
GO

------------------------------------------------------------
-- 6. Check Lesson Completion Status
------------------------------------------------------------
SELECT 
    CASE 
        WHEN ProgressPercent = 100 THEN 'Completed'
        ELSE 'In Progress'
    END AS LessonStatus
FROM VideoProgress
WHERE UserID = 101
  AND LessonID = 12;
GO

------------------------------------------------------------
-- 7. View All Lesson Progress for a User (Dashboard)
------------------------------------------------------------
SELECT 
    L.LessonTitle,
    VP.ProgressPercent,
    VP.LastUpdated
FROM VideoProgress VP
JOIN Lessons L ON VP.LessonID = L.LessonID
WHERE VP.UserID = 101;
GO

------------------------------------------------------------
-- 8. Check Course Completion Using Video Progress
------------------------------------------------------------
SELECT 
    COUNT(*) AS TotalLessons,
    SUM(CASE 
            WHEN VP.ProgressPercent = 100 THEN 1 
            ELSE 0 
        END) AS CompletedLessons
FROM Lessons L
LEFT JOIN VideoProgress VP
       ON L.LessonID = VP.LessonID
      AND VP.UserID = 101
WHERE L.CourseID = 5;
GO
