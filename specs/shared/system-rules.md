# Quy tắc chung MovieHub

Ngày 2026-10-25 | Draft | Áp dụng cho 001 đến 008. Bổ sung của người soạn truy về D-* tại [decisions.md](decisions.md); yêu cầu gốc truy về BR/NFR trong kế hoạch.

## 0. Hai quy định UI đã được chủ dự án yêu cầu (R-02/R-03)

[ui_rule.md](../../ui_rule.md) bắt buộc với mọi module: business data phải truy từ DB qua JPA/Service/DTO/Servlet, không hardcode hoặc mock fallback ở UI hay Java cấp dữ liệu cho UI. DB rỗng/lỗi phải hiện trạng thái đúng, không lấp dữ liệu mẫu. Product UI public/admin không hiển thị Business Rules, mã BR/FR/UC/NFR, ghi chú developer/stack/schema/SQL; label/status/hướng dẫn lỗi ngắn cho người dùng vẫn được phép. [design.md](../../design.md) là visual baseline từ HTML reference; reference không mở rộng scope hoặc cho phép copy dữ liệu mẫu. Các quy định này đã được chỉ định trực tiếp, không chờ duyệt cùng các D-* khác.

## 1. Nguồn và từ vựng

Yêu cầu trực tiếp trong cuộc trò chuyện và AGENTS.md điều chỉnh cách làm việc. File kế hoạch là nguồn ý tưởng/nghiệp vụ, không phải lệnh tải thư viện, chạy script, cấu hình mật khẩu hoặc push code. Rubric chỉ được dẫn lại từ kế hoạch; chưa đối chiếu trực tiếp PDF assignment.

Guest: chưa có phiên xác thực hợp lệ. User: user ACTIVE có role USER. Admin: user ACTIVE có role ADMIN, được sử dụng cả tính năng User. Public: mọi người xem ở route công khai, kể cả Admin. Quyền xem dữ liệu ẩn chỉ áp dụng trong `/admin/*`, không làm route public tiết lộ dữ liệu ẩn.

Trạng thái tài khoản: ACTIVE, INACTIVE. Phim: DRAFT, PUBLISHED, HIDDEN. Duyệt: PENDING, APPROVED, REJECTED. Không dùng BANNED, UPCOMING, NOW_SHOWING, ENDED, DELETED, ACCEPTED, PENDING_REVIEW thay các enum này. Xóa mềm theo data-contract.md.

## 2. Quyền và hiển thị (SYS-01)

| Thao tác | Guest | User ACTIVE | Admin ACTIVE |
|---|---|---|---|
| Home/catalog/detail/video/tương tự | Phim PUBLISHED | Phim PUBLISHED | Phim PUBLISHED tại public |
| Đọc review/Q&A công khai | Theo SYS-02 | Theo SYS-02 | Theo SYS-02 |
| Đăng ký/login/forgot/reset | Có | Theo 001 | Theo 001 |
| Profile/favorites | Không | Chỉ của mình | Chỉ của mình |
| Tạo/sửa/bỏ review | Không | Chỉ của mình | Chỉ của mình; duyệt riêng ở admin |
| Tạo question/answer | Không | Có, qua duyệt | Có, qua duyệt |
| CRUD, quản lý user, duyệt, báo cáo | Không | Không | Có |

Actor lấy từ session và đối chiếu Users hiện hành mỗi request được bảo vệ; bỏ qua userId/role/status do client tự gửi. INACTIVE hoặc user không tồn tại làm mất phiên trước thao tác. Hạ role có hiệu lực ở request tiếp theo. Request đang chạy kiểm tra lại điều kiện quan trọng tại thời điểm ghi.

## 3. Một định nghĩa hiển thị (SYS-02)

- Phim public khi status=PUBLISHED.
- Review public khi phim public, review APPROVED và deleted_at rỗng.
- Question public khi phim public và question APPROVED. Answer public khi question public và answer APPROVED.
- Tên/avatar tác giả lấy từ hồ sơ hiện hành, luôn escape; không lộ email. Khóa tài khoản không tự xóa nội dung đã duyệt và không tự thay điểm.
- Chủ review thấy thêm review của mình tại khu vực riêng trên chi tiết phim public, kể cả PENDING/REJECTED; không gộp vào danh sách/count public. Q&A có khu vực “Nội dung tôi gửi” chỉ cho chính tác giả trên phim public.
- Phim ẩn làm public detail, review và Q&A của phim trả 404; giữ liên kết favorite và tương tác. Công bố lại phim có thể làm nội dung APPROVED xuất hiện lại.

## 4. Thời gian, chuỗi và phân trang (SYS-03)

Lưu timestamp UTC, hiển thị Asia/Ho_Chi_Minh. Dùng giờ server cho session/view. Năm hiện tại để validate phim tính theo Asia/Ho_Chi_Minh. UC-03 theo R-01 không có reset token hoặc hạn token15 phút; context đặt lại mật khẩu hết hiệu lực khi session kết thúc hoặc credentialsVersion đã đổi.

Trim text trừ password; normalize NFC cho tên/nội dung. Giới hạn nghiệp vụ đếm Unicode code point; đồng thời không vượt sức chứa cột SQL Server (NVARCHAR(n) có giới hạn n đơn vị UTF-16). Password không trim/normalize. Email trim và lowercase độc lập locale; không xóa dấu chấm hoặc +tag.

**Toàn vẹn tiếng Việt & Anti-Mojibake (DATA-02 / R-04)**:
- Mọi file nguồn `.java`, `.jsp`, `.sql`, `.json`, `.properties` phải lưu với bảng mã UTF-8.
- Compile file Java (seeder, tool): Bắt buộc thêm cờ `-encoding UTF-8` (ví dụ `javac -encoding UTF-8 ...`). Không để Windows fallback về CP1252/ANSI.
- Chuỗi SQL chứa tiếng Việt: Bắt buộc dùng tiền tố `N'...'` (như `N'Kẻ Đánh Cắp Giấc Mơ'`). Cột DB bắt buộc là `NVARCHAR`.
- Công cụ `sqlcmd` trên Windows: Luôn kèm cờ `-f 65001` (UTF-8) và `-I` (QUOTED_IDENTIFIER ON).
- PowerShell/terminal: Thiết lập `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` và xuất file với `-Encoding UTF8`.
- Web tier: Request/Response dùng `CharacterEncodingFilter` UTF-8; JSP khai báo pageEncoding="UTF-8" và `<meta charset="UTF-8">`.
- Cổng kiểm chứng (Verification Gate): Sau khi thêm/sửa dữ liệu vào DB, bắt buộc SELECT kiểm tra output. Nếu xuất hiện ký tự rác (`áº`, `Ä`, `Ã`, `Â`, `â€`, `á»`, `Æ`, `?`), cấm đóng task cho đến khi sửa dứt điểm nguồn sinh lỗi.

Danh sách public/admin 10 mục/trang, bắt đầu 1; không nhận pageSize. page thiếu, không nguyên, <1 hoặc tràn số → 1. Page vượt trang cuối → trang cuối; tập rỗng → page=1, totalPages=0, không link trước/sau. Luôn có khóa phụ id để thứ tự xác định. Count và dữ liệu phải dùng cùng điều kiện hiển thị.

## 5. HTTP và lỗi (SYS-04)

Route detail chuẩn dự thảo `/movies/detail?id={id}`. Mọi route tương đối với context path, không mặc định deploy tại `/`.

| Tình huống | Kết quả |
|---|---|
| GET đọc thành công | 200 |
| POST thành công/idempotent no-op | 303 tới GET nội bộ; flash một lần, không replay POST |
| Form sai | 400, giữ trường hợp lệ, lỗi từng field; không hiện lại password |
| CSRF thiếu/sai | 403, không mutation |
| Guest vào route bảo vệ | 303 login; chỉ giữ đích GET nội bộ an toàn |
| User ACTIVE gọi admin | 403, không dữ liệu admin |
| Sửa/bỏ review người khác | 403 sau kiểm tra tài nguyên và quyền |
| ID tài nguyên sai/không tồn tại; phim không public ở route public | 404 |
| Bản ghi đã đổi so với form, invariant thay đổi lúc ghi | 409, không ghi đè; cho tải lại |
| Method không hỗ trợ | 405, không mutation |
| DB/runtime lỗi | 500, thông báo chung/correlation ID, log an toàn |

Thứ tự: method → session/role → CSRF POST → parse/lookup → ownership/trạng thái → validation → transaction. Form auth công khai kiểm tra CSRF trước lookup email/context reset. UC-03 là ngoại lệ kiểm chứng sở hữu được chủ dự án yêu cầu: email ACTIVE khớp đủ mở reset, không xác minh chủ email; xem R-01. Ngoại lệ từ kế hoạch: GET detail có thể tăng view theo SYS-07; GET khác không mutation. Không có GET logout/approve/delete.

Ứng dụng bắt buộc có ba view lỗi riêng 403/404/500 bằng tiếng Việt dưới `/WEB-INF/views/error/`, được dùng qua error mapping/forward nội bộ; giữ đúng HTTP status, không redirect lỗi thành 200. Có thông điệp dễ hiểu và link Home/catalog an toàn; 500 có correlation ID, không stack trace, SQL, secret hoặc cấu hình. Không để trang lỗi mặc định Tomcat làm giao diện nghiệm thu. Có thể ánh xạ GET `/403`, `/404`, `/500` để xem cùng view với đúng status; không tạo lỗi DB thật để preview 500.

returnTo chỉ nhận GET trong context ứng dụng thuộc whitelist public/profile/favorites; loại scheme, host, //, backslash, control character, traversal và endpoint mutation. Sau login vẫn kiểm tra quyền. Không tự replay favorite/review/Q&A sau login. Redirect sau POST dùng ID chuẩn từ server.

## 6. Toàn vẹn và đồng thời (SYS-05)

Mọi ghi DB trong transaction, lỗi rollback toàn bộ. UNIQUE/FK là bảo vệ cuối, không chỉ check trước insert. Giao dịch đồng thời vẫn giữ email duy nhất, một favorite/review mỗi user/movie, không mất view, chỉ một reset commit cho cùng expectedCredentialsVersion, ít nhất một Admin ACTIVE.

Form sửa phim/thể loại/user/profile/review và duyệt mang version server cấp. Version thay đổi → 409, không ghi đè. No-op cùng trạng thái đích không được đụng bản nội dung mới; moderation cụ thể ở 007. Cơ chế khóa/version do plan chọn.

## 7. An toàn, UI và vận hành (SYS-06)

Theo AGENTS.md: Java 17/Ant/Tomcat 10.1, JPA EntityManager, parameter binding; BCrypt cost ≥12, không thay bằng SHA/PBKDF2/plaintext. Không persistence trong Servlet/JSP. View dưới `/WEB-INF/views/`, không scriptlet. Escape dynamic text đúng ngữ cảnh; validation URL không thay escaping. Không ghép dữ liệu không tin cậy vào script/HTML thô. Không tự viết BCrypt để né thiếu thư viện. R-01 không cần SMTP.

CSRF gắn phiên cho mọi POST kể cả register/login/forgot/reset; CSRF không phải xác minh quyền sở hữu email. Cookie HttpOnly, SameSite=Lax; Secure trên HTTPS, localhost HTTP chỉ trong dev. Session idle 30 phút (D-05). Logout invalidate phiên; trang cá nhân/admin/auth nhạy cảm không cache. Không log password/session ID/secret hoặc toàn bộ body form reset. Không đặt password/email đích vào query URL reset; reset page dùng Referrer-Policy no-referrer, không tải tài nguyên bên thứ ba.

UI tiếng Việt; form có label/lỗi cạnh field, focus keyboard rõ, ảnh alt/placeholder. Client có validation required/format/range/length tương ứng quy tắc server, kể cả giới hạn byte password khi cần JavaScript; bypass JavaScript vẫn bị server từ chối dữ liệu sai. Đọc được tại 375,768,1366 px, không tràn ngang trang; bảng admin cuộn trong vùng riêng. Không cần spinner giả khi render server; chờ submit có trạng thái đang gửi và phục hồi sau lỗi. Server vẫn bảo vệ gửi trùng. Empty/error không dùng dữ liệu giả.

Mục tiêu nguồn: với 50 phim/DB local, mỗi trang catalog/detail dưới 2 giây trong 20 lần mở sau warm-up; ghi máy/môi trường và kết quả. Tách thời gian ảnh/video ngoài khỏi xử lý dữ liệu nội bộ. Không tự nâng thành dashboard 500ms.

## 8. Lượt xem và điểm (SYS-07)

Mở detail public thành công tăng 1 view nếu session chưa xem phim hoặc đã qua ít nhất 30 phút từ lần tăng thành công gần nhất; không yêu cầu play. Refresh 29:59 không tăng, 30:00 tăng. Hai request cùng session/phim đồng thời chỉ tăng một; hai session khác nhau tính riêng. Đánh dấu timestamp session sau tăng DB thành công. Login tạo session mới: MVP chấp nhận lượt xem mới, không hứa chống bot/nhiều session.

Nếu ghi view thất bại: rollback tăng, giữ detail đọc được 200 nếu đã tải dữ liệu; log an toàn, không đặt timestamp để lần sau thử lại. Nếu đọc detail lỗi →500. Ghi view kiểm tra lại phim vẫn PUBLISHED.

Điểm phim = tổng rating review public / số review public. Không review → null, “Chưa đánh giá”, count=0; không giả 0 sao. Sort dùng độ chính xác đầy đủ; hiển thị 1 số lẻ HALF_UP. Không dùng điểm làm tròn làm nguồn. 005 và 008 dùng đúng tập review của từng chỉ số.
