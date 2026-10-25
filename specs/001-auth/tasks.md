# Tasks Breakdown: 001-auth (User Authentication & Password Recovery)
<!-- Actionable, Dependency-Ordered Task List -->

- [ ] **Task 1: JPA Entities & Persistence Config**
  - Create `User.java` and `PasswordResetToken.java` with JPA annotations.
  - Configure `src/conf/persistence.xml` for SQL Server connection.
- [ ] **Task 2: DAOs with JPA EntityManager**
  - Implement `UserDAO` (`findByEmail`, `save`, `updateFailedAttempts`, `lockAccount`).
  - Implement `PasswordResetTokenDAO` (`save`, `findByToken`, `deleteByToken`).
- [ ] **Task 3: AuthService & PasswordUtil (TDD)**
  - Write unit tests in `AuthServiceTest.java`.
  - Implement BCrypt hashing in `PasswordUtil.java`.
  - Implement business logic in `AuthService.java` (BR-01 to BR-05).
- [ ] **Task 4: Servlets (Controller Layer)**
  - Implement `RegisterServlet`, `LoginServlet`, `LogoutServlet`.
  - Implement `ForgotPasswordServlet` and `ResetPasswordServlet`.
- [ ] **Task 5: JSP Views (Pure JSTL)**
  - Build `register.jsp`, `login.jsp`, `forgot-password.jsp`, `reset-password.jsp`.
  - Verify zero scriptlets, 100% JSTL `<c:out>`.
- [ ] **Task 6: Verification & Git Delivery**
  - Pass 15-item Validation Gate checklist.
  - Commit with `feat(auth): implement user authentication and recovery`.
  - Push branch `feat/001-auth` to GitHub.
