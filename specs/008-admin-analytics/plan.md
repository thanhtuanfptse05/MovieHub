> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Implementation Plan: 008-admin-analytics
<!-- Architecture & Engineering Plan -->

## 1. Architectural Layers & File Map
- **DAOs**: `com.moviehub.dao.AnalyticsDAO` (`getSummaryCounts`, `getTopViewedMovies`, `getTopRatedMovies`)
- **Services**: `com.moviehub.service.AnalyticsService`
- **Controllers (Servlets)**:
  - `com.moviehub.controller.admin.AdminDashboardServlet` (`/admin/dashboard`)
- **Views (JSP + JSTL)**:
  - `web/WEB-INF/views/admin/dashboard.jsp`

## 2. Verification Strategy
- Unit tests: `AnalyticsServiceTest.java`.
- Web tests: Verify dashboard counter cards, chart/table data rendering with JSTL.
