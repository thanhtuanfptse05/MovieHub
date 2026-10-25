# Changelog: 001-auth (User Authentication & Password Recovery)
<!-- Spec & Implementation Evolution History -->

## [1.1.0 Draft] - 2026-10-25

- Chủ dự án chỉ định R-01: nhập email ACTIVE để mở form đặt mật khẩu mới trực tiếp; bỏ gửi/xác thực email, OTP, reset token và SMTP.
- Bổ sung context server, expectedCredentialsVersion/flowVersion, kiểm tra target/form cũ, rollback và thu hồi phiên; không tạo lại account hay mở khóa INACTIVE.
- Đồng bộ data-contract, system-rules, decisions, acceptance, API và hai constitution; không thay code hoặc dữ liệu DB.
- Ghi rõ không xác minh quyền sở hữu email; người biết email ACTIVE có thể đổi password của tài khoản đó.

## [1.0.0 Draft] - 2026-10-25

- Viết lại spec từ kế hoạch nguồn: nghiệp vụ, EARS, contracts, validation, concurrency và success criteria; xem overview và tài liệu shared.
- Chưa triển khai, chưa duyệt baseline; plan/tasks/checklists cũ cần tạo lại. Có requirements checklist mới.

## [0.1.0] - 2026-10-25
### Initialized
- Scaffolded feature spec, architecture plan, tasks, and validation checklists.
- Linked to UC-01, UC-02, UC-03 and BR-01 through BR-05.
