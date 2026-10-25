# Hợp đồng dữ liệu MovieHub

Ngày 2026-10-25 | Draft. Nguồn: mục 9–10 kế hoạch. Đọc cùng [system-rules.md](system-rules.md) và [decisions.md](decisions.md). Đây là yêu cầu dữ liệu để lập plan, chưa phải migration đã chạy.

## 1. Quy tắc mọi bảng

ID BIGINT dương do server sinh, không cho client gán. FK phải tồn tại. Timestamp UTC do server tạo. Không hard-delete user/phim/review/question/answer/category. Favorite bỏ mềm để tương thích constitution, cần duyệt D-06. Không cascade xóa dữ liệu tương tác. Schema nguồn có 9 bảng; sau R-01 chỉ 8 bảng nghiệp vụ được dùng, PasswordResetTokens là bảng dự phòng lịch sử, không phụ thuộc của MVP. Nếu đã có bảng đó thì để nguyên không sử dụng, không yêu cầu xóa dữ liệu; không triển khai entity/DAO cho nó chỉ để làm UC-03.

Form sửa dùng version như SYS-05; plan có thể dùng cột số `version` hoặc cơ chế tương đương. Reviews cần thêm `content_revision` (mặc định 1, tăng mỗi khi đổi text/rating hoặc restore) để phân biệt bản nội dung với quyết định duyệt. Question/answer không sửa nội dung trong MVP, contentRevision trong form duyệt luôn 1. Session thu hồi sau reset cần `credentials_version` tăng nguyên tử trong Users và giá trị tương ứng ở session, hoặc cơ chế tương đương có test nhiều session; không dựa vào việc chỉ invalidate phiên mở reset.

## 2. Từ điển trường

| Bảng | Trường và ràng buộc nghiệp vụ |
|---|---|
| Users | id; full_name NVARCHAR(100) bắt buộc 1–100; email VARCHAR(255) canonical duy nhất; password_hash VARCHAR(255) không null; role USER/ADMIN; status ACTIVE/INACTIVE; avatar_url VARCHAR(500) tùy chọn; created_at,updated_at; version/credentials_version theo mục 1 |
| Movies | id; title NVARCHAR(200) 1–200; slug VARCHAR(250) 1–250 unique; description NVARCHAR(MAX) 1–10000; release_year số nguyên 1888…năm hiện tại+2; duration_minutes số nguyên 1…600; poster_url VARCHAR(1000) tùy DRAFT/publish; video_url,trailer_url VARCHAR(1000) tùy chọn; status DRAFT/PUBLISHED/HIDDEN; featured boolean mặc định false; view_count BIGINT không âm mặc định 0; created_at,updated_at; version |
| Categories | id; name NVARCHAR(100) 1–100, canonical unique; slug VARCHAR(120) 1–120 unique; created_at; deleted_at tùy chọn; version |
| MovieCategories | movie_id FK Movies + category_id FK Categories; khóa ghép duy nhất, không duplicate; mọi category đang gán phải chưa deleted |
| Favorites | id; user_id FK Users; movie_id FK Movies; created_at; deleted_at tùy chọn; unique(user_id,movie_id) kể cả khi đã bỏ mềm; restore cập nhật created_at thành lần thêm gần nhất |
| Reviews | id; user_id,movie_id FK; rating nguyên 1–5; content NVARCHAR(1000) 1–1000; status PENDING/APPROVED/REJECTED; moderated_by FK Users,moderated_at tùy chọn; created_at,updated_at; deleted_at; version; unique(user_id,movie_id) kể cả khi bỏ mềm |
| Questions | id; movie_id,user_id FK; content NVARCHAR(500) 10–500; status ba trạng thái duyệt; moderated_by,moderated_at tùy chọn; created_at; version |
| Answers | id; question_id,user_id FK; content NVARCHAR(1000) 1–1000; status ba trạng thái duyệt; moderated_by,moderated_at tùy chọn; created_at; version |
| PasswordResetTokens (lịch sử, không dùng) | Bảng trong schema nguồn cũ; R-01 bỏ nghiệp vụ phát/lưu/consume reset token. Không ghi/đọc bảng này khi quên mật khẩu và không cần tạo mới nó để nghiệm thu MVP |

Q&A không có thao tác xóa/sửa trong MVP nên không cần trường deleted_at cho hai bảng đó; từ chối/ẩn qua status. Nếu thêm xóa sau này phải tuân thủ DATA-01 bằng thay đổi spec trước.

## 3. Validation dùng chung

- Email: tối đa 255 ASCII, đúng một @; local-part 1–64 ký tự thuộc chữ/số và `. _ % + -`, không dấu chấm đầu/cuối/hai dấu chấm liên tiếp; domain có ít nhất hai nhãn ngăn bằng dấu chấm, mỗi nhãn 1–63 ký tự chữ/số/hyphen, không hyphen đầu/cuối. Đây là tập email MVP, không tuyên bố hỗ trợ mọi địa chỉ RFC/IDN. Normalize như SYS-03, unique không phân biệt hoa thường.
- Password/confirm: không trim/normalize; tối thiểu 8 code point và 8 byte UTF-8, tối đa 72 byte UTF-8; không NUL; confirm phải khớp tuyệt đối. Hash bằng BCrypt cost ≥12 với salt riêng. Không lưu confirm.
- Slug phim/thể loại: lowercase ASCII, mẫu `[a-z0-9]+(-[a-z0-9]+)*`, không khoảng trắng, giới hạn theo cột; người nhập chịu trách nhiệm chọn. Không dùng slug làm FK; URL canonical dùng id.
- Category name unique theo NFC + trim + lowercase độc lập locale, phân biệt dấu. Unique phải được bảo đảm khi ghi đồng thời, không phụ thuộc collation mặc định có thể accent-insensitive; plan chọn khóa canonical/collation phù hợp. Tên/slug đã xóa mềm vẫn giữ unique; chưa có restore category trong MVP.
- URL avatar/poster: HTTPS tuyệt đối, không userinfo/control characters; dev chỉ cho HTTP host chính xác localhost hoặc 127.0.0.1. Độ dài theo cột. Không chấp nhận javascript/data/file, HTML iframe hoặc scheme-relative. Không server-fetch URL để validate; browser tải ảnh, lỗi dùng placeholder.
- Video/trailer: cùng quy tắc URL, path kết thúc `.mp4` không phân biệt hoa thường, được có query; không coi link trang YouTube là MP4. Tình trạng mạng/Content-Type thực phải test bằng browser. Thiếu hoặc URL hợp lệ nhưng không phát được xử lý fallback, không báo đã phát thành công.
- Nội dung review/Q&A là plain text; trim + NFC, giữ xuống dòng khi hiển thị an toàn. Chuỗi rỗng/toàn whitespace không hợp lệ. Không xóa thẻ HTML rồi coi là sạch; lưu text hợp lệ và escape khi render.

## 4. Điều kiện xuất bản và chuyển trạng thái

Tạo phim mặc định DRAFT. Mọi save yêu cầu title/slug/description/year/duration hợp lệ. DRAFT có thể chưa có poster, video và category. PUBLISHED cần poster hợp lệ và ít nhất một category chưa deleted; video/trailer có thể trống để hiển thị “Chưa có video”. HIDDEN giữ dữ liệu đã có và được sửa theo validation cơ bản; nếu chuyển PUBLISHED phải validate đủ lại.

Phim chuyển giữa DRAFT/PUBLISHED/HIDDEN bởi Admin qua form versioned; không có hard-delete. Nút “Ẩn” đặt HIDDEN idempotent; chỉ bấm “Xuất bản”/chọn PUBLISHED có xác nhận mới public lại. Category xóa mềm chỉ khi không còn bất kỳ MovieCategories nào, kể cả phim DRAFT/HIDDEN. Không tự bỏ liên kết để ép xóa.

## 5. Ràng buộc duyệt và xóa review

Mới/resubmit/sửa review → PENDING, moderated_by/at rỗng; review đã APPROVED sửa xong mất điểm public ngay. Approve/reject thật sự ghi moderator/time. No-op không đổi audit. Bỏ review đặt deleted_at, không giữ điểm public; create lại restore đúng hàng và PENDING. Admin không sửa lời tác giả thay họ. Moderation question/answer giữ FK và status của con khi ẩn cha.

## 6. Bộ seed để nghiệm thu

30–50 phim; ít nhất 6 category; ít nhất 1 Admin ACTIVE và 2 User ACTIVE. Có phim cả 3 status, năm/view đa dạng, phim nhiều category, phim chưa review/video. 15 favorite active, 20 review đa trạng thái, 10 question và 10 answer hợp lệ cả trạng thái chờ/đã duyệt; có question APPROVED với answer PENDING. Bản ghi test ID/oracle cố định trong acceptance.md là fixture riêng, không thay toàn bộ seed.

Seed chạy lại không nhân đôi; dùng khóa business ổn định, không reset password/tương tác đã đổi nếu không có chế độ reset DB test riêng được chỉ rõ. Password demo nhập từ biến môi trường và hash, không đưa plaintext vào repo. Assets có nguồn và quyền sử dụng; cấu hình DB secret ngoài Git. Không seed reset token hoặc yêu cầu SMTP theo R-01. Chưa coi seed, schema hoặc môi trường là đã được tạo trong lần soạn spec.
