CREATE DATABASE LMS;
GO
USE LMS;


CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(50) CHECK (role IN ('student','instructor'))
);

CREATE TABLE Courses (
    course_id INT IDENTITY(1,1) PRIMARY KEY,
    course_name VARCHAR(200) NOT NULL,
    description TEXT,
    instructor_id INT,
    FOREIGN KEY (instructor_id) REFERENCES Users(user_id)
);

CREATE TABLE Lessons (
    lesson_id INT IDENTITY(1,1) PRIMARY KEY,
    course_id INT NOT NULL,
    lesson_title VARCHAR(200) NOT NULL,
    duration_minutes INT,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);


CREATE TABLE Enrollments (
    enrollment_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    status VARCHAR(20) CHECK (status IN ('active','inactive')),
    enrollment_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

CREATE TABLE UserActivity (
    activity_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    lesson_id INT NOT NULL,
    activity_type VARCHAR(50), -- e.g., 'view', 'complete'
    activity_timestamp DATETIME2,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (lesson_id) REFERENCES Lessons(lesson_id)
);

CREATE TABLE Assessments (
    assessment_id INT IDENTITY(1,1) PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(200),
    max_score INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

CREATE TABLE AssessmentSubmissions (
    submission_id INT IDENTITY(1,1) PRIMARY KEY,
    assessment_id INT NOT NULL,
    user_id INT NOT NULL,
    score INT NOT NULL,
    submission_date DATETIME2,
    FOREIGN KEY (assessment_id) REFERENCES Assessments(assessment_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT unique_submission UNIQUE (assessment_id, user_id),
    CONSTRAINT valid_score CHECK (score >= 0)
);


