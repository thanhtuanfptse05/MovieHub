# 005-reviews-rating: đánh giá và điểm phim

Ngày 2026-10-25 | Version 1.0.0 | Draft | P0
Nguồn UC-09 và phần review của UC-15; FR-13; BR-11,12,14,15,19.
Áp dụng [quy tắc chung](../shared/system-rules.md), [dữ liệu](../shared/data-contract.md), D-06/D-08/D-11.
007 sở hữu giao diện/thao tác duyệt, module này sở hữu nội dung và ảnh hưởng lên điểm.

## User Scenarios & Testing

### REV-US-01: viết đánh giá (P0)

Là thành viên, tôi muốn gửi 1–5 sao cùng bình luận để chia sẻ nhận xét.
Given chưa review phim public, When gửi rating=4 và nội dung hợp lệ, Then có một review PENDING, tác giả thấy trạng thái riêng, Guest không thấy và điểm public chưa đổi.
Kiểm thử độc lập với Users/Movies seed và công cụ duyệt fixture; không cần favorites/Q&A.

### REV-US-02: sửa và bỏ review (P0)

Given review đã APPROVED, When chủ sửa rating/content, Then chuyển PENDING, bỏ audit cũ và loại khỏi điểm public ngay.
Given review của U2, When U1 sửa/bỏ, Then 403 dù U1 đoán đúng ID.
Given đã bỏ review, When tác giả gửi lại, Then restore cùng hàng với nội dung mới/PENDING, không tạo review thứ hai.

### REV-US-03: xem điểm đáng tin cậy (P0)

Given hai review APPROVED điểm 5 và 4, một PENDING điểm 1, When Guest đọc, Then count=2, điểm=4.5.
Given review điểm 5 bị từ chối/bỏ, Then điểm=4.0,count=1; không review thì “Chưa đánh giá”.

### Edge Cases

Rating 0/6/1.5/chuỗi; content trắng/1001; create hai lần; stale version; người dùng khóa lúc gửi; phim bị ẩn; XSS lưu plain text; delete lặp; duyệt form cũ sau tác giả sửa; nội dung Admin vẫn PENDING.

## Requirements

### Luồng tạo/sửa/bỏ

Một user/movie tối đa một row Reviews kể cả sau bỏ mềm. Form hiển thị “Viết” nếu chưa có active review, “Sửa” nếu có. Client gửi mode=create hoặc update, không silent upsert.

Create: movie public + actor ACTIVE, rating nguyên 1–5, content trim/NFC 1–1000. Nếu không có row: tạo PENDING. Nếu row bỏ mềm: restore và thay nội dung/rating, đặt PENDING/audit null, updatedAt mới, giữ createdAt lịch sử. Nếu đã active: 409 với link review hiện hành; không coi request cũ là lệnh sửa.

Update: reviewId của actor thuộc movie public, version hiện hành, không deleted. Thay rating/content, status=PENDING, moderatedBy/At=null, updatedAt/version đổi. Submit hoàn toàn giống nội dung hiện hành là no-op, không rút APPROVED khỏi public. Resubmit một REJECTED bằng mode=update và nội dung hợp lệ được phép; kể cả text giống cũ vẫn đặt PENDING khi người dùng xác nhận gửi duyệt lại.

Delete: reviewId/version đúng, actor là chủ, movie public. Đặt deletedAt, tăng version, loại khỏi public/count/rating ngay; không xóa vật lý. Retry cùng phiên bản delete đã hoàn tất được no-op nếu row vẫn deleted và không có lần restore mới; nếu đã restore →409. Không cho Admin sửa/bỏ nội dung của người khác tại route này; dùng quyết định duyệt trong 007.

### Public và private

Public list chỉ APPROVED/chưa deleted/phim PUBLISHED, order createdAt DESC,id DESC, 10/trang; có tác giả hiện hành, thời gian, sao và text escaped. Tác giả xem active review của mình riêng bất kể status; nếu đã nằm public không nhân thành hai mục trong public list. Form sửa điền đúng dữ liệu hiện hành, không dùng email làm tên.

Review mới/sửa không tự được approve vì không có từ cấm. Admin viết review cũng PENDING; MVP cho Admin tự duyệt trong giao diện quản trị, ghi đúng moderator, không có yêu cầu tách hai người.

### Functional Requirements / Acceptance Criteria EARS

- REV-AC-01 (Ubiquitous): THE system SHALL chỉ nhận rating nguyên 1–5 và content 1–1000, bắt buộc cả hai.
- REV-AC-02 (Event-driven): WHEN tạo/restore hợp lệ THE system SHALL lưu một review PENDING và chỉ tác giả/Admin trong admin thấy nội dung chưa duyệt.
- REV-AC-03 (Unwanted): IF create khi đã có review active THEN THE system SHALL 409, không tạo duplicate hoặc ghi đè.
- REV-AC-04 (Event-driven): WHEN tác giả sửa nội dung/rating hoặc resubmit REJECTED THE system SHALL đặt PENDING, xóa audit cũ, bỏ đóng góp rating public.
- REV-AC-05 (Unwanted): IF user sửa/bỏ review người khác THEN THE system SHALL 403 và không mutation.
- REV-AC-06 (Event-driven): WHEN tác giả bỏ review THE system SHALL xóa mềm, bỏ khỏi public và điểm, giữ unique để restore.
- REV-AC-07 (Ubiquitous): THE system SHALL tính avg/count từ đúng tập review public, null khi count=0, hiển thị 1 số lẻ HALF_UP.
- REV-AC-08 (Event-driven): WHEN Admin APPROVE/REJECT theo 007 THE system SHALL làm public/count/rating phản ánh trạng thái mới từ request đọc tiếp theo.
- REV-AC-09 (Unwanted): IF version cũ hoặc review đã restore sau form delete cũ THEN THE system SHALL 409, không ghi đè.
- REV-AC-10 (State-driven): WHILE movie không public THE system SHALL từ chối route tương tác public 404 và không tính nó vào catalog public.
- REV-AC-11 (Ubiquitous): THE system SHALL escape nội dung như text; không tự gắn trạng thái PENDING_REVIEW hoặc tự approve.

### Hợp đồng giao tiếp

| Method/route | Input | Thành công |
|---|---|---|
| GET /movies/detail | id,reviewPage? | Detail + list public và own review riêng |
| POST /reviews/save | mode=create/update,movieId,rating,content,csrfToken; update thêm reviewId,version | 303 detail#reviews |
| POST /reviews/delete | reviewId,version,csrfToken | 303 detail#reviews |
| POST /admin/moderation/decide | Theo 007 | Theo 007 |

movieId update phải khớp review.movieId; không khớp →400, không chuyển review sang phim khác. Actor ID luôn từ session. Lỗi còn lại SYS-04. Không dùng /reviews/submit hoặc comment làm tên field thay content.

### Key Entities

Reviews; FK Users/Movies; unique(user_id,movie_id), version/deletedAt/audit theo data-contract. Aggregate là dữ liệu suy ra, không thêm Movies.averageRating hoặc favoriteCount ngoài spec. Cập nhật review/điểm suy ra trong cùng trạng thái commit; nếu dùng cache phải vô hiệu hóa trước lần đọc tiếp theo.

## Success Criteria

- REV-SC-01: Create đồng thời vẫn tối đa một row/cặp, request thứ hai không ghi đè nội dung.
- REV-SC-02: Fixture 5,4 APPROVED +1 PENDING cho 4.5/2; sửa/bỏ/từ chối cập nhật đúng.
- REV-SC-03: Mọi đường sửa/bỏ trái chủ hoặc stale form không mutation.
- REV-SC-04: Text chứa HTML/script hiện như chữ, không chạy khi xem public hay admin.
- REV-SC-05: Restore review vẫn một row/PENDING, không public trước duyệt.

## Assumptions / Out of Scope

Không review ẩn danh, không like/dislike, report abuse, profanity engine, nhiều review/user/movie, tự approve, hoặc lịch sử nội dung nhiều phiên bản. Audit giữ moderator/time của quyết định hiện hành; log an toàn ghi thao tác quan trọng, không hứa audit ledger bất biến.
