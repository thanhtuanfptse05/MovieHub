# Tasks Breakdown: 003-movie-catalog
<!-- Actionable, Dependency-Ordered Task List -->

- [ ] **Task 1: Movie & Category Entities**
  - Implement `Movie.java` with many-to-many or join relation to `Category.java`.
- [ ] **Task 2: MovieDAO & CategoryDAO**
  - Implement dynamic JPQL filtering query in `MovieDAO.java`.
  - Implement `searchMovies(keyword)` and `incrementViewCount(movieId)`.
- [ ] **Task 3: MovieService (TDD)**
  - Write unit tests in `MovieServiceTest.java`.
  - Implement pagination calculations and filter coordination.
- [ ] **Task 4: Servlets**
  - Implement `MovieListServlet`, `MovieSearchServlet`, `MovieDetailServlet`.
- [ ] **Task 5: JSP Views (Pure JSTL)**
  - Implement `movie-list.jsp` with responsive card grid.
  - Implement `movie-detail.jsp` with video/trailer embed.
- [ ] **Task 6: Verification & Delivery**
  - Pass 15-item validation gate.
  - Commit `feat(catalog): implement movie browsing, filtering, search, and details`.
  - Push branch `feat/003-movie-catalog` to GitHub.
