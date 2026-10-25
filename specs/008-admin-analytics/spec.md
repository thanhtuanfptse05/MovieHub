# Feature Spec: 008-admin-analytics (Management Dashboard & Reporting)
<!-- SDD Specification: UC-16 -->
Status: Draft | Version: 0.1.0 | Date: 2026-10-25 | Priority: Medium
Scope: Executive Dashboard, Most Viewed Movies, Top Rated Movies, User Activity Metrics

## 1. Business Context & Problem Statement
Administrators need high-level operational visibility into platform engagement, top-performing content, user growth, and review sentiment to make informed curation and marketing decisions.

## 2. User Stories
- **US-01 (Dashboard Summary)**: As an admin, I want to see a high-level summary (total active movies, total registered users, total reviews posted) upon logging in.
- **US-02 (Content Analytics)**: As an admin, I want to view the top 10 most viewed and top 10 highest-rated movies.
- **US-03 (Time Filtering)**: As an admin, I want to filter metrics over specific time periods (last 7 days, last 30 days, all time).

## 3. Acceptance Criteria (EARS Syntax)
- **AC-01 (Admin Protection)**: WHILE an incoming request targets `/admin/dashboard` THE system SHALL verify `role == 'ADMIN'` (BR-22).
- **AC-02 (Dashboard Counters)**: WHEN admin accesses dashboard THE system SHALL query aggregate counts of active users, active movies, and approved reviews.
- **AC-03 (Top Performers)**: THE system SHALL order movies by view count descending and rating descending with a configurable limit (default: 10).
- **AC-04 (Performance SLA)**: THE system SHALL return dashboard metrics in under 500ms p95 using indexed aggregation queries.

## 4. Controller Contracts
- `GET /admin/dashboard`: Render dashboard view (`/WEB-INF/views/admin/dashboard.jsp`)

## 5. Security & Quality Constraints
- Protected by `AdminAuthFilter`.
- Pure JSTL, zero scriptlets.
- Libraries: strictly `allowedlib` only.
