# 006-qa: hỏi đáp theo phim

Ngày 2026-10-25 | Version 1.0.0 | Draft | P0
Nguồn UC-10,11 và phần Q&A của 15; FR-14,15,16; BR-12,13,14,23.
Áp dụng [quy tắc chung](../shared/system-rules.md), [dữ liệu](../shared/data-contract.md), D-08/D-14.
007 sở hữu giao diện duyệt; 006 sở hữu tạo/đọc và điều kiện hiển thị cha/con.

## User Scenarios & Testing

### QA-US-01: đặt câu hỏi (P0)

Là thành viên, tôi muốn hỏi về phim và theo dõi trạng thái gửi.
Given phim public và actor ACTIVE, When gửi 10–500 ký tự, Then lưu question PENDING, tác giả thấy “Chờ duyệt” riêng, Guest không thấy.
Giá trị độc lập: hỏi được trên seed Movies, không cần review/favorites.

### QA-US-02: trả lời (P0)

Là thành viên, tôi muốn trả lời câu hỏi đã duyệt để giúp người xem khác.
Given question APPROVED thuộc phim PUBLISHED, When gửi answer 1–1000 ký tự, Then lưu PENDING gắn đúng question/actor.
Given question PENDING/REJECTED hoặc phim HIDDEN, Then POST answer 404, không tạo.

### QA-US-03: đọc thảo luận đã duyệt (P0)

Given question/answer đều APPROVED, When Guest mở question, Then thấy answer.
Given Admin chuyển question sang REJECTED, Then câu hỏi và mọi answer biến mất public dù answer vẫn APPROVED.
Given Admin APPROVE lại question và phim public, Then các answer APPROVED cũ hiện lại, PENDING vẫn ẩn.

### Edge Cases

Question 9/10/500/501; answer 0/1/1000/1001; text trắng; spoof movieId/questionId/userId; parent đổi trạng thái trong lúc submit; admin gửi vẫn chờ duyệt; refresh POST; hai click cùng form; cùng text từ hai form khác nhau; DB rollback; private queue lộ nội dung người khác.

## Requirements

### Tạo và chống gửi lặp

Question nhận movieId/content. Answer nhận questionId/content; movieId nếu gửi phải khớp question.movieId. Actor ACTIVE từ session; liên kết không sửa sau tạo. Validate độ dài theo data-contract. Trước commit kiểm tra lại phim PUBLISHED và question APPROVED khi tạo answer.

Mỗi form create có submissionId do server cấp, gắn actor/session, loại question/answer và target ID. Cùng submissionId đã commit: redirect lại kết quả ban đầu, không insert lần nữa. Hai request đồng thời dùng cùng nonce tối đa một insert. Chỉ đánh dấu nonce thành công sau commit; validation/DB rollback cho phép thử lại. Hai form khác nonce được phép gửi cùng nội dung, vì không có unique text. Đây là chống double-click/retry trong phiên, không hứa chống spam hay exactly-once qua restart server. Nonce hết hạn theo session; form cũ yêu cầu tải lại (409), không tự tạo lại nonce phía client.

### Đọc public và nội dung của tôi

Trong detail: question public theo SYS-02, order createdAt DESC,id DESC, 10/trang, có tác giả/thời gian/content và count answer public. Chọn questionId để mở answers của một question public thuộc phim hiện tại; answers order createdAt ASC,id ASC, 10/trang. Không chèn tất cả answers không giới hạn vào mỗi card.

“Nội dung tôi gửi”: question và answer do actor tạo trong phim đang public, kể cả PENDING/REJECTED; order createdAt DESC, loại question trước answer khi timestamp bằng nhau, id DESC; 10/trang bằng myQaPage. Không trả text câu hỏi cha chưa public do người khác viết trong khu vực này; chỉ hiện trạng thái liên kết hiện không công khai. Public counters không cộng nội dung private.

Nếu question bị REJECTED sau khi answer được gửi, answer giữ nguyên status/FK, hiển thị public bị chặn bởi cha; tác giả answer có thể thấy status answer và nhãn “Câu hỏi hiện không công khai” trong vùng riêng. Không có quyền tự xem câu hỏi chưa duyệt của người khác bằng ID.

### Duyệt và quản lý

Mới luôn PENDING kể cả Admin. APPROVE/REJECT ghi moderator/time theo 007. Admin có thể từ chối question APPROVED để ẩn toàn thread; không cascade đổi trạng thái answer. Duyệt answer chỉ được APPROVE nếu question APPROVED và phim PUBLISHED; REJECT được phép cả khi cha ẩn. Không có accepted/best answer, sửa/xóa Q&A của chủ, voting hoặc notify trong MVP. Nội dung bị từ chối chỉ Admin đổi quyết định lại; tác giả có thể gửi câu hỏi mới.

### Functional Requirements / Acceptance Criteria EARS

- QA-AC-01 (State-driven): WHILE actor không ACTIVE THE system SHALL yêu cầu login trước create, không lưu nội dung.
- QA-AC-02 (Event-driven): WHEN tạo question hợp lệ cho phim public THE system SHALL lưu PENDING đúng author/movie/time.
- QA-AC-03 (Event-driven): WHEN tạo answer hợp lệ THE system SHALL lưu PENDING đúng question/author, chỉ nếu cha APPROVED và phim PUBLISHED tại commit.
- QA-AC-04 (Unwanted): IF question/answer ngoài biên hoặc trắng THEN THE system SHALL 400 field error và không tạo row.
- QA-AC-05 (Ubiquitous): THE system SHALL chỉ public question APPROVED trong phim public, và answer APPROVED có cha public.
- QA-AC-06 (Event-driven): WHEN cha mất điều kiện public THE system SHALL ẩn answer theo liên kết mà không đổi status/FK con.
- QA-AC-07 (Event-driven): WHEN cha public trở lại THE system SHALL chỉ hiện lại những answer APPROVED.
- QA-AC-08 (Ubiquitous): THE system SHALL phân trang/order/count theo trên và dùng cùng điều kiện public.
- QA-AC-09 (Unwanted): IF spoof author/target hoặc question không public THEN THE system SHALL không tạo sai liên kết, không lộ nội dung.
- QA-AC-10 (Event-driven): WHEN retry cùng submissionId đã commit THE system SHALL không tạo thêm question/answer.
- QA-AC-11 (Ubiquitous): THE system SHALL chỉ trả private submissions của actor, escape text, không dùng trạng thái ACCEPTED.
- QA-AC-12 (Unwanted): IF transaction lỗi THEN THE system SHALL rollback và không consume submissionId thành công.

### Hợp đồng giao tiếp

| Method/route | Input | Thành công |
|---|---|---|
| GET /movies/detail | id,questionPage?,questionId?,answerPage?,myQaPage? | 200 public Q&A và private của actor |
| POST /questions/create | movieId,content,submissionId,csrfToken | 303 detail#qa, flash “Đã gửi câu hỏi, đang chờ duyệt” |
| POST /answers/create | questionId,content,submissionId,csrfToken | 303 detail?questionId=...#qa, flash chờ duyệt |
| POST /admin/moderation/decide | Theo 007 | Theo 007 |

Nếu parent mất public sau commit nhưng trước redirect, redirect detail vẫn được đánh giá lại và có thể 404; bản ghi đã commit vẫn PENDING. Không đính questionId không public vào redirect retry. Lỗi theo SYS-04. Không có route /qa/answers/accept, /qa/delete hay GET mutation.

### Key Entities

Questions,Answers; FK không cascade xóa. moderatedBy/At null khi PENDING; version cho duyệt. Không cần gắn status phim vào answer; kiểm tra điều kiện qua cha ở từng query. Submission nonce là trạng thái phiên tạm thời, không bảng thứ 10.

## Success Criteria

- QA-SC-01: Boundary content đúng; một question và answer mới đều không public trước duyệt.
- QA-SC-02: Cha REJECTED ẩn toàn answer; phục hồi cha không tự approve answer PENDING.
- QA-SC-03: Hai POST cùng nonce tạo tối đa một row; lỗi DB không mất khả năng retry.
- QA-SC-04: Không actor nào đọc private text của người khác qua URL/filter/list/count.
- QA-SC-05: Public list và answerCount khớp đúng predicates SYS-02.

## Assumptions / Out of Scope

Câu hỏi gắn từng phim, không forum toàn site, realtime, best answer, edit/delete tác giả hay email notification. Moderation chỉ giữ quyết định hiện hành, không hứa lịch sử bản sửa.
