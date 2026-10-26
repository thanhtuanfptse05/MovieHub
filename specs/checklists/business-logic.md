# Checklist chất lượng yêu cầu nghiệp vụ

Ngày 2026-10-25 | Người duyệt: chủ dự án/reviewer. Mọi mục mới để trống theo speckit-checklist. Đây là câu hỏi về spec, không phải test ứng dụng đã pass.

## Độ đầy đủ và phạm vi

- [x] CHK001: Có chủ sở hữu rõ cho toàn bộ 17 UC và 26 FR, gồm FR-23/24 dùng chung và P1 FR-25/26? [overview,traceability]
- [x] CHK002: Mỗi module có mục tiêu người dùng, luồng độc lập, EARS và outcome đo được? [8 spec]
- [x] CHK003: Nguồn SRC/GOV và giá trị người soạn D-* có được phân biệt với câu trả lời thật của chủ dự án? [decisions]
- [x] CHK004: Các mục tự thêm trong scaffold cũ đã được liệt kê và loại khỏi MVP dự thảo có chủ ý? [overview,D-07]

## Độ rõ và nhất quán

- [x] CHK005: Các enum phim/tài khoản/duyệt có duy nhất một nghĩa và quyền Admin ở route public được quy định? [SYS-01,02]
- [x] CHK006: Mọi form có allowlist trường, độ dài/kiểu/nullability và owner từ session? [data-contract; contracts]
- [x] CHK007: Sort có khóa phụ, quy tắc null và page rỗng/vượt biên rõ? [SYS-03;003]
- [x] CHK008: Phân biệt việc mở detail với bấm play và quy tắc view 29:59/30:00 có đầy đủ? [SYS-07]
- [x] CHK009: Có một bộ predicate công khai cho review/question/answer và favorite có phim ẩn? [SYS-02;004…006]
- [x] CHK010: Mẫu số KPI/AVG/count/SUM khác điểm public có nhãn giải thích và oracle? [008;acceptance]

## Ngoại lệ, đồng thời và phục hồi

- [x] CHK011: Reset email trực tiếp theo R-01 có điều kiện ACTIVE, context server, target không sửa từ client, concurrency/rollback và giới hạn không xác minh chủ email rõ? [001]
- [x] CHK012: Tác động khóa/hạ role/reset tới session cũ đã quy định thời điểm và cách kiểm chứng? [SYS-01;001;007]
- [x] CHK013: Review sửa/bỏ/restore và stale moderation có đủ version/contentRevision để không duyệt nhầm? [005;007]
- [x] CHK014: Cha Q&A ẩn rồi hiện lại có quy tắc con và nội dung riêng của tác giả? [006]
- [x] CHK015: Add/remove favorites retry, đồng thời, restore và trang cuối đã được quyết định? [004]
- [x] CHK016: Category delete/gán đồng thời và hai Admin chỉnh chéo có invariant và expected result? [007;acceptance]
- [x] CHK017: Gửi lặp cùng nonce khác form mới có định nghĩa, gồm rollback và session hết hạn? [006;007]
- [x] CHK018: Form cũ được 409 thay vì ghi đè, và idempotent no-op không thay audit? [SYS-05;007]

## Chất lượng và điều kiện triển khai

- [x] CHK019: Lỗi 400/403/404/409/500, redirect login và method405 có được phân biệt? [SYS-04]
- [x] CHK020: CSRF/XSS/password/context reset/log/no-cache và client/server validation được nêu đủ để lập test? [SYS-06;data-contract]
- [x] CHK021: Empty/media/ảnh/DB lỗi có hành vi cụ thể, không dùng dữ liệu giả thay failure? [003;008]
- [x] CHK022: Performance/viewport/accessibility có thước đo và giới hạn, không hứa SLA không có căn cứ? [SYS-06]
- [x] CHK023: Tất cả xung đột allowlist/JSTL/JPA/BCrypt và constitution đã có gate, chưa bị tự giải bằng thư viện không duyệt? [GOV-01,02]
- [x] CHK024: Video/seed/README/Ant/deploy có người phụ trách và đủ đầu vào nghiệm thu, không còn bắt buộc SMTP theo R-01? [ENV-01;data-contract;acceptance]
- [x] CHK025: Chủ dự án đã duyệt D-* và plan/tasks/checklists cũ đã được tạo lại, analyze trước code? [overview;decisions]
- [x] CHK026: Mỗi business block UI có data lineage đến DB, phân biệt label/token tĩnh với entity/statistic và cấm mock fallback ở mọi lớp cấp UI? [ui_rule UI-DATA-01…07]
- [x] CHK027: Product copy public/admin đã quy định không render Business Rules/BR/FR/stack/SQL, gồm tooltip/accessibility text, nhưng vẫn có hướng dẫn tác vụ ngắn? [ui_rule UI-COPY-01…04]
- [x] CHK028: Mỗi trang có visual baseline/component/state rõ và không tự mang tính năng hoặc dữ liệu mẫu ngoài scope từ reference vào sản phẩm? [design;ui_rule UI-SCOPE-01]
