# Feature Spec: 007-admin-crud (Admin Entity Management)
<!-- SDD Specification: UC-12, UC-13, UC-14 -->
Status: Draft | Version: 0.1.0 | Date: 2026-10-25 | Priority: High
Scope: Manage Movies (Create, Read, Update, Soft-Delete), Manage Categories, Manage Users & Roles

## 1. Business Context & Problem Statement
System administrators require full lifecycle management over the movie catalog, taxonomy (categories), and registered user accounts to maintain platform quality, freshness, and compliance.

## 2. User Stories
- **US-01 (Manage Movies)**: As an admin, I want to create, edit, and soft-delete movies with poster URLs, trailer links, and category tags.
- **US-02 (Manage Categories)**: As an admin, I want to create and organize categories.
- **US-03 (Manage Users)**: As an admin, I want to view all users, activate/ban accounts, and assign roles.

## 3. Acceptance Criteria (EARS Syntax)
- **AC-01 (Admin Filter Enforcement)**: WHILE an incoming HTTP request targets any URL matching `/admin/*` THE system SHALL verify the authenticated user has role `ADMIN` (BR-22); IF unauthenticated OR non-admin THEN redirect to `/login` with HTTP 403.
- **AC-02 (Movie Validation)**: WHEN creating/updating a movie THE system SHALL enforce that duration > 0 (BR-08) and release year is valid (BR-07).
- **AC-03 (Soft Delete Movie)**: WHEN admin deletes a movie THE system SHALL perform soft-delete (`is_active = false`), preserving associated reviews and history (BR-09).
- **AC-04 (Admin Self-Delete Prevention)**: IF an admin attempts to delete or ban their own account THEN THE system SHALL reject the operation with error "Cannot ban or delete your own admin account" (BR-23).

## 4. Controller Contracts
- `GET /admin/movies`: List movies for admin
- `GET /admin/movies/create`: Create movie form
- `POST /admin/movies/create`: Save new movie
- `GET /admin/movies/edit?id=...`: Edit movie form
- `POST /admin/movies/edit`: Update movie
- `POST /admin/movies/delete`: Soft-delete movie
- `GET /admin/categories`: Manage categories
- `POST /admin/categories/save`: Save category
- `GET /admin/users`: List users & manage status

## 5. Security & Quality Constraints
- Protected by `AdminAuthFilter`.
- 100% pure JSTL, zero scriptlets.
- Libraries: strictly `allowedlib` only.
