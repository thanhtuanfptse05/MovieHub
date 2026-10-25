# Implementation Plan: 004-favorites
<!-- Architecture & Engineering Plan -->

## 1. Architectural Layers & File Map
- **Entities**:
  - `com.moviehub.entity.Favorite` (Table: `Favorites`, identity PK `id`, FKs `user_id`, `movie_id`, `created_at`, `deleted_at`)
  - Registered in `src/conf/persistence.xml`
- **DAOs**:
  - `com.moviehub.dao.FavoriteDAO` (`isFavorited`, `findByUserAndMovie`, `addOrRestore`, `softRemove`, `findActiveMovieIdsByUser`, `countActiveByUser`)
  - `com.moviehub.dao.MovieDAO` (`findById`)
- **DTOs & Exceptions**:
  - `com.moviehub.dto.FavoritePage` (`items`, `page`, `totalPages`, `totalCount`)
  - `com.moviehub.exception.NotFoundException` (maps to 404)
- **Services**:
  - `com.moviehub.service.FavoriteService` (`isFavorited`, `addFavorite`, `removeFavorite`, `getFavorites`)
- **Controllers (Servlets)**:
  - `com.moviehub.controller.favorite.FavoriteListServlet` (`/favorites`, GET)
  - `com.moviehub.controller.favorite.FavoriteAddServlet` (`/favorites/add`, POST)
  - `com.moviehub.controller.favorite.FavoriteRemoveServlet` (`/favorites/remove`, POST)
  - `com.moviehub.controller.movie.MovieDetailServlet` (injected with `isFavorited` state)
- **Views & Tags (Pure JSTL)**:
  - `web/WEB-INF/views/favorite/favorite-list.jsp`
  - `web/WEB-INF/views/movie/movie-detail.jsp` (integrated favorite toggle form/button)
  - `web/WEB-INF/tags/header.tag` (nav link to `/favorites`)
  - `web/assets/css/style.css`

## 2. Verification Strategy
- Unit tests: `FavoriteServiceTest.java` (22 tests covering idempotency, soft-delete restore, 404 on hidden/missing movies, and pagination).
- E2E tests: `test_e2e_favorites.py` (49 assertions covering guest protection, add, remove, soft-delete, hidden movie filtering, and anti-mojibake verification).
