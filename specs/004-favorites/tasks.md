> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Tasks Breakdown: 004-favorites
<!-- Actionable, Dependency-Ordered Task List -->

- [ ] **Task 1: Favorite Entity**
  - Implement `Favorite.java` with composite PK or `@IdClass`.
- [ ] **Task 2: FavoriteDAO**
  - Implement `addFavorite`, `removeFavorite`, `findByUserId`, `isFavorited`.
- [ ] **Task 3: FavoriteService (TDD)**
  - Write unit tests in `FavoriteServiceTest.java`.
  - Implement `FavoriteService.java`.
- [ ] **Task 4: FavoriteServlet**
  - Implement `FavoriteServlet` with actions `list`, `add`, `remove`.
- [ ] **Task 5: View (Pure JSTL)**
  - Implement `favorite-list.jsp`.
- [ ] **Task 6: Verification & Delivery**
  - Pass 15-item validation gate.
  - Commit `feat(favorite): implement personal favorites watchlist`.
  - Push branch `feat/004-favorites` to GitHub.
