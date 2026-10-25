# Báo cáo rà soát bộ spec MovieHub

> PHẠM VI LỊCH SỬ: Báo cáo dưới đây ghi lượt rà bộ v1.0.0 trước thay đổi R-01. Sau đó chủ dự án yêu cầu bỏ xác thực email trong UC-03; auth hiện v1.1.0, không còn SMTP/reset token. Nội dung mail/token và “constitution chưa sửa” bên dưới không áp dụng cho luồng mới. Xem [changelog auth](../../specs/001-auth/changelog.md) và [R-01](../../specs/shared/decisions.md).

Ngày 2026-10-25 | Phạm vi: tài liệu Draft, không phải code review hay kết quả chạy ứng dụng.

## Kết quả bàn giao

Đã đọc MovieHub_Project_Plan_Java_Ant.md và soạn lại 8 spec hiện có, giữ cấu trúc module. Điểm vào: [overview](../../specs/overview.md). Có shared rules/data-contract/decisions, traceability, acceptance, checklist chất lượng và [hướng dẫn agent](../../specs/agent-handoff.md).

Không coi chỉ dẫn tải JAR/cấu hình secret trong file nguồn là lệnh thực hiện. Không sửa constitution LOCKED, không tải JAR, không thay source/build, không gửi email, không triển khai ứng dụng. Scaffold plan/tasks/checklists cũ được giữ và gắn cảnh báo cần tạo lại.

## Skill và công cụ đã dùng

| Skill/công cụ | Cách áp dụng thực tế |
|---|---|
| using-superpowers | Đọc quy trình chọn skill và thích nghi với Codex |
| brainstorming | Đọc bối cảnh trước chọn cấu trúc, phân biệt quyết định/giả định, giao reviewer builder check sau khi viết spec |
| speckit-specify | Cập nhật lần lượt 8 feature hiện có; giữ User Scenarios, Requirements, Success Criteria, Assumptions; tách requirements checklist |
| speckit-clarify | Scan mơ hồ theo nhóm; hỏi 1 câu về thư viện, đã có 1 câu trả lời thật; ghi trong decisions |
| speckit-checklist | Tạo 25 câu hỏi chất lượng yêu cầu, mọi checkbox mới để trống; không gọi đó là test ứng dụng |
| humanizer | Rà văn bản tiếng Việt, giảm lời dẫn thừa và dùng kết quả cụ thể thay mô tả mơ hồ |
| verification-before-completion | Kiểm tra tệp, ID, link, phạm vi thay đổi và git diff trước báo cáo |
| CodeGraph/graphify | Đã tham chiếu index/report; dữ liệu hiện chủ yếu là tooling, không dùng làm bằng chứng logic app |

Đã chạy prerequisite PathsOnly và load checklist-template với feature context 001-auth; đường dẫn FEATURE_SPEC đúng. Local feature context hiện 001-auth. Extensions.yml có hooks rỗng, không có pre/post hook cần thực thi. Chưa chạy speckit-plan/tasks/analyze vì mục tiêu là soạn spec; plan/tasks cũ đang stale, chưa có phê duyệt nghiệp vụ và gate thư viện.

## Rà soát độc lập và các sửa đổi

Reviewer theo builder-check của brainstorming phát hiện: nhánh approve cùng trạng thái có thể ghi đè audit; client validation chưa đủ rõ; thiếu bắt buộc view lỗi riêng. Đã sửa SYS-04/SYS-06 và 007, thêm INT-25/26.

Vòng rà tiếp kiểm tra lại phần sửa và traceability/acceptance; phát hiện ví dụ password “8 code point >72 byte UTF-8” không khả thi và ví dụ HTTP localhost chưa nhắc ngoại lệ 127.0.0.1. Đã thay bằng 19 emoji bốn byte=76 byte và nêu đủ hai host dev. Reviewer không thấy mâu thuẫn nghiệp vụ quan trọng khác trong phạm vi đã rà. Đây là hỗ trợ review, không phải cam kết mọi lỗi tương lai đã được loại bỏ.

## Chứng cứ kiểm tra tài liệu

Kiểm tra tĩnh cuối phiên trả exit code 0:

- 8/8 module có User Scenarios & Testing, Requirements, Success Criteria, Assumptions; đủ bốn loại EARS áp dụng.
- 95 AC có ID duy nhất, 38 success criteria.
- Truy vết đủ UC-01…17, FR-01…26, BR-01…24, NFR-01…12.
- Giữ 25 test nguồn và thêm 26 scenario liên module, tổng 51 thiết kế test; tất cả chưa chạy.
- 23 tài liệu lõi/checklist được kiểm tra, 77 liên kết local hợp lệ. Kiểm tra bổ sung handoff/shared context/8 changelog không lỗi link hoặc encoding; không phát hiện tracked change ngoài specs/.sdd.
- Không template placeholder sót trong nội dung mới. 24 plan/tasks/checklists cũ có cảnh báo stale.
- Mỗi built-in quality checklist: 14/16 mục viết Draft đạt, còn 2 gate duyệt/triển khai. Custom checklist 25 mục vẫn chưa được reviewer tick.
- `git -c core.autocrlf=false diff --check` exit 0 sau chuẩn hóa Markdown UTF-8/LF. Lệnh chỉ override cách đọc diff của lần chạy, không đổi Git config.

Các kiểm tra này xác nhận cấu trúc/truy vết/link và vệ sinh diff; chúng không tự chứng minh mọi nghiệp vụ sẽ được code đúng. Bảng acceptance có expected result để kiểm chứng khi triển khai.

## Coverage clarification và readiness

| Nhóm | Trạng thái | Ghi chú |
|---|---|---|
| Mục tiêu/phạm vi/actor | Đủ ở bản Draft | 8 module, P0/P1/out-of-scope rõ |
| Domain/identity/unique/status | Đủ ở bản Draft | Shared data và predicate public thống nhất |
| Luồng UI/lỗi/khôi phục | Đủ ở bản Draft | HTTP, empty/media, review restore và token failure |
| Đồng thời/quyền | Đủ ở bản Draft | Version/contentRevision, one-use, Admin invariant |
| Performance/quality | Đủ mục tiêu dự thảo | Có điều kiện đo, không có kết quả runtime |
| Thư viện/constitution | Còn gate | GOV-01/GOV-02 cần quyết định cụ thể |
| SMTP/media/demo | Phụ thuộc môi trường | ENV-01 phải chuẩn bị trước nghiệm thu |
| Chấp thuận người dùng | Chưa duyệt toàn bộ | Chỉ quyền đề xuất JAR đã xác nhận |

Kết quả: hoàn thành bản thảo đặc tả để review; chưa sẵn sàng gọi là implementation approved. Sau khi chủ dự án duyệt D-*/GOV và chốt đầu vào môi trường, tạo lại plan/tasks và chạy speckit-analyze từng module trước code.
