# Implementation Plan: 005-reviews-rating
<!-- Architecture & Engineering Plan aligned with spec.md v1.0.0 -->

## 1. Architectural Layers & File Map
- **Entities**:
  - `com.moviehub.entity.Review`: Full mapping for `Reviews` table with `user_id`, `movie_id`, `rating` (1..5), `content` (NVARCHAR(1000)), `status` (`PENDING`, `APPROVED`, `REJECTED`), `moderated_by`, `moderated_at`, `created_at`, `updated_at`, `deleted_at`, `@Version version`, `content_revision`.
- **DTOs**:
  - `com.moviehub.dto.ReviewItem`: Public/private review item (id, userId, authorName, authorAvatarUrl, rating, content, status, createdAt, updatedAt, version).
  - `com.moviehub.dto.ReviewPage`: Paginated result container for reviews.
- **DAOs**:
  - `com.moviehub.dao.ReviewDAO`:
    - `findById(Long id)`
    - `findByUserAndMovie(Long userId, Long movieId)`
    - `createReview(Review review)`
    - `updateReview(Review review)`
    - `findPublicReviews(Long movieId, int page, int pageSize)`
    - `countPublicReviews(Long movieId)`
    - `findRatingSummary(Long movieId)`
- **Services**:
  - `com.moviehub.service.ReviewService`:
    - Validation: rating (1..5), content (1..1000 chars, NFC trimmed).
    - Create mode: new or restore soft-deleted row, 409 if active exists, status `PENDING`.
    - Update mode: ownership check (403), version check (409), no-op on identical content (retains APPROVED), resets to `PENDING` on changes or resubmitting REJECTED.
    - Delete mode: ownership check (403), version check (409), soft-delete with timestamp and version increment.
    - Public list query (10/page) & rating summary (HALF_UP, null if 0).
- **Controllers (Servlets)**:
  - `com.moviehub.controller.review.ReviewSaveServlet`: Handles `POST /reviews/save` (mode create/update, CSRF, redirect 303 to `/movies/detail?id={movieId}#reviews`).
  - `com.moviehub.controller.review.ReviewDeleteServlet`: Handles `POST /reviews/delete` (CSRF, redirect 303 to `/movies/detail?id={movieId}#reviews`).
  - `com.moviehub.controller.movie.MovieDetailServlet`: Updated to load `reviewsPage` and logged-in `userReview`.
- **Views (JSP + JSTL)**:
  - `web/WEB-INF/views/movie/movie-detail.jsp`:
    - Add `#reviews` section with public reviews list, pagination, "Đánh giá của bạn" card, review form ("Viết" vs "Sửa"), guest login prompt.
    - 100% pure JSTL/EL with XML escaping (`<c:out escapeXml="true" />`), zero scriptlets.

## 2. Verification Strategy
- **Unit Tests**: `test/com/moviehub/service/ReviewServiceTest.java` (JUnit 4):
  - Validation: rating range 1..5, invalid values.
  - Content length: 1..1000 characters, empty, blank, exceeding max.
  - Create review: unpublished movie (404), active review duplicate (409), restore soft-deleted row.
  - Update review: non-author (403), version mismatch (409), identical content no-op, modified content sets PENDING.
  - Delete review: non-author (403), version mismatch (409), soft-delete, idempotent delete retry.
  - Rating summary: rounded HALF_UP to 1 decimal place, null when count=0.
- **End-to-End Tests**: `scratch/test_e2e_reviews.py`:
  - Full HTTP lifecycle on live Tomcat: create, update, delete, restore, pagination, rating reflection, anti-mojibake check on DB.
