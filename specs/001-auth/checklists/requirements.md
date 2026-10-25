# Specification Quality Checklist

Ngày 2026-10-25 | Đánh giá chất lượng bản Draft bởi người soạn, không phải kiểm thử ứng dụng.
Feature: [spec.md](../spec.md)

## Nội dung và yêu cầu

- [x] Có mục tiêu, actor và giá trị độc lập.
- [x] Phạm vi P0/P1 và out of scope rõ.
- [x] Có user scenarios và Given/When/Then.
- [x] Có EARS Ubiquitous, Event-driven, State-driven, Unwanted phù hợp.
- [x] Yêu cầu có mã AC duy nhất trong hệ thống.
- [x] Trường đầu vào/validation/quyền sở hữu đã xác định.
- [x] Luồng chính, lỗi và trạng thái rỗng có kết quả.
- [x] Quy tắc dữ liệu/uniqueness/status dùng hợp đồng chung.
- [x] Đồng thời/retry/stale form phù hợp phạm vi được nêu.
- [x] Success criteria có thể kiểm chứng, không coi là đã đạt.
- [x] Phụ thuộc module và gate môi trường được dẫn chiếu.
- [x] Giả định người soạn tách khỏi yêu cầu nguồn và xác nhận người dùng.
- [x] Có truy vết FR/UC và kịch bản acceptance.
- [x] Hợp đồng giao tiếp tách rõ khỏi ý nghĩa nghiệp vụ.
- [ ] Chủ dự án đã duyệt spec và các D-* áp dụng.
- [ ] GOV-01/GOV-02 đã chốt; ENV-01 đủ cho phần phụ thuộc trước implementation.

## Kết luận

Rà lại theo auth v1.1.0/R-01 ngày 2026-10-25: quên mật khẩu không gửi/xác thực email, không SMTP/OTP/reset token. Target/context/flowVersion, phiên cũ, race/rollback và giới hạn không xác minh chủ email được đặc tả. Người dùng đã chỉ định R-01; gate duyệt toàn bộ spec/JAR vẫn để trống.

14/16 tiêu chí soạn Draft đã đạt khi rà nội dung; 2 gate duyệt/triển khai còn mở.
Không có placeholder nội dung bị bỏ trống. Các lựa chọn dự thảo chưa đồng nghĩa phê duyệt.
plan.md/tasks.md/checklists.md cũ chưa được đồng bộ; cần tạo lại rồi speckit-analyze trước code.
Custom checklist reviewer-owned nằm ở [business-logic.md](../../checklists/business-logic.md), vẫn để trống.
