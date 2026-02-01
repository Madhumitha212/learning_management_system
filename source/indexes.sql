-- Speed up counting users per course
CREATE INDEX idx_enrollments_course
ON Enrollments(course_id);

-- Speed up lesson counts per course
CREATE INDEX idx_lessons_course ON Lessons(course_id);


-- Speed up user-based activity queries
CREATE INDEX idx_activity_user ON UserActivity(user_id);


-- Composite index for joins
CREATE INDEX idx_activity_user_lesson ON UserActivity(user_id, lesson_id);
