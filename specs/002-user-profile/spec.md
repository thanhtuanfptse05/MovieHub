# 002-user-profile: hồ sơ cá nhân

Ngày 2026-10-25 | Version 1.0.0 | Draft | P0
Nguồn UC-04, FR-05, NFR-03,04,10. UC-14 thuộc 007.
Áp dụng [quy tắc chung](../shared/system-rules.md), [dữ liệu](../shared/data-contract.md), D-10/D-11.

## User Scenarios & Testing

### PROFILE-US-01: đọc hồ sơ (P0)

Là User/Admin ACTIVE, tôi muốn thấy tên, email, avatar và ngày tham gia của chính mình.
Given U1 và U2 tồn tại, When U1 mở profile kèm userId=U2, Then chỉ hồ sơ U1 được trả về; không lộ U2.
Giá trị/kiểm thử độc lập: chỉ cần login và Users seed, không cần phim hay review.

### PROFILE-US-02: cập nhật (P0)

Là thành viên, tôi muốn sửa tên/avatar để hồ sơ hiển thị đúng.
Given profile version=3, When sửa fullName/avatarUrl hợp lệ, Then lưu đúng hai trường, tăng version, redirect profile và refresh tên/avatar trong phiên.
Given avatarUrl trống, When save, Then bỏ avatar và dùng placeholder.
Given hai tab cùng version, When tab thứ hai save sau tab đầu, Then 409, không ghi đè.

### Edge Cases

Guest/session bị thu hồi; tên toàn whitespace; 100/101 ký tự; avatar URL nguy hiểm/quá 500; ảnh HTTPS trả 404; client gửi role/status/email/password; DB rollback; admin khóa tài khoản lúc form đang mở.

## Requirements

### Luồng và quyền

GET lấy tài khoản theo ID từ session đã guard. Hiện fullName, email chỉ đọc, avatar/placeholder, createdAt hiển thị timezone chung. Không trả password_hash, token hoặc thông tin tài khoản khác.

POST chỉ nhận fullName, avatarUrl, version và csrfToken. Validate theo data-contract, kiểm tra phiên và version, transaction cập nhật, cập nhật dữ liệu display trong phiên, 303 /profile với flash “Đã cập nhật hồ sơ”. Không đổi createdAt,email,role,status,password_hash hay credentialsVersion. updatedAt chỉ đổi khi dữ liệu thực sự đổi. Submit không đổi gì là thành công no-op.

### Functional Requirements / Acceptance Criteria EARS

- PROFILE-AC-01 (State-driven): WHILE Guest hoặc phiên không còn hợp lệ THE system SHALL chuyển tới login trước khi đọc/ghi profile.
- PROFILE-AC-02 (Ubiquitous): THE system SHALL xác định chủ hồ sơ từ phiên, không từ query/body userId.
- PROFILE-AC-03 (Event-driven): WHEN mở profile THE system SHALL hiện tên/email/ngày tham gia/avatar chính mình và không trả trường nhạy cảm.
- PROFILE-AC-04 (Event-driven): WHEN cập nhật hợp lệ THE system SHALL lưu tên/avatar nguyên tử và hiển thị dữ liệu mới ở lần GET tiếp theo.
- PROFILE-AC-05 (Unwanted): IF tên/URL không hợp lệ THEN THE system SHALL trả form 400 với lỗi field và không thay dữ liệu.
- PROFILE-AC-06 (Event-driven): WHEN avatarUrl trống THE system SHALL lưu giá trị rỗng chuẩn hóa/null và dùng placeholder.
- PROFILE-AC-07 (Unwanted): IF URL ảnh hợp lệ nhưng tải lỗi THEN THE system SHALL hiện placeholder, không làm hỏng profile.
- PROFILE-AC-08 (Unwanted): IF version cũ hoặc tài khoản không ACTIVE tại lúc ghi THEN THE system SHALL không ghi đè; conflict 409 hoặc mất xác thực theo SYS-01.
- PROFILE-AC-09 (Ubiquitous): THE system SHALL bỏ qua field ngoài allowlist; không thay email/role/status/password từ profile.
- PROFILE-AC-10 (Ubiquitous): THE system SHALL escape tên/avatar attribute và áp dụng CSRF, transaction, no-cache theo SYS-06.

### Hợp đồng giao tiếp

| Method/route | Input | Output |
|---|---|---|
| GET /profile | Không cần userId | 200 profile của session; Guest 303 login |
| POST /profile | fullName 1–100; avatarUrl optional ≤500; version bắt buộc; csrfToken | 303 /profile; 400 field errors; 403 CSRF; 409 version; 500 rollback |

Không có /users/{id}/profile công khai, không /change-password trong MVP. Giao diện dưới WEB-INF/views/user/, việc chọn filename chính xác thuộc plan.

### Key Entities

Users; chỉ full_name,avatar_url,updated_at,version thay đổi. Cập nhật tên/avatar làm tác giả review/Q&A hiển thị tên/ảnh hiện hành theo SYS-02. Không snapshot thông tin hồ sơ vào bản ghi tương tác.

## Success Criteria

- PROFILE-SC-01: U1 không đọc/sửa U2 qua bất kỳ userId client gửi.
- PROFILE-SC-02: Sau save, tên/avatar đúng ở profile và nội dung do user viết khi mở lại.
- PROFILE-SC-03: Mọi input invalid không mutation; conflict hai tab không mất bản cập nhật đầu.
- PROFILE-SC-04: Có placeholder khi avatar rỗng/lỗi và form dùng được ở ba viewport SYS-06.

## Assumptions / Out of Scope

Chỉ tên/avatar. Bio, thay email, đổi password trực tiếp, upload file, tổng hợp hoạt động và trang profile công khai không nằm trong nguồn MVP. Khôi phục mật khẩu thuộc 001; quản lý người dùng/role thuộc 007.
