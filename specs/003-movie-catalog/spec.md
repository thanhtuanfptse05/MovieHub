# 003-movie-catalog: khám phá phim và video demo

Ngày 2026-10-25 | Version 1.0.0 | Draft | MVP P0; breadcrumb/navbar search P1
Nguồn UC-05,06,07,17; FR-07…11,22,25; BR-06,09,18,19,20.
Áp dụng [quy tắc chung](../shared/system-rules.md), [dữ liệu](../shared/data-contract.md), D-01/D-03/D-04.

## User Scenarios & Testing

### CAT-US-01: khám phá Home (P0)

Là người xem, tôi muốn thấy phim nổi bật, mới cập nhật, xem nhiều và điểm cao để chọn nhanh.
Given có phim PUBLISHED/DRAFT/HIDDEN, When mở Home, Then mọi nhóm chỉ có PUBLISHED và đúng thứ tự quy định.
Kiểm thử độc lập: seed Movies/Categories/Reviews đã duyệt; không cần đăng nhập.

### CAT-US-02: tìm và thu hẹp danh sách (P0)

Là người xem, tôi muốn tìm tên và kết hợp thể loại/năm/sắp xếp để tìm phim.
Given có 23 phim thỏa điều kiện, When mở page=2, Then thấy 10 phim, total=23,totalPages=3; link giữ đúng q/category/year/sort.
Given phim có nhiều category, Then mỗi phim chỉ xuất hiện một lần và count không bị nhân.

### CAT-US-03: xem chi tiết và video (P0)

Là người xem, tôi muốn đọc metadata, xem demo và phim tương tự.
Given phim public có video hợp lệ, When mở detail và bấm phát, Then player cho phép phát bằng browser.
Given video lỗi nhưng trailer MP4 hợp lệ, Then có nút chuyển trailer; nếu cả hai thiếu/lỗi thì thông báo, phần chi tiết vẫn dùng được.
Given cùng session mở lại trong 30 phút, Then không cộng view thêm.

### Edge Cases

Tập phim rỗng; q trống/1 ký tự/200/201; ký tự %/_/' được coi literal; sort lạ; năm/category sai/không tồn tại; page tràn số; không review; nhiều rating bằng nhau; poster lỗi; media không phải MP4; detail ID âm/sai/ẩn; chuyển HIDDEN giữa lúc mở; hai tab tăng view cùng lúc.

## Requirements

### Home

Bốn nhóm riêng:
1. Featured: tối đa 1 phim featured=true, order updatedAt DESC,id DESC. Nếu không có thì ẩn hero; không lấy DRAFT hoặc tự bật featured.
2. Mới cập nhật: tối đa 10, updatedAt DESC,id DESC.
3. Xem nhiều: tối đa 10, viewCount DESC,id DESC.
4. Đánh giá cao: tối đa 10 phim có ít nhất 1 review public, avgRating DESC,reviewCount DESC,id DESC.

Một phim có thể hiện ở nhiều nhóm. Nhóm rỗng ẩn section; nếu không có bất kỳ phim public nào hiện “Chưa có phim”. Card có poster/placeholder,title,year,điểm hoặc “Chưa đánh giá”, link detail. Không tăng view ở Home/list/similar.

### Tìm/lọc/sort/page

GET /movies có q,category,year,sort,page. q trim/NFC, tìm substring chỉ trong title, không phân biệt hoa thường nhưng phân biệt dấu. q trống = không lọc tên; một ký tự hợp lệ. q>200 →400 và giữ form; không cắt âm thầm. %,_,backslash phải được tìm như ký tự literal, không wildcard từ client.

category một ID category chưa deleted; year một số nguyên trong khoảng 1888…năm hiện tại+2. Thiếu/trống = không filter; sai định dạng/range/category không tồn tại →400 chỉ rõ field, không bỏ filter rồi trả toàn bộ. Year hợp lệ nhưng chưa có phim →empty. Kết hợp q AND category AND year; phim PUBLISHED luôn bắt buộc. Category dropdown chỉ category chưa deleted; year dropdown từ phim public.

Sort whitelist:
- newest (mặc định): updatedAt DESC,id DESC.
- views: viewCount DESC,id DESC.
- rating: phim có review trước, average chưa làm tròn DESC,reviewCount DESC,id DESC; chưa review xếp cuối.
- title: title NFC so không phân biệt hoa thường, có phân biệt dấu, tăng dần; id ASC.

Sort lạ →newest; dùng whitelist cố định, không ghép tham số làm biểu thức. Page theo SYS-03. Count là số phim DISTINCT cùng điều kiện, page tối đa 10. Khi đổi filter/sort trong form đặt page=1; URL GET có page vẫn chuẩn hóa theo SYS-03. Encoding query đúng, không làm mất dấu/nhân đôi &. Không hỗ trợ nhiều category/year range/director/rating filter/autocomplete.

### Detail, media, similar

Detail chỉ public phim PUBLISHED, cả khi actor là Admin. Hiện title,poster,description,year,duration,categories,viewCount,avgRating/reviewCount, player, review/Q&A và similar. Tên category chưa deleted. Tương tác đăng nhập theo 004–006; trạng thái duyệt riêng không rò public.

Video chính MP4; nếu trống dùng trailer MP4. Nếu cả hai có: ưu tiên video, khi lỗi có nút fallback trailer, không vòng lặp tải vô hạn. Không autoplay có tiếng, có controls và thông báo nếu không phát được. Không dựng iframe từ HTML/URL client. Không tải video qua server MovieHub. Hiển thị thiếu media không làm phim biến mất.

Similar tối đa 6 phim DISTINCT PUBLISHED, chia sẻ ít nhất 1 category đang hoạt động, loại id hiện tại; order số category chung DESC,viewCount DESC,id DESC. Không có thì ẩn section. Không gọi AI hay random.

### Functional Requirements / Acceptance Criteria EARS

- CAT-AC-01 (State-driven): WHILE phim không ở trạng thái PUBLISHED THE system SHALL loại phim khỏi Home/list/count/similar và không trả metadata tại detail public.
- CAT-AC-02 (Event-driven): WHEN mở Home THE system SHALL lấy bốn nhóm theo giới hạn/thứ tự trên, empty không tạo dữ liệu giả.
- CAT-AC-03 (Event-driven): WHEN tìm tên THE system SHALL áp dụng substring case-insensitive/accent-sensitive và xem wildcard client là literal.
- CAT-AC-04 (Event-driven): WHEN có nhiều filter THE system SHALL kết hợp AND, distinct phim, count đúng.
- CAT-AC-05 (Unwanted): IF q/category/year sai THEN THE system SHALL trả 400/lỗi field, không âm thầm bỏ điều kiện; sort sai dùng newest.
- CAT-AC-06 (Ubiquitous): THE system SHALL dùng 10 phim/trang, chuẩn hóa page theo SYS-03 và giữ filter trên link.
- CAT-AC-07 (Ubiquitous): THE system SHALL dùng sort ổn định, rating chưa review ở cuối và không coi null là 0 sao.
- CAT-AC-08 (Event-driven): WHEN mở detail hợp lệ THE system SHALL hiện đủ metadata và tính view theo SYS-07.
- CAT-AC-09 (Unwanted): IF ID sai/không public THEN THE system SHALL trả 404, không tăng view hoặc hiện metadata.
- CAT-AC-10 (Event-driven): WHEN play media lỗi/thiếu THE system SHALL dùng fallback đã định nghĩa và giữ phần trang còn lại.
- CAT-AC-11 (Event-driven): WHEN tính similar THE system SHALL loại phim hiện tại, hidden, trùng và giới hạn 6 theo thứ tự trên.
- CAT-AC-12 (Unwanted): IF tăng view lỗi hoặc request cùng session cạnh tranh THEN THE system SHALL xử lý đúng SYS-07, không làm mất tăng từ session khác.
- CAT-AC-13 (Ubiquitous): THE system SHALL escape metadata và dùng placeholder local khi ảnh lỗi.

### Hợp đồng giao tiếp

| Route | Input | Kết quả |
|---|---|---|
| GET / | Không | 200 Home |
| GET /movies | q?,category?,year?,sort?,page? | 200 list/empty; 400 filter invalid |
| GET /movies/detail | id bắt buộc BIGINT dương; reviewPage?,questionPage?,questionId?,answerPage?,myQaPage? | 200 detail; 404 phim không public |

Các tham số trang phụ theo SYS-03, không reset lượt xem ngoài SYS-07. questionId nếu có phải là question public thuộc phim, sai →404. Không tạo route /movies/search hoặc /movies/{id} song song trong baseline.

### Key Entities

Movies,Categories,MovieCategories và aggregate Reviews theo SYS-02. Count/sort rating phải tính đúng phim nhiều category/review, tránh nhân bản do join. Module 007 quản lý catalog, 005 cung cấp điểm, 006 nội dung hỏi đáp.

## Success Criteria

- CAT-SC-01: 23 phim thỏa filter trả 10/10/3 trên 3 trang, không duplicate hoặc hidden.
- CAT-SC-02: Mọi sort cho kết quả ổn định trên dữ liệu không đổi, gồm tie/null.
- CAT-SC-03: Boundary 29:59/30:00 và request song song tuân thủ đúng view.
- CAT-SC-04: Có bằng chứng phát được ít nhất 1 MP4 hợp lệ, fallback và placeholder.
- CAT-SC-05: Mục tiêu thời gian/viewport theo SYS-06 được đo khi có ứng dụng.

## Assumptions / Out of Scope

Ảnh/video được phép dùng, không hứa external URL luôn sẵn sàng. Breadcrumb/navbar search FR-25 là P1; nếu làm chỉ điều hướng về query chuẩn /movies. Không streaming thương mại, upload, YouTube embed, nhiều tập, cast/director hay recommendation AI.
