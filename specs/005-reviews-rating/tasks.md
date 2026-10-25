> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Tasks Breakdown: 005-reviews-rating
<!-- Actionable, Dependency-Ordered Task List -->

- [ ] **Task 1: Review Entity**
  - Implement `Review.java` with foreign keys to `User` and `Movie`.
- [ ] **Task 2: ReviewDAO**
  - Implement CRUD and aggregate average calculation via JPQL.
- [ ] **Task 3: ReviewService (TDD)**
  - Write unit tests in `ReviewServiceTest.java`.
  - Implement business logic (BR-11 through BR-15).
- [ ] **Task 4: Servlets**
  - Implement `ReviewServlet` and `AdminReviewServlet`.
- [ ] **Task 5: Views (Pure JSTL)**
  - Build review submission form and list components.
- [ ] **Task 6: Verification & Delivery**
  - Pass 15-item validation gate.
  - Commit `feat(review): implement movie reviews, ratings, and moderation`.
  - Push branch `feat/005-reviews-rating` to GitHub.
