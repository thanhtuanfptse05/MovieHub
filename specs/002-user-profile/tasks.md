# Tasks Breakdown: 002-user-profile
<!-- Actionable, Dependency-Ordered Task List -->

- [ ] **Task 1: UserDAO Extensions**
  - Implement `updateProfile(userId, fullName, avatarUrl, bio)`.
  - Implement `updatePassword(userId, newPasswordHash)`.
- [ ] **Task 2: UserService & TDD Unit Tests**
  - Write unit tests in `UserServiceTest.java`.
  - Implement `UserService.java` with validation rules.
- [ ] **Task 3: Profile & ChangePassword Servlets**
  - Implement `ProfileServlet` (`doGet`, `doPost`).
  - Implement `ChangePasswordServlet` (`doGet`, `doPost`).
- [ ] **Task 4: JSP Views (Pure JSTL)**
  - Implement `profile.jsp` and `change-password.jsp`.
  - Ensure zero scriptlets and proper XSS escaping with `<c:out>`.
- [ ] **Task 5: Verification & Delivery**
  - Pass 15-item validation gate.
  - Commit `feat(user): implement profile management and password change`.
  - Push branch `feat/002-user-profile` to GitHub.
