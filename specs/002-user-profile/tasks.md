# Tasks Breakdown: 002-user-profile (User Profile Management)
<!-- Actionable, Dependency-Ordered Task List - Aligned with spec.md v1.0.0 -->

## Phase 1: Data Access & Business Logic (TDD)
- [x] **Task 1: UserDAO Profile Extension**
  - Add `updateProfile(Long userId, String fullName, String avatarUrl, int expectedVersion)` in `UserDAO.java`.
  - Use atomic parameterized JPQL update with `WHERE u.id = :id AND u.version = :expectedVersion AND u.status = 'ACTIVE'`.
  - Increment version and update `updated_at`.
- [x] **Task 2: UserService Implementation & TDD Unit Tests**
  - Create test suite `test/com/moviehub/service/UserServiceTest.java`.
  - Implement `com.moviehub.service.UserService`:
    - `getProfile(Long userId)`
    - `updateProfile(Long userId, String fullName, String avatarUrl, Integer version)`
    - Validate fullName (1–100 chars, non-whitespace).
    - Validate avatarUrl (null/empty allowed, <=500 chars, valid HTTP/HTTPS URL format).
    - Detect no-op change (if fullName and avatarUrl are identical, return success without bumping version).
    - Detect stale version conflict -> throw `IllegalStateException` (translates to 409).

## Phase 2: Controller & View Layers
- [x] **Task 3: ProfileServlet Controller**
  - Implement `com.moviehub.controller.user.ProfileServlet` (`/profile`).
  - `doGet`: Read `userId` from session (enforce session ownership, ignore any client `userId`), fetch profile, forward to `/WEB-INF/views/user/profile.jsp`.
  - `doPost`: Validate CSRF token, extract `fullName`, `avatarUrl`, `version`; invoke `UserService.updateProfile`.
  - On success: refresh `userFullName` and `userAvatarUrl` in session; set flash message; `303 See Other` redirect to `/profile`.
  - On validation error: `400 Bad Request` with field error message.
  - On version conflict: `409 Conflict` with conflict error message.
  - Register `/profile` in `web/WEB-INF/web.xml`.
- [x] **Task 4: JSP View (Pure JSTL Cinema Aesthetics)**
  - Create `web/WEB-INF/views/user/profile.jsp`.
  - Pure JSTL/EL (100% Zero scriptlets).
  - Avatar image with error fallback (`onerror="this.src=..."` or initial circle).
  - Read-only fields: Email, Joined Date.
  - Form fields: Full Name, Avatar URL, hidden `version`, hidden `csrfToken`.
  - Adhere to `ui_rule.md` (no hardcoded business data, no engineering notes).

## Phase 3: Database Seeding & Verification
- [x] **Task 5: Database Seeding (Rich Sample Data)**
  - Ensure all 8 core tables exist in SQL Server (`Users`, `Movies`, `Categories`, `MovieCategories`, `Favorites`, `Reviews`, `Questions`, `Answers`).
  - Insert rich sample data:
    - 6+ demo users (Admin and Customers with BCrypt password hashes).
    - 8 genres/categories.
    - 30+ movies across various years, durations, and statuses.
    - Movie-category mappings.
    - Favorites, Reviews (ratings & comments), Questions and Answers.
- [x] **Task 6: Verification Gate & Delivery**
  - Run Ant compile and unit test suite.
  - Run E2E integration verification script against Tomcat server.
  - Complete 15-item checklist in `specs/002-user-profile/checklists.md`.
  - Commit with Conventional Commits and push to GitHub (`feat/002-user-profile`).
