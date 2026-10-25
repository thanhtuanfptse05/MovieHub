# Implementation Plan: 003-movie-catalog

Aligned with spec.md v1.0.0 (CAT-AC-01…13). Replaces the earlier scaffold; no `/movies/search` route.

## Layers
- **Entities**: `Movie` (ManyToMany `Categories` via `MovieCategories`), `Category` (soft delete), `Review` (read only, for public rating aggregates).
- **DTOs**: `MovieCard`, `MovieDetail`, `HomeData`, `CatalogQuery`, `PageResult`, `CategoryOption`.
- **DAO**: `MovieDAO`, `CategoryDAO`. Parameterized JPQL only. Sort is a fixed whitelist; LIKE input is escaped (`%`, `_`, `[`, escape char) with `escape '!'`.
- **Service**: `MovieService` (query validation, SYS-03 paging, Home groups, detail, similar, SYS-07 view counting). `MediaUrlUtil` accepts only http(s) URLs; video must be `.mp4`.
- **Controllers**: `HomeServlet` (`/`), `MovieListServlet` (`/movies`), `MovieDetailServlet` (`/movies/detail`).
- **Views** (`/WEB-INF/views/movie/`): `home.jsp`, `movie-list.jsp`, `movie-detail.jsp`; tag files in `/WEB-INF/tags` (`header`, `movieCard`, `movieRow`, `pager`). Assets: `assets/js/catalog.js`, `assets/img/poster-placeholder.svg`.

## Key decisions
- Pagination is two-step: one query for the page of ids (ordered), one query for card data with rating aggregates. Counting uses `count(m.id)` over the same WHERE, so category filters never multiply rows (category match is an `IN` sub-select).
- Rating sort: `LEFT JOIN Review` (APPROVED, not deleted), unrated movies last, ties by review count then id. Average is kept unrounded; display rounds HALF_UP to 1 decimal.
- View counting: `UPDATE ... SET view_count = view_count + 1 WHERE id=? AND status='PUBLISHED'` (atomic, does not touch `updated_at`). The per-session map of last counted time is guarded by a lock on the map; the timestamp is written only after the DB update succeeded.
- Invalid `q`/`category`/`year` give 400 with field errors and the form keeps its values.
- Reviews/Q&A panels on detail belong to 005/006 and are not part of this module.

## Verification
- `MovieServiceTest` (26 tests): validation boundaries, paging, escaping, URL safety, view window and concurrency.
- E2E script (47 checks): Home, 23/10/10/3 paging, sort/filter/literal wildcards, 400/404 cases, per-session view counting.
