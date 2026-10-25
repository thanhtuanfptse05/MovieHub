> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Implementation Plan: 003-movie-catalog
<!-- Architecture & Engineering Plan -->

## 1. Architectural Layers & File Map
- **Entities**:
  - `com.moviehub.entity.Movie` (Table: `Movies`)
  - `com.moviehub.entity.Category` (Table: `Categories`)
- **DAOs**:
  - `com.moviehub.dao.MovieDAO` (`findPaginated`, `filterMovies`, `searchMovies`, `findById`, `incrementViewCount`)
  - `com.moviehub.dao.CategoryDAO` (`findAllActive`)
- **Services**:
  - `com.moviehub.service.MovieService`
  - `com.moviehub.service.CategoryService`
- **Controllers (Servlets)**:
  - `com.moviehub.controller.movie.MovieListServlet` (`/movies`)
  - `com.moviehub.controller.movie.MovieSearchServlet` (`/movies/search`)
  - `com.moviehub.controller.movie.MovieDetailServlet` (`/movies/detail`)
- **Views (JSP + JSTL)**:
  - `web/WEB-INF/views/movie/movie-list.jsp`
  - `web/WEB-INF/views/movie/movie-detail.jsp`

## 2. Verification Strategy
- Unit tests: `MovieServiceTest.java` (Filter combinations, pagination bounds).
- Web tests: Search query execution, category filter checks, pagination page traversal.
