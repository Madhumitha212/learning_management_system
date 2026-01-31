-- 1.List all users who are enrolled in more than three courses.
SELECT 
    u.user_id,
    u.user_name,
    COUNT(e.course_id) AS total_courses
FROM Enrollments e
JOIN Users u ON e.user_id = u.user_id
GROUP BY u.user_id, u.user_name
HAVING COUNT(e.course_id) > 3;


-- 2.Find courses that currently have no enrollments.
SELECT 
    c.course_id,
    c.course_name
FROM Courses as c
LEFT JOIN Enrollments as e
ON c.course_id = e.course_id
WHERE e.course_id IS NULL

-- 3.Display each course along with the total number of enrolled users
SELECT 
c.course_id,
c.course_name,
COUNT(e.user_id) AS total_users
FROM Courses AS c
INNER JOIN Enrollments AS e
ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name

-- 4.Identify users who enrolled in a course but never accessed any lesson.
SELECT u.user_id, u.user_name 
FROM Users AS u 
INNER JOIN Enrollments AS e 
ON u.user_id = e.user_id 
LEFT JOIN UserActivity AS ua 
ON u.user_id = ua.user_id 
WHERE ua.activity_id IS NULL;

-- 5.Fetch lessons that have never been accessed by any user.
SELECT 
l.lesson_id,
l.lesson_title
FROM Lessons AS l
LEFT JOIN UserActivity AS u
ON l.lesson_id = u.lesson_id
WHERE u.activity_id IS NULL

-- 6.Shows the last activity timestammp for each user
SELECT 
u.user_id,
u.user_name,
MAX(ua.activity_timestamp) AS last_activity
FROM Users AS u
INNER JOIN UserActivity AS ua
ON u.user_id = ua.user_id
GROUP BY u.user_id, u.user_name

/* 7.List users who submitted an assessment but scored less than 50 percent of the 
maximum score. */
SELECT 
    u.user_id, 
    u.user_name,
    assess.score,
    a.max_score
FROM Users AS u
INNER JOIN AssessmentSubmissions AS assess
ON u.user_id = assess.user_id
INNER JOIN Assessments AS a
ON assess.Assessment_id = a.assessment_id
WHERE assess.score < 0.5 * a.max_score

-- 8.Find assessments that have not received any submissions.
SELECT 
    a.assessment_id,
    a.course_id,
    a.title
FROM Assessments AS a
LEFT JOIN AssessmentSubmissions AS s
ON a.assessment_id = s.assessment_id
WHERE s.submission_date IS NULL

-- 9.Display the highest score achieved for each assessment
SELECT assessment_id,
       MAX(score) As Maximum_score
FROM AssessmentSubmissions
GROUP BY assessment_id

-- 10.Identify users who are enrolled in a course but have an inactive enrollment status.
SELECT 
    u.user_id,
    u.user_name,
    e.course_id,
    e.status
FROM Users AS u
INNER JOIN Enrollments AS e
ON u.user_id = e.user_id
WHERE e.status = 'inactive'




















