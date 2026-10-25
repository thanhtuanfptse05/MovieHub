# Quyết định, nguồn và điều kiện trước triển khai

Ngày 2026-10-25 | Draft; chưa duyệt toàn bộ baseline.

## Nguồn

- SRC: kế hoạch MovieHub_Project_Plan_Java_Ant.md bản 1.0, nhất là mục 5,7,9,10,14,21. Nguồn tự ghi nhiều quyết định là PROPOSED.
- GOV: AGENTS.md và constitution hiện hành; phần token reset được cập nhật theo yêu cầu trực tiếp R-01, các ràng buộc khác giữ nguyên.
- D-*: lựa chọn người soạn để loại bỏ mơ hồ, đề nghị chủ dự án duyệt cùng spec. Không gán thành lời người dùng.
- Chưa đọc PDF assignment nên không xác nhận rubric độc lập.

## Clarifications

### Session 2026-10-25

- Q: Nếu 4 JAR không đủ JPA/Hibernate và BCrypt thì xử lý thế nào? → A: Chủ dự án chọn “Cho phép đề xuất bổ sung JAR cần thiết”. Đây là quyền lập đề xuất; chưa phải duyệt danh sách/version cụ thể hoặc cho tải/cài JAR.
- Q: UC-03 có cần xác thực qua email không? → A: Chủ dự án yêu cầu chỉ nhập đúng email để được cấp lại quyền đặt mật khẩu, không xác thực qua email. R-01 thay luồng mail/token cũ: email ACTIVE khớp → form password mới ngay, không SMTP/OTP/link/token reset. Đây là xác nhận phạm vi UC-03, không phải duyệt toàn bộ spec.

## Lựa chọn dự thảo

| ID | Lựa chọn | Căn cứ/ảnh hưởng |
|---|---|---|
| D-01 | Detail `/movies/detail?id=...`; MP4 trực tiếp, trailer MP4 fallback | Theo mặc định mục 21; không embed tùy ý |
| D-02 | Đăng ký về login. Password ít nhất 8 code point và 8 byte, tối đa 72 byte UTF-8; không bắt buộc bốn loại ký tự | Flow nguồn; giới hạn byte tránh BCrypt cắt chuỗi. Xung đột business.md cũ cần GOV-02 |
| D-03 | pageSize=10; một category + một year; q tối đa 200; newest theo updated_at DESC | Chốt các nhánh tùy chọn trong nguồn |
| D-04 | Home: tối đa 1 featured, 10 mới cập nhật, 10 xem nhiều, 10 điểm cao; similar tối đa 6 | Có nhóm điểm cao ở mục 11; giới hạn Home do người soạn chọn |
| D-05 | Session idle 30 phút; quyền/trạng thái cập nhật từ request kế tiếp; reset thu hồi mọi phiên cũ | Nguồn chưa định lượng; cơ chế thu hồi phải có trong plan |
| D-06 | Favorite bỏ mềm/restore, review bỏ mềm/restore cùng hàng, category xóa mềm khi không liên kết; schema nguồn9 bảng, R-01 không dùng bảng token | Tuân thủ DATA-01 chặt hơn nguồn; cần duyệt phần khác biệt xóa mềm |
| D-07 | Không khóa user sau 5 lần sai; không profanity engine, accepted answer, bio, đổi mật khẩu profile, time-series | Đây là phần scaffold tự thêm, ngoài nguồn |
| D-08 | Admin gửi nội dung PENDING; được APPROVED↔REJECTED; ẩn question không đổi status answers | Làm rõ quyền duyệt/ẩn, tránh cascade mất dữ liệu |
| D-09 | Slug nhập tay lowercase ASCII; category name so NFC, trim, không phân biệt hoa thường, phân biệt dấu | Tránh tự đoán thuật toán slug/collation |
| D-10 | Description 1–10000; tên người 1–100; title 1–200; DRAFT được thiếu media/category, publish cần poster và category | Kế thừa sức chứa nguồn và chốt điều kiện publish |
| D-11 | Lỗi form 400, conflict 409, POST thành công 303; version cho form sửa | Hợp đồng rõ và chống ghi đè |
| D-12 | Analytics toàn thời gian, tổng phim/view mọi status, AVG mọi review APPROVED chưa bỏ | Theo mục 14; khác rating public khi có phim ẩn, cần nhãn rõ |
| D-13 | Không tự hạ role; luôn ít nhất một Admin ACTIVE; không xóa user | Củng cố BR-16 cả khi đồng thời |
| D-14 | Email ASCII theo data-contract; review/question/answer 10/trang; mở answers một question mỗi lần | Không hứa toàn bộ chuẩn email/tải vô hạn |
| D-15 | Đã được thay bằng R-01, không còn hiệu lực | Không triển khai logic reset token/SMTP của bản v1.0.0 |

## R-01: quyết định trực tiếp của chủ dự án về quên mật khẩu

Ngày 2026-10-25: email đã đăng ký thuộc tài khoản ACTIVE là đủ để mở form đặt password mới trong cùng session. Không cần quyền truy cập hộp thư, OTP, token xác thực hoặc mật khẩu hiện tại. Áp dụng cả USER và ADMIN ACTIVE; INACTIVE không được mở khóa qua reset. Không tạo account mới. Context session giữ target, credentialsVersion và flowVersion form giữa hai màn hình, không phải xác minh danh tính.

Hệ quả thực tế: người biết email có thể đổi password tài khoản đó; luồng không chứng minh chủ sở hữu email và cho biết email nào đủ điều kiện qua việc chuyển sang form reset. Không gọi đây là cơ chế xác minh khôi phục an toàn. Chi tiết/validation/concurrency tại 001-auth v1.1.0 là hợp đồng mới; các phần mail/token trong kế hoạch nguồn và báo cáo v1.0.0 chỉ còn giá trị lịch sử.

## Gate thư viện và môi trường

### R-02/R-03: giao diện dùng dữ liệu DB và không trình bày tài liệu nghiệp vụ

Ngày 2026-10-25, chủ dự án yêu cầu viết design.md/ui_rule.md từ HTML đính kèm và thiết lập hai rule áp dụng xuyên suốt: agent cấm hardcode business data trong UI, dữ liệu phải từ DB; giao diện không có Business Rules/BR/ghi chú nghiệp vụ cho developer. Quy định đã được ghi vào AGENTS.md, hai constitution v2.1.0 và shared system rules. Xem [design](../../design.md) và [ui_rule](../../ui_rule.md).

Nhãn nút/thương hiệu/design tokens/mapping enum không phải bản ghi nghiệp vụ; phản hồi tác vụ ngắn như “Chờ duyệt” được phép. Các ngoại lệ được giới hạn trong UI-DATA-03, không cho phép mock business rows ở backend hoặc static payload. Đây là chính sách đã được chủ dự án chỉ định, không phải phê duyệt tính năng ngoài MVP hay cài thư viện.

### GOV-01: allowlist và khả năng chạy

Kiểm tra local ngày 2026-10-25: allowedlib đúng bốn JAR AGENTS.md. Không tìm thấy entry `jakarta/persistence/EntityManager.class`, `org/hibernate/*`, `BCrypt.class` hay mail/SMTP provider. Đây là bằng chứng về allowedlib; chưa kiểm kê Tomcat ngoài repo, không giả định server có provider.

JSTL implementation hiện có khai báo `META-INF/c.tld` URI `http://java.sun.com/jsp/jstl/core`; AGENTS.md bắt buộc `jakarta.tags.core`. URI mới được mô tả trong [Jakarta Tags 3.0](https://jakarta.ee/specifications/tags/3.0/tagdocs/c/tld-summary). Chỉ thêm ORM chưa giải quyết toàn bộ tương thích.

Đề xuất: mở allowlist có kiểm soát, tiếp tục Ant/JAR local. Bảng là nhóm artifact cần đánh giá, chưa phải inventory đóng gói hoàn chỉnh hoặc version đã khóa.

| Nhu cầu | Đề xuất | Điều kiện |
|---|---|---|
| ORM | Hibernate ORM 6.6.x, Jakarta Persistence 3.1 API và đầy đủ runtime dependencies đúng POM bản chọn | [Trang chính thức](https://hibernate.org/orm/releases/6.6/) ghi Java 17/JPA 3.1; dòng 6.6 đang limited support lúc tra cứu. Không tự lấy latest |
| BCrypt | Implementation Java đã duyệt, hỗ trợ cost ≥12 và known-answer tests; jBCrypt là ứng viên để đánh giá | Chốt nguồn/license/version; không tự viết crypto |
| JSTL | Thay cặp JSTL 2.0 bằng API/implementation [Jakarta Tags 3.0](https://jakarta.ee/specifications/tags/3.0/) tương thích URI yêu cầu | Loại bản trùng; không đổi URI ngầm |
| JDBC/JAXB | Smoke test driver hiện có trên Java 17/SQL Server; đánh giá Jakarta XML Binding đúng namespace nếu ORM cần | Không coi jaxb-api-2.1 là Jakarta XML Binding runtime; không tự nâng driver |

Ở giai đoạn plan: liệt kê từng filename/version, artifact nguồn chính thức, SHA-256, license, compile/runtime và dependencies bắc cầu. Không khẳng định chỉ cần thêm 2–3 JAR. Phải compile sạch, mở EntityManager/transaction, verify BCrypt, render JSTL và kiểm tra WAR không đóng gói Servlet API trùng Tomcat. Theo R-01 không cần mail/SMTP dependency để làm UC-03. Chỉ tải/cài/sửa allowlist khi inventory cụ thể và ngoại lệ GOV được duyệt.

Nếu giữ đồng thời “chỉ bốn JAR”, “JPA/Hibernate”, “BCrypt”, “jakarta.tags.*” mà chưa chứng minh server cung cấp đủ thành phần thì chưa có phương án chạy được xác nhận. Không né bằng JDBC CRUD, đổi hash hoặc mail giả.

### GOV-02: xung đột tài liệu

business.md cũ dùng BR-03 khóa 5 lần, BR-10 UPCOMING/NOW_SHOWING/ENDED, BANNED, accepted answer; số BR khác nghĩa kế hoạch nguồn. DATA-01 constitution hạn chế hard-delete rộng hơn nguồn. Spec mới giữ BR-01…24 theo nguồn và ghi D-02/D-06/D-07; không sửa nội dung LOCKED hoặc coi nó đã hết hiệu lực.

Trước code, chủ dự án duyệt baseline và cập nhật có kiểm soát constraints/constitution liên quan. Không coi business.md cũ và spec mới là hai nguồn BR ngang nhau. Thông báo trong tài liệu cũ chỉ cảnh báo xung đột, không thay quyết định duyệt.

### ENV-01: media

Cần ít nhất một MP4 được phép sử dụng, placeholder local và test playback thật trước demo. UC-03 không cần SMTP, hộp thư test hoặc cấu hình gửi email theo R-01. Không thêm thư viện mail để triển khai luồng đã bỏ.

## Điều kiện chuyển Approved

Chủ dự án duyệt 8 module/D-*; chốt GOV-01/GOV-02; xác nhận hoặc phân công ENV-01. Sau đó tạo lại plan/tasks và analyze từng module. Câu trả lời “được đề xuất JAR” ở trên chưa phải duyệt toàn bộ baseline.
