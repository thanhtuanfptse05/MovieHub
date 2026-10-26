# Tasks Breakdown: 008-admin-analytics
<!-- Actionable, Dependency-Ordered Task List -->

- [x] **Task 1: DTO Models**
  - Implement `AdminDashboardDTO.java`, `TopMovieDTO.java`, `CategoryStatDTO.java` under `com.moviehub.dto`.
- [x] **Task 2: AnalyticsDAO**
  - Implement `AnalyticsDAO.java` with JPQL aggregate queries adhering to KPI-01 through KPI-09 and P1 category counts.
- [x] **Task 3: AnalyticsService (TDD)**
  - Write comprehensive unit tests in `test/com/moviehub/service/AnalyticsServiceTest.java`.
  - Implement `AnalyticsService.java` handling data formatting, empty states, and error propagation.
  - Verify all unit tests pass with `ant test`.
- [x] **Task 4: AdminDashboardServlet & Web Configuration**
  - Implement `AdminDashboardServlet.java` (`/admin/dashboard`).
  - Configure servlet mappings in `web.xml` (including `/admin` redirecting to `/admin/dashboard`).
- [x] **Task 5: Admin Dashboard View (Pure JSTL)**
  - Create `/WEB-INF/views/admin/dashboard.jsp` with cinema-grade styling, KPI stat cards, top 5 movies table, category distribution, and clear empty states.
  - Ensure 100% pure JSTL/EL, zero scriptlets, proper escaping.
- [x] **Task 6: E2E Verification & Anti-Mojibake Gate**
  - Run `test_e2e_analytics.py` verifying authorization guards, KPI accuracy, and anti-mojibake checks.
  - Run full suite `ant test` to ensure zero regressions across all 7 test suites.
- [x] **Task 7: Delivery & Commit**
  - Check 15-item validation gate.
  - Git commit conforming to conventional commits: `feat(analytics): implement admin dashboard and KPI analytics`.
  - Push branch `feat/008-admin-analytics` to remote repository.
