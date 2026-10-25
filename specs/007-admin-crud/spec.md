# 007-admin-crud: quản trị nội dung và tài khoản

Ngày 2026-10-25 | Version 1.0.0 | Draft | P0
Nguồn UC-12,13,14,15; FR-17…20; BR-05,07,08,16,21,22,23.
Áp dụng [quy tắc chung](../shared/system-rules.md), [dữ liệu](../shared/data-contract.md), D-06/D-08/D-09/D-10/D-11/D-13.
Đây là module duy nhất sở hữu thao tác duyệt review/question/answer.

## User Scenarios & Testing

### ADM-US-01: quản lý catalog (P0)

Là Admin, tôi muốn tạo/sửa/xuất bản/ẩn phim và gán thể loại để không phải sửa SQL trực tiếp.
Given phim DRAFT hợp lệ có poster và category, When xuất bản, Then public thấy phim từ request tiếp theo.
Given phim có tương tác, When ẩn, Then giữ liên kết và toàn bộ nội dung, public detail 404.
Giá trị độc lập: dùng Users/Categories seed và form phim, chưa cần tương tác đầy đủ.

### ADM-US-02: quản lý thể loại (P0)

Given category chưa liên kết, When xóa, Then bỏ mềm và không còn trong dropdown public/admin gán mới.
Given category gắn bất kỳ phim nào kể cả HIDDEN, When xóa, Then 409, không tự tháo liên kết.
Tên/slug trùng canonical bị từ chối ngay cả khi category cũ đã xóa mềm.

### ADM-US-03: kiểm soát quyền tài khoản (P0)

Là Admin, tôi muốn tìm user và đổi ACTIVE/INACTIVE, USER/ADMIN để quản lý quyền.
Given U1 đang có session, When Admin khóa U1, Then request bảo vệ tiếp theo của U1 mất quyền.
Given hai Admin ACTIVE cùng hạ quyền người kia, Then không được kết thúc ở trạng thái không còn Admin ACTIVE.

### ADM-US-04: duyệt nội dung (P0)

Given review/question/answer PENDING, When Admin duyệt đúng bản hiện hành, Then đổi status/audit, public phản ánh theo SYS-02.
Given tác giả vừa sửa review, When Admin submit form duyệt cũ, Then 409, không approve nội dung mới chưa đọc.
Given hai Admin cùng approve một phiên bản nội dung, Then một quyết định ghi audit, request còn lại no-op; không đổi người/giờ duyệt sang người đến sau.

### Edge Cases

Guest/non-admin direct POST; mass assignment viewCount/id/moderator; slug unique race; category deleted giữa form/commit; stale phim/profile/user; xóa category có phim ẩn; tự khóa/tự hạ role; admin cuối INACTIVE; chéo hai admin; duyệt answer cha ẩn; review đã bỏ; hai mục cùng id nhưng khác type; DB lỗi giữa lưu phim và quan hệ.

## Requirements

### 1. Guard, danh sách và form

Toàn bộ /admin/* cần Admin ACTIVE, kiểm tra lại khi ghi. /admin redirect /admin/dashboard. Guest 303 login, User ACTIVE 403. Không kết hợp một response vừa redirect vừa status403.

List 10/trang. Movie list: q theo title/slug substring case-insensitive, status optional trong enum, order updatedAt DESC,id DESC. User list: q theo email substring canonical, role/status optional; order createdAt DESC,id DESC. Category list: q theo name/slug, chưa deleted, name ASC,id ASC. q tối đa 200; filter enum không hợp lệ →400, page theo SYS-03. Giữ filter trên page/link quay lại. Không hiện password_hash/token.

Movie form fields: title,slug,description,releaseYear,durationMinutes,posterUrl?,videoUrl?,trailerUrl?,status,featured,categoryIds[]. version khi edit. Validate theo data-contract; categoryIds duplicate được deduplicate, ID sai/đã deleted →400. Không nhận id mới,viewCount,createdAt,updatedAt từ client. Lưu movie và thay toàn bộ tập category trong cùng transaction; lỗi bất kỳ rollback cả hai.

Create mặc định DRAFT/featured=false/viewCount=0. Form create có submissionId gắn session để retry đã commit không tạo phim thứ hai, theo nguyên tắc nonce 006; unique slug vẫn bắt buộc. Xuất bản validate đủ; không cho “status=DELETED”. Edit status thay đổi public theo SYS-02; nút Ẩn có xác nhận, POST đặt HIDDEN, không xóa vật lý kể cả chưa tương tác. HIDDEN→PUBLISHED phải xác nhận và validate lại; viewCount không reset.

Category fields name,slug,version khi sửa. Unique canonical cả tên/slug kể cả hàng deleted. Xóa mềm chỉ khi không có MovieCategories. Cần kiểm tra và bảo vệ race với thao tác gán category, không chỉ count trước. Không có restore category trong MVP; nếu muốn tái sử dụng tên/slug cũ phải thay spec, không xóa vật lý để né unique.

### 2. User và invariant Admin

User edit chỉ role và status; không tạo/xóa user hoặc sửa email/password từ admin. Có version, xác nhận trước khóa/hạ role. Không tự INACTIVE hoặc tự hạ role khỏi ADMIN, kể cả còn Admin khác.

Luôn COUNT(user.role=ADMIN AND user.status=ACTIVE) ≥1 sau commit. Bảo vệ invariant trong transaction đủ mạnh để hai admin sửa hai hàng khác nhau cũng không write-skew. Account INACTIVE có role ADMIN không được tính vào số admin còn lại. Promoting USER không cần password reset, hiệu lực request kế tiếp theo SYS-01. Thay role/status không sửa nội dung review/Q&A/favorite cũ.

### 3. Queue và quyết định duyệt thống nhất

GET queue filter type=all/review/question/answer, status=PENDING/APPROVED/REJECTED, page; mặc định all/PENDING. Sort createdAt ASC,type theo review→question→answer,id ASC. Review deleted không vào queue. Queue bao gồm nội dung thuộc phim ẩn và answer cha chưa approved, có nhãn nguyên nhân và vô hiệu nút approve; reject vẫn được phép. Đếm pending trong dashboard khớp tập queue này.

Mỗi item có type,id,author display,context movie/question,status,content,rating nếu review,createdAt,version và contentRevision. Không cho moderator sửa text/rating. Action chỉ APPROVE/REJECT, target tương ứng APPROVED/REJECTED. Không có endpoint riêng lặp nghiệp vụ cho từng loại.

APPROVE review/question cần movie PUBLISHED; APPROVE answer cần question APPROVED và movie PUBLISHED. REJECT được phép khi cha ẩn để làm sạch queue. Review deleted →409. Admin tự gửi nội dung không được bỏ qua PENDING; MVP cho phép tự duyệt có audit.

Chuyển PENDING→APPROVED/REJECTED, APPROVED→REJECTED và REJECTED→APPROVED đều được phép khi parent thỏa điều kiện tương ứng. Question bị reject không đổi status answer; public kiểm tra cha. Re-approve question làm answer APPROVED cũ hiện lại.

Chống stale: yêu cầu version và contentRevision từ form. Sau guard/quyền và kiểm tra deleted/parent, xét no-op trước: nếu contentRevision vẫn đúng và status hiện tại bằng đích →no-op, không đổi audit/version, kể cả form mang version hiện hành. Nếu chưa cùng trạng thái đích, chỉ version và contentRevision đều đúng, đủ điều kiện parent mới được update, tăng version, ghi moderatedBy/At. Những trường hợp khác →409, tải lại. Review sửa/restore tăng contentRevision, vì vậy form duyệt nội dung cũ không được xem là no-op an toàn. Question/answer không edit trong MVP nên contentRevision cố định 1. Author edit review đặt PENDING và xóa audit; moderation không đổi contentRevision.

Ghi log an toàn actor ID,action,type/id,status cũ/mới,timestamp cho thay đổi thật; không log mật khẩu/token/secret hoặc full request body. Audit trên hàng là quyết định hiện hành, không hứa ledger bất biến.

### Functional Requirements / Acceptance Criteria EARS

- ADM-AC-01 (State-driven): WHILE actor không Admin ACTIVE THE system SHALL chặn mọi admin read/write theo guard chung.
- ADM-AC-02 (Event-driven): WHEN tạo/sửa phim hợp lệ THE system SHALL lưu phim và category links nguyên tử, giữ field server quản lý.
- ADM-AC-03 (Unwanted): IF slug trùng, category không hợp lệ hoặc validation lỗi THEN THE system SHALL 400 field error, không lưu một phần.
- ADM-AC-04 (Event-driven): WHEN xuất bản phim THE system SHALL kiểm tra điều kiện publish; WHEN ẩn THE system SHALL đặt HIDDEN, bảo toàn dữ liệu tương tác.
- ADM-AC-05 (Event-driven): WHEN tạo/sửa category THE system SHALL giữ unique name/slug canonical trong cả giao dịch đồng thời.
- ADM-AC-06 (Unwanted): IF category còn liên kết hoặc vừa được gán đồng thời THEN THE system SHALL chặn xóa mềm 409.
- ADM-AC-07 (Event-driven): WHEN đổi role/status user THE system SHALL áp dụng ở request kế tiếp, không sửa credentials hay nội dung họ.
- ADM-AC-08 (Unwanted): IF tự khóa/tự hạ role hoặc làm mất Admin ACTIVE cuối THEN THE system SHALL 409, invariant còn đúng kể cả giao dịch song song.
- ADM-AC-09 (Event-driven): WHEN mở queue THE system SHALL hiển thị đúng type/status/order/page và trạng thái parent, không gồm review đã bỏ.
- ADM-AC-10 (Event-driven): WHEN quyết định duyệt hợp lệ THE system SHALL cập nhật status,moderator,time,version và hiệu lực public đúng SYS-02.
- ADM-AC-11 (Unwanted): IF APPROVE khi parent không public hoặc review deleted THEN THE system SHALL 409, không thay status.
- ADM-AC-12 (Event-driven): WHEN retry cùng target trên cùng contentRevision đã được quyết định THE system SHALL no-op và giữ audit người đầu.
- ADM-AC-13 (Unwanted): IF version/contentRevision stale không đủ no-op THEN THE system SHALL 409, không approve nội dung chưa đọc.
- ADM-AC-14 (Event-driven): WHEN reject question APPROVED THE system SHALL ẩn thread public nhưng giữ nguyên status và FK answers.
- ADM-AC-15 (Ubiquitous): THE system SHALL xác nhận thao tác ẩn/khóa/hạ role tại UI, vẫn kiểm tra CSRF/role/version trên server.

### Hợp đồng giao tiếp

| Method/route | Input |
|---|---|
| GET /admin | Redirect dashboard |
| GET /admin/movies | q?,status?,page? |
| GET/POST /admin/movies/create | POST movie fields,submissionId,csrfToken |
| GET /admin/movies/edit | id |
| POST /admin/movies/edit | id,version,movie fields,csrfToken |
| POST /admin/movies/hide | id,version,csrfToken |
| GET /admin/categories | q?,page? |
| GET /admin/categories/edit | id |
| POST /admin/categories/save | id? (thiếu=create),name,slug,version nếu edit,csrfToken |
| POST /admin/categories/delete | id,version,csrfToken |
| GET /admin/users | q?,role?,status?,page? |
| GET /admin/users/edit | id |
| POST /admin/users/update | id,role,status,version,csrfToken |
| GET /admin/moderation | type?,status?,page? |
| POST /admin/moderation/decide | type=review/question/answer,id,action=APPROVE/REJECT,version,contentRevision,csrfToken |

GET thành công 200; POST 303 tới list/filter chuẩn hoặc edit GET liên quan, flash một lần. Lỗi SYS-04; enum/form sai 400, target không có 404, stale/invariant 409. Category create form nằm ở list; không cần route create riêng. Không có GET mutation, /admin/reviews/moderate hoặc /admin/movies/delete thực hiện hard-delete.

### Key Entities

Movies,Categories,MovieCategories,Users,Reviews,Questions,Answers theo data-contract. version trên đối tượng chỉnh sửa; Reviews thêm contentRevision. Không đưa mật khẩu vào form user. Mutating operations có transaction rollback và guard điều kiện tại commit.

## Success Criteria

- ADM-SC-01: Tạo/sửa/ẩn phim phản ánh đúng public; movie/category update lỗi không để links một phần.
- ADM-SC-02: Category đang dùng không bị xóa kể cả khi phim HIDDEN và khi có gán đồng thời.
- ADM-SC-03: Hai giao dịch hạ/khóa admin chéo không làm số Admin ACTIVE về 0.
- ADM-SC-04: Quyết định duyệt làm public/count/điểm thay đúng; form stale không approve bản sửa.
- ADM-SC-05: Mọi admin endpoint từ chối User/Guest kể cả request POST giả mạo.

## Assumptions / Out of Scope

Không bulk import, upload poster/video, ban tự động, hard-delete, khôi phục category, admin sửa password/email hay lịch sử chỉnh sửa đầy đủ. D-06/D-08/D-13 và xung đột constitution phải được duyệt trước code.
