# Implementation Plan: 004-favorites
<!-- Architecture & Engineering Plan -->

## 1. Architectural Layers & File Map
- **Entities**: `com.moviehub.entity.Favorite` (Table: `Favorites`, composite key `(userId, movieId)`)
- **DAOs**: `com.moviehub.dao.FavoriteDAO` (`findByUser`, `exists`, `add`, `remove`)
- **Services**: `com.moviehub.service.FavoriteService`
- **Controllers (Servlets)**:
  - `com.moviehub.controller.favorite.FavoriteServlet` (`/favorites`, `/favorites/add`, `/favorites/remove`)
- **Views (JSP + JSTL)**:
  - `web/WEB-INF/views/favorite/favorite-list.jsp`

## 2. Verification Strategy
- Unit tests: `FavoriteServiceTest.java` (Duplicate check, add/remove logic).
- Web tests: Verify heart icon state toggles and items display in list.
