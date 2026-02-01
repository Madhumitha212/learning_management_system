/*For each course, calculate:
1.Total number of enrolled users
2.Total number of lessons
3.Average lesson duration*/

 SELECT 
    e.course_id,
    COUNT(DISTINCT e.user_id) AS tot_nr_users,
    COUNT(DISTINCT l.lesson_id) AS tot_nr_lessons,
    AVG(l.duration_minutes) AS avg_duration
FROM Enrollments e
LEFT JOIN Lessons l 
    ON e.course_id = l.course_id
GROUP BY e.course_id;

-- 2.Identify the top three most active users based on total activity count.
SELECT TOP 3
u.user_id,
u.user_name,
COUNT(ua.activity_id) AS total_active_count
FROM Users AS u
INNER JOIN UserActivity AS ua
ON u.user_id = ua.user_id
GROUP BY u.user_id, u.user_name
ORDER BY total_active_count DESC

--3.Calculate course completion percentage per user based on lesson activity.
SELECT 
    u.user_id,
    u.user_name,
    c.course_id,
    c.course_name,
    COUNT(DISTINCT CASE WHEN ua.activity_type = 'complete' THEN ua.lesson_id END) AS lessons_completed,
    COUNT(DISTINCT l.lesson_id) AS total_lessons,
    (COUNT(DISTINCT CASE WHEN ua.activity_type = 'complete' THEN ua.lesson_id END) * 100.0 
        / NULLIF(COUNT(DISTINCT l.lesson_id),0)) AS completion_percentage
FROM Enrollments e
JOIN Users u ON e.user_id = u.user_id
JOIN Courses c ON e.course_id = c.course_id
JOIN Lessons l ON c.course_id = l.course_id
LEFT JOIN UserActivity ua ON u.user_id = ua.user_id AND l.lesson_id = ua.lesson_id
WHERE e.status = 'active'
GROUP BY u.user_id, u.user_name, c.course_id, c.course_name
ORDER BY c.course_id, u.user_id;


-- 4.Find users whose average assessment score is higher than the course average.
WITH CTE_AVG_SCORE AS(
    SELECT 
    a.course_id,
    AVG(a.max_score) AS course_avg
    FROM Assessments AS a
    INNER JOIN Assessments AS s
    ON a.assessment_id = s.assessment_id
    GROUP BY a.course_id
),

user_avg_score AS(
    SELECT u.user_id,
           u.user_name,
           a.course_id,
           AVG(s.score) AS user_avg
    FROM Assessments AS a
    INNER JOIN AssessmentSubmissions AS s
    ON a.assessment_id = s.assessment_id
    JOIN Users u 
    ON s.user_id = u.user_id 
    GROUP BY u.user_id, u.user_name, a.course_id )

SELECT 
    ua.user_id,
    ua.user_name,
    ua.course_id,
    ua.user_avg,
    cavg.course_avg
FROM CTE_AVG_SCORE AS cavg
INNER JOIN user_avg_score AS ua
ON ua.course_id = cavg.course_id
WHERE ua.user_avg > cavg.course_avg



--5.List courses where lessons are frequently accessed but assessments are never attempted.
SELECT DISTINCT c.course_id, c.course_name 
FROM Courses c 
JOIN Lessons l ON c.course_id = l.course_id 
JOIN UserActivity ua ON ua.lesson_id = l.lesson_id 
WHERE NOT EXISTS ( 
    SELECT 1 
    FROM Assessments a 
    JOIN AssessmentSubmissions s 
    ON a.assessment_id = s.assessment_id 
    WHERE a.course_id = c.course_id );


-- 6.Rank users within each course based on their total assessment score.
WITH UserScores AS (
    SELECT 
        u.user_id,
        u.user_name,
        a.course_id,
        SUM(s.score) AS total_score
    FROM AssessmentSubmissions s
    JOIN Users u ON s.user_id = u.user_id
    JOIN Assessments a ON s.assessment_id = a.assessment_id
    JOIN Courses c ON a.course_id = c.course_id
    GROUP BY u.user_id, u.user_name, a.course_id
)
SELECT 
    user_id,
    user_name,
    course_id,
    total_score,
    RANK() OVER (PARTITION BY course_id ORDER BY total_score DESC) AS user_rank
FROM UserScores;


-- 7.Identify the first lesson accessed by each user for every course.
WITH LessonAccess AS (
    SELECT 
        u.user_id,
        u.user_name,
        c.course_id,
        c.course_name,
        l.lesson_id,
        l.lesson_title,
        ua.activity_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY u.user_id, c.course_id 
            ORDER BY ua.activity_timestamp ASC
        ) AS rn
    FROM UserActivity ua
    JOIN Users u ON ua.user_id = u.user_id
    JOIN Lessons l ON ua.lesson_id = l.lesson_id
    JOIN Courses c ON l.course_id = c.course_id
)
SELECT 
    user_id,
    user_name,
    course_id,
    course_name,
    lesson_id,
    lesson_title,
    activity_timestamp AS first_access_time
FROM LessonAccess
WHERE rn = 1;

--8.Find users with activity recorded on at least five consecutive days.
WITH DistinctActivityDates AS (
    SELECT 
        user_id,
        CAST(activity_timestamp AS DATE) AS activity_date
    FROM UserActivity
    GROUP BY user_id, CAST(activity_timestamp AS DATE)
),
RankedDates AS (
    SELECT 
        user_id,
        activity_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY activity_date) AS rn
    FROM DistinctActivityDates
),
GroupedStreaks AS (
    SELECT 
        user_id,
        activity_date,
        DATEADD(DAY, -rn, activity_date) AS streak_group
    FROM RankedDates
)
SELECT 
    user_id,
    MIN(activity_date) AS streak_start,
    MAX(activity_date) AS streak_end,
    COUNT(*) AS streak_length
FROM GroupedStreaks
GROUP BY user_id, streak_group
HAVING COUNT(*) >= 5
ORDER BY user_id, streak_start;

--9.Retrieve users who enrolled in a course but never submitted any assessment.
SELECT u.user_id, u.user_name, u.email, e.course_id
FROM Users u
JOIN Enrollments e ON u.user_id = e.user_id
WHERE NOT EXISTS (
    SELECT 1
    FROM AssessmentSubmissions s
    JOIN Assessments a ON s.assessment_id = a.assessment_id
    WHERE s.user_id = u.user_id
      AND a.course_id = e.course_id
);

--10.List courses where every enrolled user has submitted at least one assessment.
SELECT c.course_id, c.course_name
FROM Courses c
JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
HAVING COUNT(*) = (
    SELECT COUNT(DISTINCT s.user_id)
    FROM AssessmentSubmissions s
    JOIN Assessments a ON s.assessment_id = a.assessment_id
    WHERE a.course_id = c.course_id
);










USE lms;

SELECT * FROM Users

SELECT * FROM Courses

SELECT * FROM Enrollments

SELECT * FROM Lessons

SELECT * FROM UserActivity

SELECT * FROM Assessments

SELECT * FROM AssessmentSubmissions



