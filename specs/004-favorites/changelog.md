# Changelog: 004-favorites
<!-- Spec & Implementation Evolution History -->

## [1.0.0] - 2026-10-26
### Implemented & Verified
- Triển khai toàn bộ tính năng phim yêu thích cá nhân (004-favorites) tuân thủ EARS FAV-AC-01 đến FAV-AC-09.
- **Entity**: `Favorite` mapping bảng `Favorites` với xóa mềm (`deleted_at`).
- **DAO**: `FavoriteDAO` hỗ trợ `isFavorited`, `addOrRestore` (idempotent, khôi phục hàng đã xóa mềm), `softRemove`, phân trang danh sách phim `PUBLISHED`.
- **Service**: `FavoriteService` với 22 unit tests JUnit đạt 100% pass.
- **Servlets**: `FavoriteListServlet` (`/favorites`), `FavoriteAddServlet` (`/favorites/add`), `FavoriteRemoveServlet` (`/favorites/remove`), tích hợp `MovieDetailServlet`.
- **View**: `favorite-list.jsp` chuẩn giao diện cinema-dark, empty state, card bỏ yêu thích và phân trang; cập nhật nút yêu thích trên `movie-detail.jsp` và điều hướng `header.tag`.
- **Kiểm thử**: Toàn bộ 75 unit test và 49/49 E2E test đều pass 100%, bảo toàn 100% font tiếng Việt (Anti-mojibake Verification Gate).

## [0.1.0] - 2026-10-25
### Initialized
- Scaffolded feature spec, architecture plan, tasks, and validation checklists.
- Linked to UC-08 and BR-16, BR-17.
