# Implementation Plan: 005-reviews-rating
<!-- Architecture & Engineering Plan -->

## 1. Architectural Layers & File Map
- **Entities**: `com.moviehub.entity.Review` (Table: `Reviews`)
- **DAOs**: `com.moviehub.dao.ReviewDAO` (`findByMovieId`, `findByUserAndMovie`, `saveOrUpdate`, `delete`, `calculateAverageRating`)
- **Services**: `com.moviehub.service.ReviewService`
- **Controllers (Servlets)**:
  - `com.moviehub.controller.review.ReviewServlet` (`/reviews/submit`, `/reviews/delete`)
  - `com.moviehub.controller.admin.AdminReviewServlet` (`/admin/reviews/moderate`)
- **Views (JSP + JSTL)**:
  - Included as fragment inside `movie-detail.jsp` and `web/WEB-INF/views/admin/review-moderate.jsp`

## 2. Verification Strategy
- Unit tests: `ReviewServiceTest.java` (Rating range 1-5, average recomputation).
- Web tests: Review submission and check average rating update.
