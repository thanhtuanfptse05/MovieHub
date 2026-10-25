# 001-auth: xác thực và khôi phục mật khẩu

Ngày 2026-10-25 | Version 1.1.0 | Draft; thay đổi UC-03 được chủ dự án xác nhận | P0
Nguồn: UC-01, UC-02, UC-03; FR-01…04, FR-06; BR-01…04; BR-17 được thay bằng R-01 ngày 2026-10-25.
Áp dụng [quy tắc chung](../shared/system-rules.md), [dữ liệu](../shared/data-contract.md), D-02/D-05 và quyết định R-01 trong [decisions](../shared/decisions.md). SMTP, email xác thực, OTP và reset token không thuộc luồng mới.

## User Scenarios & Testing

### AUTH-US-01: đăng ký (P0)

Là Guest, tôi muốn đăng ký bằng tên/email/mật khẩu để lưu phim và tương tác. Kiểm thử độc lập: tạo tài khoản hợp lệ, không cần cộng đồng.

Given email chưa có và form hợp lệ, When đăng ký, Then tạo đúng một USER ACTIVE và chuyển login, chưa xác thực tự động.
Given email đã có dưới dạng khác hoa/thường/khoảng trắng, Then báo “Email đã được sử dụng”, không tạo hàng thứ hai.

### AUTH-US-02: login/logout và guard (P0)

Là thành viên, tôi muốn vào đúng phạm vi quyền và kết thúc phiên khi logout.

Given User ACTIVE nhập đúng credentials, Then hủy phiên cũ, tạo phiên mới, về returnTo an toàn hoặc Home.
Given Admin ACTIVE không có returnTo, Then vào /admin/dashboard.
Given đã logout, When dùng cookie cũ gọi /favorites, Then yêu cầu login, không trả dữ liệu cá nhân.

### AUTH-US-03: đặt lại mật khẩu bằng email đã đăng ký (P0)

Là người quên mật khẩu, tôi muốn nhập email đã đăng ký để được đặt mật khẩu mới ngay trên website, không nhận hay xác thực email.

Given email khớp tài khoản ACTIVE, When gửi form quên mật khẩu, Then được chuyển thẳng đến form đặt mật khẩu mới trong cùng phiên.
Given nhập mật khẩu mới và xác nhận hợp lệ, When gửi, Then chỉ đổi mật khẩu tài khoản đã chọn, thu hồi phiên đăng nhập cũ, chuyển login; không tạo tài khoản mới và không gửi email.
Given email không có/INACTIVE, Then báo “Email không tồn tại hoặc tài khoản không khả dụng”, không cho mở bước đặt mật khẩu.

### Edge Cases

Email sai format/canonical; email của USER hoặc ADMIN ACTIVE; tài khoản INACTIVE; context reset chưa có/hết phiên/đã dùng; sửa email/userId trong POST reset; hai forgot cùng phiên/khác tab; form cũ không được đổi password target mới; hai reset đồng thời; password sai biên/confirm; CSRF; DB rollback; account bị khóa/đổi mật khẩu sau bước nhập email.

## Requirements

### Đăng ký và đăng nhập

Đăng ký: form →validate fullName/email/password/confirm →normalize/unique →transaction tạo USER ACTIVE/hash BCrypt →303 login, không auto-login. Không nhận role/status từ client.

Login: verify BCrypt và ACTIVE, lỗi email không có/password sai/INACTIVE dùng cùng thông báo “Email hoặc mật khẩu không hợp lệ”. Thành công invalidate phiên cũ, tạo session ID mới, lưu ID/credentialsVersion và dữ liệu tối thiểu. Không tự khóa tài khoản sau 5 lần sai.

Logout POST có CSRF →invalidate phiên →303 Home. GET logout405. Protected request đối chiếu status/role/credentialsVersion hiện hành.

### Luồng quên mật khẩu mới (R-01)

1. GET /forgot-password hiển thị một trường email và nút “Tiếp tục”. POST có email/csrfToken; email trim/lowercase và validate theo data-contract.
2. Server xóa context reset trước đó của phiên ngay khi nhận một POST forgot có CSRF hợp lệ. Nếu email không hợp lệ/không có/INACTIVE: trả400 và lỗi, không để context cũ còn dùng được.
3. Nếu khớp một tài khoản ACTIVE: lưu context tạm trên server trong session gồm targetUserId, expectedCredentialsVersion lấy từ DB và flowVersion tăng dần trong phiên, rồi303 /reset-password. Không phát mã OTP/link/token reset, không gửi mail, không cần SMTP. Context chỉ giữ tài khoản đã chọn giữa hai màn hình, không chứng minh quyền sở hữu email. flowVersion là số phiên bản form để tránh hai tab nhầm target, không phải bí mật hay mã xác minh.
4. GET /reset-password cần context hiện hành, user còn ACTIVE và credentialsVersion chưa đổi. Thiếu/sai context →303 /forgot-password với thông báo “Vui lòng nhập lại email”. GET không đổi password.
5. Form mới nhận password,confirmPassword,flowVersion và csrfToken. Email đích nếu hiển thị là chỉ đọc từ server; userId/email/role/status do client thêm không có quyền chọn lại tài khoản. flowVersion phải khớp context đang giữ; form từ lần nhập email trước trả409 và giữ context mới, không đổi password của target mới.
6. POST reset kiểm tra lại context, trạng thái ACTIVE và expectedCredentialsVersion tại thời điểm ghi. Transaction đổi password_hash BCrypt, tăng credentialsVersion và updatedAt/version; không đổi role/status/email, không tạo Users mới.
7. Commit thành công xóa context, invalidate phiên hiện tại và làm mọi phiên đăng nhập cũ của user mất quyền ở request kế tiếp;303 /login, không auto-login. Thông báo “Đã đặt lại mật khẩu. Vui lòng đăng nhập”.
8. Password/confirm sai →400, không ghi, giữ context để sửa; không điền lại password. Khi CSRF hợp lệ nhưng context thiếu/đã dùng/hết phiên, credentialsVersion đổi hoặc user không còn ACTIVE →409, xóa context, yêu cầu nhập lại email. CSRF sai403 được xét trước lỗi context theo SYS-04; retry bằng cookie/CSRF của session đã invalidate có thể403. DB lỗi500/rollback, context còn dùng lại nếu trạng thái DB vẫn khớp.
9. Hai context trước cùng một lần reset có cùng expectedCredentialsVersion: chỉ một commit được, request còn lại409. Người dùng có thể bắt đầu lại bằng email sau đó; luồng này không giới hạn một lần reset cho tài khoản.
10. Context chỉ tồn tại trong session, hết hiệu lực theo session idle30 phút, không có expiry token15 phút. Một phiên chỉ giữ một target: nhập email khác thay thế context cũ.

Password theo data-contract, không tự cấp mật khẩu mặc định hay hiển thị mật khẩu gốc. Không bắt buộc mật khẩu mới khác mật khẩu cũ; nếu đặt trùng thì giá trị mật khẩu cũ vẫn đăng nhập được, nhưng các phiên cũ vẫn bị thu hồi.

### Giới hạn của R-01

Chỉ biết email của tài khoản ACTIVE là đủ để đặt lại password, kể cả email ADMIN. Không có bằng chứng sở hữu email hoặc xác thực chủ tài khoản. CSRF/session context giúp ràng buộc form và chống gửi giả từ site khác; chúng không khắc phục việc người lạ biết email có thể đổi password. Đây là hành vi trực tiếp người dùng yêu cầu, không được mô tả là khôi phục tài khoản có xác minh danh tính.

### Functional Requirements / Acceptance Criteria EARS

- AUTH-AC-01 (Ubiquitous): THE system SHALL áp dụng validation chung, BCrypt cost≥12, không lưu password/confirm plaintext.
- AUTH-AC-02 (Event-driven): WHEN Guest đăng ký hợp lệ THE system SHALL tạo một USER ACTIVE rồi303 login, không auto-login.
- AUTH-AC-03 (Unwanted): IF email canonical trùng kể cả race THEN THE system SHALL400 field error, không tạo duplicate.
- AUTH-AC-04 (Event-driven): WHEN login ACTIVE hợp lệ THE system SHALL invalidate phiên cũ, tạo session mới, redirect đúng role/returnTo.
- AUTH-AC-05 (Unwanted): IF login sai hoặc INACTIVE THEN THE system SHALL lỗi chung, không tạo phiên xác thực.
- AUTH-AC-06 (State-driven): WHILE phiên hết hạn/credentialsVersion cũ/user INACTIVE THE system SHALL hủy xác thực trước request bảo vệ tiếp theo.
- AUTH-AC-07 (Event-driven): WHEN logout POST hợp lệ THE system SHALL invalidate phiên và303 Home.
- AUTH-AC-08 (State-driven): WHILE actor không có quyền ADMIN THE system SHALL chặn /admin/*; Guest303 login, User403.
- AUTH-AC-09 (Event-driven): WHEN Guest nhập email của tài khoản ACTIVE THE system SHALL cho mở form đặt password ngay bằng context server; không gửi mail/OTP/reset token.
- AUTH-AC-10 (Unwanted): IF email sai/không tồn tại/INACTIVE THEN THE system SHALL400 lỗi, xóa context reset cũ và không cấp bước reset.
- AUTH-AC-11 (Event-driven): WHEN POST reset có context hiện hành và password hợp lệ THE system SHALL đổi hash/tăng credentialsVersion nguyên tử, xóa context và303 login.
- AUTH-AC-12 (Unwanted): IF context không có/đã dùng/hết phiên, account không ACTIVE hoặc credentialsVersion đổi THEN THE system SHALL không đổi password; GET303 forgot, POST có CSRF hợp lệ409 yêu cầu nhập lại email; flowVersion form cũ409 không đổi target mới.
- AUTH-AC-13 (Unwanted): IF hai reset cùng expectedCredentialsVersion cạnh tranh THEN THE system SHALL chỉ cho một commit; request còn lại409, không ghi đè.
- AUTH-AC-14 (State-driven): WHILE đã xác thực hợp lệ THE system SHALL chuyển GET login/register/forgot/reset về Home/dashboard; POST tương ứng409, yêu cầu logout trước.
- AUTH-AC-15 (Ubiquitous): THE system SHALL kiểm tra CSRF/returnTo theo SYS-04/SYS-06; không dùng email/userId client trong bước reset để chọn lại target.

### Hợp đồng giao tiếp

| Method/route | Input | Thành công | Lỗi |
|---|---|---|---|
| GET /register | Không | 200 form | SYS-04 |
| POST /register | fullName,email,password,confirmPassword,csrfToken | 303 /login | 400 |
| GET /login | returnTo? | 200 form | Đích không an toàn bị bỏ |
| POST /login | email,password,returnTo?,csrfToken | 303 đúng đích | 400 |
| POST /logout | csrfToken | 303 / | CSRF403; GET405 |
| GET /forgot-password | Không | 200 form email | SYS-04 |
| POST /forgot-password | email,csrfToken | 303 /reset-password | 400 sai email/account |
| GET /reset-password | Context server, không query email/token | 200 form password | 303 /forgot-password |
| POST /reset-password | password,confirmPassword,flowVersion,csrfToken; context server | 303 /login | 400 password;403 CSRF;409 flow/context/account stale;500 DB |

Không đặt password/email/userId/reset token vào URL. Target chỉ đến từ context server đã được chọn bởi bước email. Hai bước đều có CSRF. GET không được đổi password.

### Key Entities và giao dịch

UC-03 chỉ đọc/ghi Users, dùng credentialsVersion để chống ghi đè và thu hồi phiên. Không cần PasswordResetTokens, EmailUtil, SMTP hoặc mail provider. Bảng PasswordResetTokens trong schema nguồn nếu đã có được để nguyên không sử dụng; không tạo thêm hay truy vấn bảng đó cho luồng mới, không xóa dữ liệu DB trong lần sửa tài liệu này.

## Success Criteria

- AUTH-SC-01: Register hợp lệ tối đa1 user/email canonical, kể cả hai request.
- AUTH-SC-02: Protected/admin routes từ chối đúng actor sau logout/khóa/hạ role/reset.
- AUTH-SC-03: Email ACTIVE canonical mở reset ngay; email không có/INACTIVE không mở được; không phát sinh email/OTP/reset token.
- AUTH-SC-04: Reset sang password khác thành công thì password cũ không dùng được, password mới login được; mọi session cũ và context cũ mất hiệu lực.
- AUTH-SC-05: CSRF, target tamper, concurrent reset và DB rollback cho đúng kết quả; không lưu/log password plaintext.

## Assumptions / Out of Scope

R-01 do chủ dự án chỉ định thay luồng reset bằng email token trong nguồn. Không xác minh quyền sở hữu email, không SMTP/OTP/token/link, không tạo lại account hoặc mở khóa INACTIVE. D-02/D-05 và các phần spec khác vẫn là dự thảo chưa duyệt toàn bộ.
