# Business Rules & Domain Constraints — MovieHub
<!-- SDD Constraint Layer 2: Business Logic & Policies -->

## 1. User & Account Rules
- **BR-01**: Email must be globally unique across all user accounts.
- **BR-02**: Passwords must be at least 8 characters long, containing at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character.
- **BR-03**: Failed login attempts exceeding 5 consecutive times will temporarily lock the account for 15 minutes.
- **BR-04**: Password reset tokens expire after 15 minutes and can only be used once.
- **BR-05**: Account status can be `ACTIVE`, `INACTIVE`, or `BANNED`. Only `ACTIVE` users can log in, post reviews, and ask questions.

## 2. Movie & Catalog Rules
- **BR-06**: Each movie must belong to at least 1 category.
- **BR-07**: Movie release year must be between 1888 and current year + 2.
- **BR-08**: Movie duration must be greater than 0 minutes.
- **BR-09**: Deleting a movie uses soft-delete (`is_active = false`), preserving historical reviews, ratings, and analytics data.
- **BR-10**: Movie status is either `UPCOMING`, `NOW_SHOWING`, or `ENDED`.

## 3. Review & Rating Rules
- **BR-11**: Rating score must be an integer between 1 and 5 stars.
- **BR-12**: A user can submit at most 1 review per movie (they may update their existing review).
- **BR-13**: Anonymous users cannot post reviews or ratings.
- **BR-14**: Movie average rating is re-calculated whenever a review is created, updated, or removed.
- **BR-15**: Reviews containing flagged profanity are marked as `PENDING_REVIEW` for admin moderation.

## 4. Favorites / Watchlist Rules
- **BR-16**: A user cannot add the same movie to their favorites list multiple times (unique constraint on `(user_id, movie_id)`).
- **BR-17**: Adding/removing from favorites must update the movie's aggregate favorite count.

## 5. Q&A Community Rules
- **BR-18**: Questions must be between 10 and 500 characters.
- **BR-19**: Answers must be between 5 and 1000 characters.
- **BR-20**: Only admins or the question owner can mark an answer as `ACCEPTED`.
- **BR-21**: Deleted questions soft-delete all associated answers.

## 6. Administration & Reporting Rules
- **BR-22**: Only users with role `ADMIN` can access `/admin/*` routes.
- **BR-23**: Admins cannot delete their own admin account.
- **BR-24**: Analytical reports aggregate data over customizable periods (daily, weekly, monthly) using cached or indexed database queries.
