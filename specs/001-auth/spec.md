# Feature Spec: 001-auth (User Authentication & Password Recovery)
<!-- SDD Specification: UC-01, UC-02, UC-03 -->
Status: Draft | Version: 0.1.0 | Date: 2026-10-25 | Priority: High
Scope: Register Account, Login, Logout, Forgot Password, Reset Password

## 1. Business Context & Problem Statement
MovieHub requires a secure authentication system to identify users, maintain user sessions, authorize customer vs admin actions, and provide self-service password recovery without administrative intervention.

## 2. User Stories
- **US-01 (Register)**: As a new visitor, I want to create an account with my email, password, and full name so that I can interact with movies, favorites, and reviews.
- **US-02 (Login/Logout)**: As a registered user, I want to securely log into my account and log out at any time to protect my session.
- **US-03 (Password Recovery)**: As a user who forgot their password, I want to receive a secure reset link/token via email so that I can regain account access.

## 3. Acceptance Criteria (EARS Syntax)
- **AC-01 (Register Success)**: WHEN a guest submits registration form with valid email, strong password (BR-02), and matching confirmation password THE system SHALL hash password using BCrypt (SEC-01), create an `ACTIVE` user record in database, establish a fresh session, and redirect to homepage.
- **AC-02 (Duplicate Email)**: IF guest attempts to register with an email that already exists (BR-01) THEN THE system SHALL display error "Email is already registered" and retain input values except password.
- **AC-03 (Login Success)**: WHEN a user submits correct email and password THE system SHALL invalidate old session, generate fresh session ID, store `UserDTO` in session, reset failed login counter, and redirect to previous page or homepage.
- **AC-04 (Brute Force Defense)**: IF user inputs incorrect credentials 5 consecutive times (BR-03) THEN THE system SHALL lock the account for 15 minutes and display error message.
- **AC-05 (Token Expiration)**: IF user attempts to reset password using a token older than 15 minutes (BR-04) THEN THE system SHALL reject request with message "Password reset token has expired".

## 4. Controller Contracts
- `GET /register`: Show registration view (`/WEB-INF/views/auth/register.jsp`)
- `POST /register`: Process registration
- `GET /login`: Show login view (`/WEB-INF/views/auth/login.jsp`)
- `POST /login`: Process authentication
- `GET /logout`: Invalidate session and redirect to `/login`
- `GET /forgot-password`: Show request token view (`/WEB-INF/views/auth/forgot-password.jsp`)
- `POST /forgot-password`: Generate token and send reset email
- `GET /reset-password?token=...`: Show new password form
- `POST /reset-password`: Update password and invalidate token

## 5. Security & Quality Constraints
- BCrypt cost >= 12.
- Session regeneration upon login to prevent session fixation.
- ZERO scriptlets in JSP. Dynamic error messages rendered via `<c:out value="${errorMessage}" escapeXml="true" />`.
- Libraries: strictly `allowedlib` only.
