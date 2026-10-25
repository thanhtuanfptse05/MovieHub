# Feature Spec: 002-user-profile (User Profile & Security Settings)
<!-- SDD Specification: UC-04, UC-14 -->
Status: Draft | Version: 0.1.0 | Date: 2026-10-25 | Priority: Medium
Scope: View Profile, Update Full Name, Update Avatar/Bio, Change Password

## 1. Business Context & Problem Statement
Users need the ability to maintain their personal account details, view their activity summary, update profile information, and change their password securely without administrative intervention.

## 2. User Stories
- **US-01 (View Profile)**: As a logged-in user, I want to view my profile details (name, email, join date, avatar) so that I can see my account status.
- **US-02 (Update Profile)**: As a logged-in user, I want to update my display name and bio so that other members can see my updated information.
- **US-03 (Change Password)**: As a logged-in user, I want to change my current password by providing my existing password and a new strong password.

## 3. Acceptance Criteria (EARS Syntax)
- **AC-01 (Authentication Guard)**: WHILE user is not authenticated THE system SHALL redirect any request to `/profile` or `/change-password` to `/login`.
- **AC-02 (Update Profile Success)**: WHEN a logged-in user submits valid profile updates (name between 2-100 characters) THE system SHALL persist updates, refresh session attributes, and display success message "Profile updated successfully".
- **AC-03 (Change Password Verification)**: WHEN user submits change password form THE system SHALL verify old password using BCrypt; IF old password matches and new password satisfies BR-02 THEN system SHALL update password hash and notify user.
- **AC-04 (Wrong Old Password)**: IF old password does not match current hash THEN system SHALL reject update with error "Current password is incorrect".

## 4. Controller Contracts
- `GET /profile`: View user profile page (`/WEB-INF/views/user/profile.jsp`)
- `POST /profile`: Update profile info
- `GET /change-password`: View change password form (`/WEB-INF/views/user/change-password.jsp`)
- `POST /change-password`: Process password change

## 5. Security & Quality Constraints
- Session authentication required.
- Current password verification before password mutation.
- Strict JSTL and XSS escaping via `<c:out>`.
- Libraries: strictly `allowedlib` only.
