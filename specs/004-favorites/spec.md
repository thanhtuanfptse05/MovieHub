# Feature Spec: 004-favorites (Personal Watchlist & Favorites)
<!-- SDD Specification: UC-08 -->
Status: Draft | Version: 0.1.0 | Date: 2026-10-25 | Priority: Low
Scope: Add to Favorites, Remove from Favorites, View Favorites List

## 1. Business Context & Problem Statement
Users want to bookmark movies they plan to watch or love, maintaining an organized personal watchlist accessible across sessions.

## 2. User Stories
- **US-01 (Add Favorite)**: As a logged-in user, I want to add a movie to my favorites from its detail page or card.
- **US-02 (Remove Favorite)**: As a logged-in user, I want to remove a movie from my favorites list.
- **US-03 (View Watchlist)**: As a logged-in user, I want to view my entire favorites list with quick links to movie details.

## 3. Acceptance Criteria (EARS Syntax)
- **AC-01 (Auth Requirement)**: WHILE user is not authenticated THE system SHALL redirect any attempt to add to favorites to `/login`.
- **AC-02 (Add Success)**: WHEN a logged-in user clicks "Add to Favorites" on an unbookmarked movie THE system SHALL insert a record into `Favorites`, update movie favorite count (BR-17), and return success.
- **AC-03 (Duplicate Prevention)**: IF a user attempts to add an already-favorited movie THEN THE system SHALL ignore duplicate insertion without error (BR-16).
- **AC-04 (Remove Success)**: WHEN user clicks "Remove" on a favorited movie THE system SHALL delete the favorite record and decrement aggregate count.

## 4. Controller Contracts
- `GET /favorites`: View user's favorites list (`/WEB-INF/views/favorite/favorite-list.jsp`)
- `POST /favorites/add`: Add movie to favorites (`?movieId=...`)
- `POST /favorites/remove`: Remove movie from favorites (`?movieId=...`)

## 5. Security & Quality Constraints
- Session authentication required.
- Pure JSTL, zero scriptlets.
- Libraries: strictly `allowedlib` only.
