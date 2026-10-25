# Feature Spec: 005-reviews-rating (Community Reviews & Star Ratings)
<!-- SDD Specification: UC-09, UC-15 -->
Status: Draft | Version: 0.1.0 | Date: 2026-10-25 | Priority: Medium
Scope: Submit Review & Rating, Update Review, Delete Review, Moderate Reviews

## 1. Business Context & Problem Statement
Reviews and ratings provide social proof, guide movie discovery, and foster an active community. Users need to share honest ratings (1-5 stars) and comments, while admins need moderation powers to eliminate spam and profanity.

## 2. User Stories
- **US-01 (Post Review)**: As a logged-in user, I want to rate a movie (1-5 stars) and write a text review so other users can read my opinion.
- **US-02 (Update/Delete Own Review)**: As a user who already reviewed a movie, I want to edit my rating/comment or delete my review.
- **US-03 (Admin Moderation)**: As an admin, I want to hide or delete inappropriate reviews.

## 3. Acceptance Criteria (EARS Syntax)
- **AC-01 (Score Bounds)**: THE system SHALL accept ratings strictly as integers between 1 and 5 (BR-11).
- **AC-02 (Single Review Per User)**: IF a user who has already reviewed a movie submits another review THE system SHALL update their existing review instead of creating a duplicate (BR-12).
- **AC-03 (Average Recalculation)**: WHEN a review is created, modified, or deleted THE system SHALL automatically recalculate the movie's average rating and total review count (BR-14).
- **AC-04 (Profanity & Moderation)**: IF review text contains prohibited terms THE system SHALL set status to `PENDING_REVIEW` for admin approval (BR-15).

## 4. Controller Contracts
- `POST /reviews/submit`: Submit or update review (`movieId`, `rating`, `comment`)
- `POST /reviews/delete`: Delete own review (`reviewId`)
- `POST /admin/reviews/moderate`: Approve or reject review (`reviewId`, `action`)

## 5. Security & Quality Constraints
- User authorization (can only modify own reviews unless Admin).
- XSS escaping on review comments via `<c:out>`.
- Strictly `allowedlib` only.
