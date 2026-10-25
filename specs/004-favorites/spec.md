# 004-favorites: phim yêu thích cá nhân

Ngày 2026-10-25 | Version 1.0.0 | Draft | P0
Nguồn UC-08, FR-12, BR-06,10. D-06 dùng bỏ mềm để tương thích constitution.
Áp dụng [quy tắc chung](../shared/system-rules.md), [dữ liệu](../shared/data-contract.md).

## User Scenarios & Testing

### FAV-US-01: thêm phim (P0)

Là User/Admin ACTIVE, tôi muốn lưu phim public để dễ quay lại.
Given chưa lưu M1, When thêm hai lần, Then chỉ có một favorite active, UI hiển thị “Đã yêu thích”.
Kiểm thử độc lập với user và movie seed, không cần review/Q&A.

### FAV-US-02: danh sách riêng và bỏ phim (P0)

Là thành viên, tôi muốn xem/bỏ yêu thích của mình mà không ảnh hưởng người khác.
Given U1/U2 cùng lưu M1, When U1 bỏ, Then favorite U2 không đổi; U1 không còn thấy M1.
Given U1 đã bỏ, When thêm lại M1 public, Then khôi phục cùng hàng, không duplicate.

### FAV-US-03: phim bị ẩn (P0)

Given phim trong favorites chuyển HIDDEN, When mở favorites, Then không thấy phim/metadata đó, count/page chỉ tính phim public.
Given phim được PUBLISHED lại, Then favorite còn active xuất hiện lại, không phải thêm mới.

### Edge Cases

Guest POST; spoof userId; phim ẩn/không tồn tại; thêm/restore đồng thời; bỏ hai lần; trang cuối sau khi bỏ; favorite đã active nhưng phim vừa ẩn; DB lỗi; CSRF sai.

## Requirements

### Luồng và danh sách

Actor từ session. Thêm chỉ khi movie PUBLISHED tại lúc ghi. Nếu chưa có hàng thì tạo; nếu đã active thì no-op; nếu deleted_at có giá trị thì restore về null và cập nhật createdAt thành lần thêm gần nhất. Không tăng view hoặc sửa Movies.updatedAt.

Bỏ nhận movieId, tìm cặp của actor, đặt deleted_at nếu đang active; chưa có/đã bỏ là no-op. Được bỏ favorite của phim vừa HIDDEN để người dùng kiểm soát liên kết đã lưu; không trả metadata phim đó. ID movie phải tồn tại, sai/không tồn tại 404. Không cho thao tác bằng favoriteId của người khác.

GET favorites chỉ cặp active của actor gắn phim PUBLISHED; order createdAt DESC,id DESC; 10/trang. Rỗng hiện “Bạn chưa có phim yêu thích” và link catalog. Card có poster/placeholder,title,year,điểm công khai,link detail và nút bỏ; không có dữ liệu private của tác giả khác.

Thành công add redirect detail canonical; remove redirect /favorites?page=... và chuẩn hóa trang nếu rỗng. Không dùng arbitrary redirect URL. Guest cần login rồi tự xác nhận thao tác lại, không replay POST.

### Functional Requirements / Acceptance Criteria EARS

- FAV-AC-01 (State-driven): WHILE chưa có phiên ACTIVE THE system SHALL yêu cầu login trước đọc/ghi favorites.
- FAV-AC-02 (Ubiquitous): THE system SHALL xác định userId từ phiên và giữ tối đa một hàng cho mỗi cặp user/movie.
- FAV-AC-03 (Event-driven): WHEN add movie public THE system SHALL tạo/restore/no-op đúng trạng thái, không duplicate kể cả hai request song song.
- FAV-AC-04 (Unwanted): IF add movie không public/không tồn tại THEN THE system SHALL 404, không tạo hay restore favorite.
- FAV-AC-05 (Event-driven): WHEN remove THE system SHALL chỉ bỏ mềm liên kết của actor; remove lặp là thành công no-op.
- FAV-AC-06 (Event-driven): WHEN đọc favorites THE system SHALL chỉ trả phim public của actor, count cùng tập và page/order theo trên.
- FAV-AC-07 (State-driven): WHILE phim HIDDEN THE system SHALL giữ liên kết nhưng không hiện public; publish lại khôi phục khả năng hiển thị.
- FAV-AC-08 (Unwanted): IF ghi thất bại THEN THE system SHALL rollback và không hiển thị flash “Đã lưu/đã bỏ” sai.
- FAV-AC-09 (Ubiquitous): THE system SHALL áp dụng CSRF và không cập nhật số favorite cache trong Movies vì nguồn không định nghĩa trường đó.

### Hợp đồng giao tiếp

| Method/route | Input | Thành công |
|---|---|---|
| GET /favorites | page? | 200 list/empty; Guest 303 login |
| POST /favorites/add | movieId bắt buộc,csrfToken | 303 /movies/detail?id=... |
| POST /favorites/remove | movieId bắt buộc,page?,csrfToken | 303 /favorites?page=... |

Lỗi chung SYS-04. Không nhận userId/favoriteCount từ client. Không có toggle GET; add/remove tách riêng để POST retry không đảo trạng thái ngẫu nhiên.

### Key Entities

Favorites với unique(user_id,movie_id) cả hàng deleted; FK Users/Movies. Chỉ Favorites đổi trong transaction. Cơ chế đồng thời không được nuốt mọi lỗi DB như thể duplicate; chỉ unique conflict đã xác nhận mới chuyển thành no-op.

## Success Criteria

- FAV-SC-01: Hai add đồng thời tạo tối đa 1 active link; bỏ lặp không lỗi.
- FAV-SC-02: Danh sách/count không chứa phim hidden hoặc favorite của user khác.
- FAV-SC-03: Restore dùng cùng row; add/remove không đổi viewCount hay review.
- FAV-SC-04: Bỏ item cuối trang cuối đưa về trang hợp lệ, không 500.

## Assumptions / Out of Scope

Favorites là bookmark, không phải trạng thái đã xem/đang xem, playlist chia sẻ hoặc giỏ hàng thanh toán. Không có favoriteCount denormalized. Bỏ mềm D-06 và thay đổi dữ liệu tương ứng còn chờ duyệt cùng GOV-02.
