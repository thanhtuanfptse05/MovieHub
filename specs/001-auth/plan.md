# Implementation Plan: 001-auth (User Authentication & Password Recovery)
<!-- Architecture & Engineering Plan - Synced with spec.md v1.1.0 / R-01 -->

## 1. Technical Context & Architectural Decisions
- **Stack**: Java 17 LTS, Apache Tomcat 10.1 (Jakarta EE 10 namespace: `jakarta.servlet.*`, `jakarta.persistence.*`), NetBeans 17 Ant Web Application, Microsoft SQL Server.
- **ORM / Persistence**: Hibernate 6.4.4.Final implementing Jakarta Persistence 3.1 (`EntityManager`, `EntityTransaction`, parameterized `TypedQuery`).
- **Security & Cryptography**:
  - BCrypt password hashing (work factor >= 12) via `org.mindrot.jbcrypt.BCrypt`.
  - Session security: Session ID regeneration on login (`session.invalidate()` -> `request.getSession(true)`).
  - CSRF protection: Session-scoped anti-CSRF token verified for every mutating POST request (`/register`, `/login`, `/logout`, `/forgot-password`, `/reset-password`).
  - Session invalidation & credential revocation: `credentialsVersion` column on `Users` table, incremented atomically upon password reset; filters and servlets check `credentialsVersion` against session attribute on protected/subsequent requests.
  - Return-to sanitization: White-list internal GET destination validation to prevent open redirects (SYS-04 / SYS-06).
- **R-01 Direct Password Reset Flow**:
  - `POST /forgot-password`: Validate ACTIVE email, store transient session context (`targetUserId`, `expectedCredentialsVersion`, `flowVersion`), redirect 303 to `/reset-password`.
  - `POST /reset-password`: Verify CSRF, match `flowVersion`, atomic verify and update `password_hash` with BCrypt, increment `credentialsVersion`, revoke all prior sessions, redirect 303 to `/login`.
  - No SMTP, no email tokens, no OTP. `PasswordResetTokens` table is ignored.
- **UI & Art Direction**:
  - Pure JSTL 2.0 (`jakarta.tags.core`) with `<c:out value="${...}" escapeXml="true" />`.
  - 100% Zero Scriptlet policy (`<% %>` strictly prohibited).
  - Dark cinema styling aligned with `design.md` design tokens (`--mh-bg: #0f131d`, `--mh-surface: #1c1f2a`, `--mh-surface-low: #171b26`, `--mh-text: #dfe2f1`, `--mh-accent: #ff535b`, `--mh-outline: #ab8987`).
  - Strict compliance with `ui_rule.md`:
    - UI-DATA-01 (R-02): Zero hardcoded business data; real database-driven feedback and honest empty/error states.
    - UI-COPY-01 (R-03): Zero Business Rules documentation, BR/FR/UC/NFR codes, or developer notes on product views.

## 2. File & Component Map

### Configuration & Persistence
- `src/conf/persistence.xml`: JPA configuration unit `MovieHubPU` with Hibernate provider and SQL Server connection settings.
- `src/java/com/moviehub/util/JPAUtil.java`: Thread-safe `EntityManagerFactory` singleton management.

### Entities (`com.moviehub.entity`)
- `User.java`: JPA Entity mapped to table `Users` (`id`, `full_name`, `email`, `password_hash`, `role`, `status`, `avatar_url`, `created_at`, `updated_at`, `version`, `credentials_version`).

### Data Access Layer (`com.moviehub.dao`)
- `UserDAO.java`:
  - `Optional<User> findById(Long id)`
  - `Optional<User> findByEmail(String canonicalEmail)`
  - `boolean existsByEmail(String canonicalEmail)`
  - `void save(User user)`
  - `boolean updatePasswordAndIncrementCredentials(Long userId, String newPasswordHash, int expectedCredentialsVersion)`

### Service Layer (`com.moviehub.service`)
- `AuthService.java`:
  - `User register(String fullName, String email, String password, String confirmPassword)`
  - `User login(String email, String password)`
  - `ResetContext initiatePasswordReset(String email, int currentFlowVersion)`
  - `void completePasswordReset(Long targetUserId, int expectedCredentialsVersion, int formFlowVersion, int contextFlowVersion, String newPassword, String confirmPassword)`
  - `boolean validateSessionCredentials(Long userId, int sessionCredentialsVersion)`
- `com.moviehub.util.PasswordUtil.java`: BCrypt utility helper (cost 12).
- `com.moviehub.util.ValidationUtil.java`: Email canonicalization, password length (8-72 bytes UTF-8), name length validation.
- `com.moviehub.util.CSRFUtil.java`: Session CSRF token generator and validator.

### Filter & Security Layer (`com.moviehub.filter`)
- `CSRFFilter.java`: Generates and attaches `csrfToken` to session and requests.
- `AuthFilter.java`: Validates session authentication, active status, and credentialsVersion consistency for protected routes.
- `AdminAuthFilter.java`: Guards `/admin/*` routes (Guest -> 303 `/login?returnTo=...`, User -> 403 Forbidden).

### Controller Layer (`com.moviehub.controller.auth`)
- `RegisterServlet.java` (`/register`): GET form, POST register -> 303 `/login`.
- `LoginServlet.java` (`/login`): GET form, POST authenticate -> 303 returnTo / `/admin/dashboard` / `/`.
- `LogoutServlet.java` (`/logout`): POST invalidate session -> 303 `/`; GET returns 405.
- `ForgotPasswordServlet.java` (`/forgot-password`): GET email form, POST validate email -> 303 `/reset-password`.
- `ResetPasswordServlet.java` (`/reset-password`): GET password form (requires session context), POST update password -> 303 `/login`.

### Error Handlers (`com.moviehub.controller.error`)
- `ErrorServlet.java`: Handles 403, 404, 500 error views.

### View Layer (`web/WEB-INF/views/`)
- `auth/register.jsp`: Registration view (clean form, label/field errors, cinema theme).
- `auth/login.jsp`: Login view with returnTo retention and flash messages.
- `auth/forgot-password.jsp`: Email input step for direct password recovery.
- `auth/reset-password.jsp`: Password input step bound to server reset context.
- `error/403.jsp`, `error/404.jsp`, `error/500.jsp`: Dedicated error pages in Vietnamese.
- `assets/css/style.css`: Cinema dark design system CSS variables and layout components.

## 3. Verification & Testing Strategy
- **Unit Tests**: `test/com/moviehub/service/AuthServiceTest.java`:
  - Test registration: validation errors, duplicate email case-insensitivity, BCrypt hash verification.
  - Test login: valid active user, invalid password, inactive user status rejection, generic error message.
  - Test R-01 direct password reset: valid active email initiates context; inactive/missing email rejected with 400; stale expectedCredentialsVersion rejected with 409; flowVersion mismatch rejected with 409; atomic credentialsVersion increment.
- **Local Ant Verification**:
  - `ant compile`
  - `ant test`
