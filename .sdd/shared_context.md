# MovieHub: ngữ cảnh bàn giao agent

Cập nhật 2026-10-25 | Giai đoạn: đặc tả MVP, chưa triển khai.

## Trạng thái đã xác nhận

- Đã đọc MovieHub_Project_Plan_Java_Ant.md và soạn lại 8 spec Draft; 001-auth hiện v1.1.0 theo R-01, bảy module còn lại v1.0.0. Bản đồ chuẩn: [specs/overview.md](../specs/overview.md).
- UC-14 là quản lý người dùng ở 007; UC-17 là phim tương tự ở 003. Không phải đổi mật khẩu/lịch sử xem.
- Đã phân rã đủ UC-01…17, FR-01…26, BR-01…24 nguồn; P0/P1 được phân biệt.
- User đã cho phép ĐỀ XUẤT bổ sung JAR cần thiết. Chưa có quyền tải/cài hay allowlist mới được duyệt. Đã yêu cầu R-01: email ACTIVE đúng cho đặt password mới trực tiếp, không xác thực/gửi email/OTP/reset token; auth spec hiện v1.1.0.
- Kiểm kê allowedlib không có JPA/Hibernate/BCrypt/mail provider; TLD JSTL 2.0 có URI cũ. Xem GOV-01 trong [decisions](../specs/shared/decisions.md).
- business.md cũ khác baseline; phần token reset trong hai constitution được cập nhật theo yêu cầu trực tiếp R-01. GOV-02 của các phần khác vẫn cần chủ dự án chốt trước code.
- plan.md/tasks.md/checklists.md cũ được giữ kèm cảnh báo, chưa đồng bộ. Chưa hoàn thành speckit-plan/tasks/analyze cho bản spec mới.
- Chưa build/deploy, chưa chạy unit/integration/browser/UAT; không dùng kiểm tra tài liệu để tuyên bố sản phẩm pass.

## Hợp đồng cần đọc trước khi lập kế hoạch

Quy định UI hiện hành: [ui_rule.md](../ui_rule.md) và [design.md](../design.md), theo yêu cầu trực tiếp R-02/R-03 ngày2026-10-25. Hai constitution và AGENTS.md v2.1.0 đã ghi rule cấm hardcode business data/mocks/fallback và cấm product-generated Business Rules/BR/FR/engineering copy trên cả public/admin. Chưa xây UI hoặc chạy browser trong lần soạn tài liệu thiết kế.

1. [system-rules](../specs/shared/system-rules.md)
2. [data-contract](../specs/shared/data-contract.md)
3. [decisions](../specs/shared/decisions.md)
4. spec module và [traceability](../specs/traceability.md)
5. [acceptance](../specs/acceptance.md)

Không thêm tính năng ngoài MVP, không tự bỏ JPA/BCrypt/reset password, không tự giải gate bằng dependency không duyệt. Sau khi chủ dự án duyệt: lập plan/tasks từng module, analyze, rồi triển khai theo AGENTS.md và skill bắt buộc.
