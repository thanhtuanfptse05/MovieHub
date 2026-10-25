# Tasks Breakdown: 004-favorites
<!-- Actionable, Dependency-Ordered Task List -->

- [x] **Task 1: Favorite Entity & Persistence Mapping**
  - Implement `Favorite.java` mapped to `Favorites` table with soft delete (`deleted_at`).
  - Register `Favorite` in `src/conf/persistence.xml`.
- [x] **Task 2: FavoriteDAO**
  - Implement `FavoriteDAO.java` (`isFavorited`, `findByUserAndMovie`, `addOrRestore`, `softRemove`, `findActiveMovieIdsByUser`, `countActiveByUser`).
  - Add `findById` to `MovieDAO.java`.
- [x] **Task 3: FavoriteService + Unit Tests (TDD)**
  - Create `FavoritePage` DTO and `NotFoundException`.
  - Write 22 unit tests in `FavoriteServiceTest.java` (100% green).
  - Implement `FavoriteService.java` with business rules (FAV-AC-01 through FAV-AC-09).
- [x] **Task 4: Servlets**
  - Implement `FavoriteListServlet` (`/favorites`), `FavoriteAddServlet` (`/favorites/add`), `FavoriteRemoveServlet` (`/favorites/remove`).
  - Update `MovieDetailServlet` to provide `isFavorited` state.
  - Register all three servlets in `web.xml`.
- [x] **Task 5: View (Pure JSTL)**
  - Implement `favorite-list.jsp` with responsive cinema-dark grid, card removal, and empty state.
  - Integrate "Yêu thích" action button into `movie-detail.jsp` with active/inactive states.
  - Add "Yêu thích" nav link in `header.tag`.
  - Update `style.css` with favorite styles.
- [x] **Task 6: Verification & Delivery**
  - Pass all 75 unit tests via `ant test`.
  - Pass all 49 E2E checks via `test_e2e_favorites.py`.
  - Verify zero mojibake in DB and rendered HTML (Verification Gate).
  - Commit `feat(favorite): implement personal favorites watchlist`.
  - Push branch `feat/004-favorites` to GitHub.
