> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Tasks Breakdown: 008-admin-analytics
<!-- Actionable, Dependency-Ordered Task List -->

- [ ] **Task 1: AnalyticsDAO**
  - Implement aggregated JPQL queries for metrics and top movie lists.
- [ ] **Task 2: AnalyticsService (TDD)**
  - Write unit tests in `AnalyticsServiceTest.java`.
  - Implement `AnalyticsService.java`.
- [ ] **Task 3: AdminDashboardServlet**
  - Implement `/admin/dashboard` controller binding metrics to request attributes.
- [ ] **Task 4: Views (Pure JSTL)**
  - Implement `dashboard.jsp` with responsive statistic cards and top tables using `<c:forEach>`.
- [ ] **Task 5: Verification & Delivery**
  - Pass 15-item validation gate.
  - Commit `feat(analytics): implement admin executive dashboard and reports`.
  - Push branch `feat/008-admin-analytics` to GitHub.
