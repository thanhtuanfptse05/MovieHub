# MovieHub: bản đồ đặc tả toàn hệ thống

Phiên bản bộ tài liệu 1.1.0 | Ngày 2026-10-25 | Draft; thay đổi UC-03/R-01 đã được chủ dự án chỉ định, các phần khác chưa được duyệt toàn bộ.

Bộ tài liệu này đặc tả MVP trong [kế hoạch gốc](../MovieHub_Project_Plan_Java_Ant.md). Đây là kết quả đọc và phân rã yêu cầu, chưa phải bằng chứng đã xây dựng hay kiểm thử ứng dụng. Các đề xuất trong nguồn tiếp tục là baseline đề xuất; viết thành spec không biến chúng thành quyết định đã được chủ dự án phê duyệt.

## Đọc theo thứ tự

1. [Quy tắc chung](shared/system-rules.md): thuật ngữ, quyền, trạng thái, lỗi và chất lượng.
2. [Hợp đồng dữ liệu](shared/data-contract.md): 8 bảng đang dùng, bảng token lịch sử không dùng theo R-01, validation/quan hệ/xóa mềm.
3. [Quyết định và xung đột](shared/decisions.md): nguồn yêu cầu, giả định, câu trả lời của chủ dự án, điều kiện phải chốt trước khi code.
4. Spec của module được giao ở bảng bên dưới.
5. [Ma trận truy vết](traceability.md) và [kịch bản nghiệm thu liên module](acceptance.md).
6. [Hướng dẫn giao việc cho agent](agent-handoff.md): chọn đúng feature, thứ tự tích hợp và điều kiện trước implementation.
7. [Báo cáo rà soát](../.sdd/reviews/specification-review-2026-10-25.md): skill đã dùng, vấn đề đã sửa và phạm vi kiểm chứng.
8. [design.md](../design.md) và [ui_rule.md](../ui_rule.md): visual baseline từ HTML người dùng và hai rule R-02/R-03 bắt buộc xuyên suốt. Không hardcode business data, không đưa Business Rules/developer copy lên sản phẩm.

## Chia module và trách nhiệm

| Module | Phạm vi chính | UC nguồn | FR nguồn | Phụ thuộc nghiệp vụ |
|---|---|---|---|---|
| [001-auth](001-auth/spec.md) | Đăng ký, login/logout, session, nhập email để đặt lại mật khẩu trực tiếp, guard quyền | 01,02,03 | 01,02,03,04,06 | Users; JPA/BCrypt, không SMTP |
| [002-user-profile](002-user-profile/spec.md) | Xem/sửa tên, avatar của chính mình | 04 | 05 | 001 |
| [003-movie-catalog](003-movie-catalog/spec.md) | Home, tìm/lọc/sort/page, detail, video, lượt xem, tương tự | 05,06,07,17 | 07,08,09,10,11,22; 25 tùy chọn | Movies/Categories; điểm từ 005 |
| [004-favorites](004-favorites/spec.md) | Thêm, bỏ, xem yêu thích cá nhân | 08 | 12 | 001,003 |
| [005-reviews-rating](005-reviews-rating/spec.md) | Viết/sửa/bỏ review; hiển thị và tính điểm | 09; review của 15 | 13 | 001,003; duyệt tại 007 |
| [006-qa](006-qa/spec.md) | Đọc, đặt câu hỏi, trả lời; hiển thị qua duyệt | 10,11; Q&A của 15 | 14,15,16 | 001,003; duyệt tại 007 |
| [007-admin-crud](007-admin-crud/spec.md) | Phim, thể loại, user/role, queue duyệt thống nhất | 12,13,14,15 | 17,18,19,20 | 001; dữ liệu 003/005/006 |
| [008-admin-analytics](008-admin-analytics/spec.md) | COUNT/SUM/AVG/MAX/MIN, top 5, hàng chờ duyệt | 16 | 21; 26 tùy chọn | 003/005/006/007 |

UC-14 chỉ thuộc 007. UC-15 có một giao diện duyệt do 007 sở hữu; 005/006 định nghĩa ảnh hưởng lên nội dung và điểm. Tất cả chức năng MVP là P0 theo kế hoạch; P1 chỉ gồm FR-25, FR-26.

## Phạm vi MVP

Website thông tin phim và cộng đồng, phát MP4 demo/trailer được phép sử dụng. Có USER, ADMIN; Guest là trạng thái chưa đăng nhập. Không có VIP, thanh toán, phim nhiều tập, upload/chuyển mã video, CDN, chat, AI recommendation hay doanh thu.

UC-03 theo yêu cầu trực tiếp R-01: nhập email ACTIVE đã đăng ký → form đặt password mới →login. Không gửi/xác thực email, OTP hoặc reset token; không tạo account mới. Người biết email có thể đổi password, luồng không xác minh chủ email. Các đoạn mail/token trong kế hoạch gốc đã được thay, xem decisions và auth v1.1.0.

Scaffold cũ tự thêm bio, đổi mật khẩu trong profile, đạo diễn/diễn viên, filter điểm, accepted answer, khóa login 5 lần và analytics theo ngày. Các mục này không có trong MVP nguồn; decisions.md ghi rõ cách xử lý.

## Trạng thái và bàn giao cho agent

- 8 spec là Draft, có EARS và Given/When/Then, chưa được người dùng duyệt toàn bộ.
- Giá trị do người soạn bổ sung mang mã D-* trong decisions.md. Agent được lập kế hoạch dự thảo theo chúng, không gọi chúng là quyết định đã duyệt.
- plan.md, tasks.md, checklists.md cũ có thông báo cần tạo lại. Không chạy task cũ để code.
- Sau khi duyệt spec và xử lý gate thư viện/constitution: chạy speckit-plan → speckit-tasks → speckit-analyze cho từng module; sau đó mới triển khai.
- Kiểm tra chất lượng tài liệu không chứng minh ứng dụng đã chạy. Checklist nghiệm thu ứng dụng để trống đến khi có bằng chứng.

## Skill và phạm vi áp dụng

Đã áp dụng using-superpowers, brainstorming, speckit-specify (soạn lại từng feature hiện có), speckit-clarify (rà mơ hồ và ghi câu trả lời), speckit-checklist (chất lượng yêu cầu), humanizer và verification-before-completion. Đã tham chiếu CodeGraph và graphify: graph hiện chủ yếu chứa tooling, không chứng minh đã có logic ứng dụng.

Không triển khai code/UI trong lần này. Khi làm UI dùng design-taste-frontend theo AGENTS.md; khi code dùng skill lập kế hoạch, TDD và kiểm chứng của dự án.
