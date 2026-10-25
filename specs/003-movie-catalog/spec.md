# Feature Spec: 003-movie-catalog (Movie Catalog, Filtering & Search)
<!-- SDD Specification: UC-05, UC-06, UC-07, UC-17 -->
Status: Draft | Version: 0.1.0 | Date: 2026-10-25 | Priority: Medium
Scope: Movie List, Filter by Category/Year/Rating, Keyword Search, Movie Detail, Watch Trailer

## 1. Business Context & Problem Statement
The movie catalog is the core public surface of MovieHub. Visitors and users need to discover films through multi-dimensional filters, keyword search, detailed synopsis, ratings, and embedded trailers.

## 2. User Stories
- **US-01 (Browse Movies)**: As a user, I want to browse paginated movies sorted by latest release, popularity, or rating.
- **US-02 (Filter Movies)**: As a user, I want to filter movies by category, release year, and minimum rating score.
- **US-03 (Search Movies)**: As a user, I want to search movies by title or director with instant keyword matching.
- **US-04 (Movie Details)**: As a user, I want to view full movie details (synopsis, cast, duration, trailer, genres, average rating).

## 3. Acceptance Criteria (EARS Syntax)
- **AC-01 (Catalog Pagination)**: THE system SHALL paginate movie lists with a default page size of 12 movies per page.
- **AC-02 (Filtering Precision)**: WHEN user selects one or more categories and a year range THE system SHALL return only movies satisfying all active filters.
- **AC-03 (Keyword Search)**: WHEN user enters a search query of at least 2 characters THE system SHALL query titles and directors using case-insensitive parameterized matching.
- **AC-04 (Detail View & View Counter)**: WHEN user navigates to `/movies/detail?id={id}` THE system SHALL retrieve movie details and increment view count by 1.
- **AC-05 (Soft-Deleted Movies)**: THE system SHALL NOT display soft-deleted (`is_active = false`) movies in public search or catalog views (BR-09).

## 4. Controller Contracts
- `GET /movies`: Browse catalog with query params `?category=&year=&sort=&page=`
- `GET /movies/search`: Search endpoint `?q={query}`
- `GET /movies/detail?id={id}`: Movie details page

## 5. Security & Quality Constraints
- Parameterized queries to prevent SQL injection.
- Zero scriptlets in JSP. Dynamic content rendered via `<c:out>`.
- Libraries: strictly `allowedlib` only.
