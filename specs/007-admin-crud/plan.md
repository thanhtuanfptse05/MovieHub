> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Implementation Plan: 007-admin-crud
<!-- Architecture & Engineering Plan -->

## 1. Architectural Layers & File Map
- **Filters**:
  - `com.moviehub.filter.AdminAuthFilter` (Protects `/admin/*`)
- **Entities**: `Movie`, `Category`, `User`
- **DAOs**: `MovieDAO`, `CategoryDAO`, `UserDAO`
- **Services**:
  - `com.moviehub.service.AdminMovieService`
  - `com.moviehub.service.AdminCategoryService`
  - `com.moviehub.service.AdminUserService`
- **Controllers (Servlets)**:
  - `com.moviehub.controller.admin.AdminMovieServlet` (`/admin/movies/*`)
  - `com.moviehub.controller.admin.AdminCategoryServlet` (`/admin/categories/*`)
  - `com.moviehub.controller.admin.AdminUserServlet` (`/admin/users/*`)
- **Views (JSP + JSTL)**:
  - `web/WEB-INF/views/admin/movie-manage.jsp`
  - `web/WEB-INF/views/admin/movie-form.jsp`
  - `web/WEB-INF/views/admin/category-manage.jsp`
  - `web/WEB-INF/views/admin/user-manage.jsp`

## 2. Verification Strategy
- Unit tests: `AdminMovieServiceTest.java`, `AdminUserServiceTest.java`.
- Integration tests: `AdminAuthFilterTest.java` (Ensure non-admins cannot access `/admin/*`).
