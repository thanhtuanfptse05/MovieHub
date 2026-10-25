# Tasks Breakdown: 001-auth (User Authentication & Password Recovery)
<!-- Actionable, Dependency-Ordered Task List - Aligned with spec.md v1.1.0 & R-01 -->

## Phase 1: Setup & Data Access Layer
- [x] **Task 1: Setup Persistence & Database Configuration**
  - Create `src/conf/persistence.xml` with `MovieHubPU` persistence unit using Hibernate 6.4 provider and SQL Server connection settings.
  - Implement `com.moviehub.util.JPAUtil` singleton helper for thread-safe `EntityManagerFactory` creation and management.
- [x] **Task 2: User JPA Entity**
  - Implement `com.moviehub.entity.User` with fields: `id`, `fullName`, `email`, `passwordHash`, `role` (`USER`/`ADMIN`), `status` (`ACTIVE`/`INACTIVE`), `avatarUrl`, `createdAt`, `updatedAt`, `version`, `credentialsVersion`.
  - Add named queries: `User.findByEmail` (case-insensitive canonical), `User.countByEmail`.
- [x] **Task 3: UserDAO with JPA EntityManager**
  - Implement `com.moviehub.dao.UserDAO` using `EntityManager` and `EntityTransaction`.
  - Methods: `save(User user)`, `findById(Long id)`, `findByEmail(String canonicalEmail)`, `existsByEmail(String canonicalEmail)`, `updatePasswordAndIncrementCredentials(Long userId, String newPasswordHash, int expectedCredentialsVersion)`.
  - Guarantee zero raw SQL concatenation, named parameters only, automatic rollback on error.

## Phase 2: Security Utilities & Business Logic (TDD)
- [x] **Task 4: Security & Validation Utilities**
  - Implement `com.moviehub.util.PasswordUtil` (BCrypt hashing with work factor 12 and verification).
  - Implement `com.moviehub.util.ValidationUtil` (email canonicalization & format, password 8-72 byte UTF-8 check, fullName 1-100 check).
  - Implement `com.moviehub.util.CSRFUtil` (cryptographically secure token generation and constant-time validation).
- [x] **Task 5: AuthService with Unit Tests (TDD)**
  - Write test suite `test/com/moviehub/service/AuthServiceTest.java`.
  - Implement `com.moviehub.service.AuthService`:
    - `register`: validate fields, check unique email, hash with BCrypt, save user as `ACTIVE` with role `USER`.
    - `login`: verify canonical email, active status, BCrypt hash verification; generic error on any failure.
    - `initiatePasswordReset` (R-01): verify canonical email is ACTIVE, create transient session context (`targetUserId`, `expectedCredentialsVersion`, `flowVersion`).
    - `completePasswordReset` (R-01): verify flowVersion and expectedCredentialsVersion match, atomic update password hash and increment credentialsVersion.
    - `validateSessionCredentials`: check active status and credentialsVersion match.

## Phase 3: Web Security & Controller Layer
- [x] **Task 6: Filters & Security Interceptors**
  - Implement `com.moviehub.filter.CSRFFilter` to attach CSRF token to all requests and validate on mutating POST requests.
  - Implement `com.moviehub.filter.AuthFilter` to validate session credentialsVersion and active status on protected requests.
  - Implement `com.moviehub.filter.AdminAuthFilter` to protect `/admin/*` routes.
  - Configure servlet mappings, filters, and error pages in `web/WEB-INF/web.xml`.
- [x] **Task 7: Servlets (Controller Layer)**
  - Implement `com.moviehub.controller.auth.RegisterServlet` (`/register`).
  - Implement `com.moviehub.controller.auth.LoginServlet` (`/login`).
  - Implement `com.moviehub.controller.auth.LogoutServlet` (`/logout` POST with CSRF; GET returns 405).
  - Implement `com.moviehub.controller.auth.ForgotPasswordServlet` (`/forgot-password` GET & POST).
  - Implement `com.moviehub.controller.auth.ResetPasswordServlet` (`/reset-password` GET & POST).
  - Implement `com.moviehub.controller.error.ErrorServlet` (`/403`, `/404`, `/500`).

## Phase 4: Frontend UI (Pure JSTL & Cinema Design System)
- [x] **Task 8: Cinema Dark CSS & Error Views**
  - Create `web/assets/css/style.css` implementing tokens from `design.md` (`--mh-bg: #0f131d`, `--mh-surface: #1c1f2a`, `--mh-accent: #ff535b`, etc.).
  - Create `web/WEB-INF/views/error/403.jsp`, `404.jsp`, `500.jsp` (pure JSTL, Vietnamese, correlation ID for 500, no stack traces).
- [x] **Task 9: Auth JSP Views**
  - Implement `web/WEB-INF/views/auth/register.jsp`.
  - Implement `web/WEB-INF/views/auth/login.jsp`.
  - Implement `web/WEB-INF/views/auth/forgot-password.jsp`.
  - Implement `web/WEB-INF/views/auth/reset-password.jsp`.
  - Verify 100% Zero Scriptlets (`<% %>`), proper `<c:out value="..." escapeXml="true" />`, label/error binding.
  - Verify UI-DATA-01 (no hardcoded business data) and UI-COPY-01 (zero BR/FR/UC/NFR codes or developer notes on UI).

## Phase 5: Verification & Delivery
- [x] **Task 10: Validation Gate & Verification**
  - Run Ant compile: `& "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" compile` (BUILD SUCCESSFUL).
  - Run Ant test: `& "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" test` (BUILD SUCCESSFUL, 12/12 passed).
  - Verify all 15 items in `specs/001-auth/checklists.md`.
