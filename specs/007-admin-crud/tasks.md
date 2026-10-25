> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Tasks Breakdown: 007-admin-crud
<!-- Actionable, Dependency-Ordered Task List -->

- [ ] **Task 1: AdminAuthFilter**
  - Implement filter checking `role == 'ADMIN'` for `/admin/*`.
- [ ] **Task 2: Admin Services (TDD)**
  - Implement `AdminMovieService`, `AdminCategoryService`, `AdminUserService`.
  - Write unit tests enforcing BR-07, BR-08, BR-09, BR-22, BR-23.
- [ ] **Task 3: Admin Servlets**
  - Implement `AdminMovieServlet`, `AdminCategoryServlet`, `AdminUserServlet`.
- [ ] **Task 4: Admin Views (Pure JSTL)**
  - Build admin dashboard layout and management forms with `<c:out>`.
- [ ] **Task 5: Verification & Delivery**
  - Pass 15-item validation gate.
  - Commit `feat(admin): implement admin entity management for movies, categories, users`.
  - Push branch `feat/007-admin-crud` to GitHub.
