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
