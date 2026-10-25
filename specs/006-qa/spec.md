# Feature Spec: 006-qa (Interactive Q&A Discussions)
<!-- SDD Specification: UC-10, UC-11, UC-15 -->
Status: Draft | Version: 0.1.0 | Date: 2026-10-25 | Priority: Medium
Scope: Ask Question, Post Answer, Accept Answer, Moderate Q&A

## 1. Business Context & Problem Statement
MovieHub provides an interactive Q&A discussion board per movie where fans can ask about plot twists, trivia, soundtrack details, and filming locations.

## 2. User Stories
- **US-01 (Ask Question)**: As a logged-in user, I want to ask a question related to a movie.
- **US-02 (Post Answer)**: As a user, I want to answer questions posted by other members.
- **US-03 (Accept Answer)**: As the question author or an admin, I want to mark the best answer as `ACCEPTED`.
- **US-04 (Moderate Q&A)**: As an admin, I want to delete spam questions or answers.

## 3. Acceptance Criteria (EARS Syntax)
- **AC-01 (Question Bounds)**: THE system SHALL validate question length between 10 and 500 characters (BR-18).
- **AC-02 (Answer Bounds)**: THE system SHALL validate answer length between 5 and 1000 characters (BR-19).
- **AC-03 (Accept Answer Permission)**: WHEN a user clicks "Accept Answer" THE system SHALL verify the user is either the question creator or an admin (BR-20); IF unauthorized THEN reject with HTTP 403.
- **AC-04 (Cascade Soft Delete)**: WHEN a question is deleted THE system SHALL soft-delete all attached answers (BR-21).

## 4. Controller Contracts
- `POST /qa/questions/create`: Submit new question
- `POST /qa/answers/create`: Submit answer to question
- `POST /qa/answers/accept`: Mark answer as accepted
- `POST /qa/delete`: Delete question or answer

## 5. Security & Quality Constraints
- XSS prevention via `<c:out>`. Zero scriptlets in JSP.
- Strictly `allowedlib` only.
