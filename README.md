# 📘 Learning Management System (LMS) SQL Project

## Overview
This project implements a **Learning Management System (LMS)** database using **Microsoft SQL Server (T‑SQL)**.  
It demonstrates how to enforce **data integrity**, design **transaction flows**, and build **analytics queries** for user activity, enrollments, and assessments.

The schema includes:
- **Users**: learners and instructors
- **Courses**: contain lessons and assessments
- **Lessons**: learning units within courses
- **Enrollments**: users enrolled in courses
- **UserActivity**: tracks lesson interactions
- **Assessments**: tests linked to courses
- **AssessmentSubmissions**: user submissions with scores

---

## 🛠️ Technologies Used 
- **Database:** Microsoft SQL Server (T‑SQL) 
- **Schema Design:** Normalized relational schema for LMS 
- **SQL Features:** 
    - Constraints (UNIQUE, FOREIGN KEY, CHECK) 
    - Triggers (`AFTER INSERT`, `AFTER UPDATE`) 
    - Transactions (`BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`) 
    - Error handling (`TRY...CATCH`, `RAISERROR`) 
    - Window functions (`ROW_NUMBER()`, `RANK()`, `AVG()`, `COUNT()`) 
- **Optimization Techniques:** Indexing, partitioning, materialized views, query tuning ---

## 📂 Sections

### Section 1: Intermediate SQL Queries
- List users enrolled in more than three courses  
- Find courses with no enrollments  
- Display each course with total enrolled users  
- Identify users enrolled but never accessed lessons  
- Fetch lessons never accessed by any user  
- Show last activity timestamp per user  
- List users scoring <50% of max score in assessments  
- Find assessments with no submissions  
- Display highest score per assessment  
- Identify users with inactive enrollment status  

Each query includes:
- **Join choice** (INNER vs LEFT JOIN)  
- **Assumptions** (e.g., missing activity = no access)  
- **Large dataset behavior** (performance considerations, indexing)  

---

### Section 2: Advanced SQL and Analytics
- Course statistics: enrolled users, lessons, average duration  
- Top 3 most active users  
- Course completion percentage per user  
- Users scoring above course average  
- Courses with lesson activity but no assessments  
- Rank users by total assessment scores  
- First lesson accessed per user/course  
- Users active on 5 consecutive days  
- Users enrolled but never submitted assessments  
- Courses where all enrolled users submitted assessments  

---

### Section 3: Performance and Optimization
- Suggested indexes for course dashboards and user activity analytics  
- Identified bottlenecks in queries involving `UserActivity`  
- Optimization strategies when `UserActivity` grows to millions of rows  
- Scenarios for using **materialized views** (e.g., pre‑aggregated reports)  
- Partitioning strategies for `UserActivity` (e.g., by date ranges)  

---

### Section 4: Data Integrity and Constraints
- Unique constraint on `(assessment_id, user_id)` to prevent duplicate submissions  
- Trigger to enforce score ≤ max_score  
- Trigger to block enrollment in courses with no lessons  
- Trigger to restrict course creation to instructors only  
- Soft delete strategy for courses using `is_active` flag  

---

### Section 5: Transactions and Concurrency
- Transaction flow for safe enrollments  
- Handling concurrent submissions with row‑level locks (`UPDLOCK`, `HOLDLOCK`)  
- Partial failure handling with `TRY...CATCH` and rollback strategy  
- Recommended isolation levels:  
  - **READ COMMITTED** for enrollments  
  - **SERIALIZABLE** for submissions  
  - **SNAPSHOT** for analytics  
- Preventing phantom reads in analytics queries  

---

### Section 6: Database Design and Architecture
- Schema changes to support course completion certificates  
- Tracking video progress efficiently at scale  
- Normalization vs denormalization trade‑offs for `UserActivity`  
- Reporting‑friendly schema design for dashboards  
- Evolution strategy to support millions of users  

---

## 🚀 How to Use
1. Set up the LMS schema in SQL Server.  
2. Apply constraints and triggers to enforce integrity rules.  
3. Run transaction flows for safe enrollments and submissions.  
4. Execute analytics queries to generate insights on user activity and performance.  

---

## 📊 Design Considerations
- **Join choices**: INNER JOIN for valid matches, LEFT JOIN for detecting missing relationships.  
- **Assumptions**: Missing activity = no access, missing submissions = not attempted.  
- **Large datasets**: Indexing on foreign keys (`user_id`, `course_id`, `assessment_id`) ensures scalability.  
