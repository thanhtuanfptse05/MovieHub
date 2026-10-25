# Changelog: 005-reviews-rating
<!-- Spec & Implementation Evolution History -->

## [1.0.0] - 2026-10-26

- Hoàn thành triển khai toàn diện tính năng đánh giá và điểm phim theo `spec.md` v1.0.0.
- Cập nhật entity `Review` đầy đủ các trường (soft-delete `deleted_at`, optimistic locking `version`, `content_revision`, audit `moderated_by`, `moderated_at`, trạng thái `PENDING`, `APPROVED`, `REJECTED`).
- Triển khai `ReviewDAO` và `ReviewService` đáp ứng các yêu cầu EARS (REV-AC-01 đến REV-AC-11).
- Triển khai `ReviewSaveServlet` (`POST /reviews/save`), `ReviewDeleteServlet` (`POST /reviews/delete`) và cập nhật `MovieDetailServlet`.
- Cập nhật giao diện `movie-detail.jsp` với thẻ `#reviews`, khối "Đánh giá của bạn", biểu mẫu viết/sửa và danh sách đánh giá cộng đồng thuần JSTL/EL.
- 31 unit tests trong `ReviewServiceTest` và 13/13 kịch bản kiểm thử E2E live Tomcat đạt 100%.
- Kiểm chứng Anti-Mojibake: dữ liệu tiếng Việt trong DB và giao diện web đạt chuẩn UTF-8 sạch 100%.

## [0.1.0] - 2026-10-25
### Initialized
- Scaffolded feature spec, architecture plan, tasks, and validation checklists.
- Linked to UC-09, UC-15 and BR-11 through BR-15.
