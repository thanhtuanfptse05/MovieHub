# Implementation Plan: 001-auth (User Authentication & Password Recovery)
<!-- Architecture & Engineering Plan -->

## 1. Architectural Layers & File Map
- **Entities**:
  - `com.moviehub.entity.User` (Table: `Users`)
  - `com.moviehub.entity.PasswordResetToken` (Table: `PasswordResetTokens`)
- **DAOs**:
  - `com.moviehub.dao.UserDAO` (Interface & Implementation with JPA EntityManager)
  - `com.moviehub.dao.PasswordResetTokenDAO`
- **Services**:
  - `com.moviehub.service.AuthService` (Hashing, authentication, registration, token generation)
  - `com.moviehub.util.PasswordUtil` (BCrypt hashing helper)
  - `com.moviehub.util.EmailUtil` (Email dispatch helper)
- **Controllers (Servlets)**:
  - `com.moviehub.controller.auth.RegisterServlet` (`/register`)
  - `com.moviehub.controller.auth.LoginServlet` (`/login`)
  - `com.moviehub.controller.auth.LogoutServlet` (`/logout`)
  - `com.moviehub.controller.auth.ForgotPasswordServlet` (`/forgot-password`)
  - `com.moviehub.controller.auth.ResetPasswordServlet` (`/reset-password`)
- **Views (JSP + JSTL)**:
  - `web/WEB-INF/views/auth/register.jsp`
  - `web/WEB-INF/views/auth/login.jsp`
  - `web/WEB-INF/views/auth/forgot-password.jsp`
  - `web/WEB-INF/views/auth/reset-password.jsp`

## 2. Verification Strategy
- Unit tests: `test/com/moviehub/service/AuthServiceTest.java` (Test BCrypt verify, validation rules).
- Integration test: Database persistence check via JPA test instance.
- Manual / Web test: Registration flow, login with invalid credentials, session persistence.
