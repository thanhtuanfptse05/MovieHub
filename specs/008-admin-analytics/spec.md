# 008-admin-analytics: thống kê quản trị

Ngày 2026-10-25 | Version 1.0.0 | Draft | P0; biểu đồ category P1
Nguồn UC-16; FR-21,26; BR-24; mục 14 kế hoạch.
Áp dụng [quy tắc chung](../shared/system-rules.md), [dữ liệu](../shared/data-contract.md), D-12.
Chỉ Admin ACTIVE; mọi chỉ số toàn thời gian, không suy diễn view theo ngày khi chưa lưu event.

## User Scenarios & Testing

### ANA-US-01: nhìn tổng quan (P0)

Là Admin, tôi muốn biết quy mô và tương tác để kiểm tra vận hành.
Given fixture trong acceptance.md có 3 phim views 100/40/60 và 3 review approved 5/3/1, When mở dashboard, Then SUM=200,MAX=100,MIN=40,AVG=3.0; nhãn giải thích tập tính rõ.
Giá trị độc lập: chạy trên dữ liệu fixture, không cần phát video hoặc biểu đồ.

### ANA-US-02: hàng chờ và top phim (P0)

Là Admin, tôi muốn thấy số chờ duyệt và top 5 để điều hướng quản trị.
Given review/question/answer PENDING kể cả parent ẩn, Then count khớp queue 007 và có link filter.
Given hai phim bằng views, Then thứ tự id DESC quyết định, không random.

### ANA-US-03: dữ liệu rỗng/lỗi (P0)

Given không có phim/review, Then count/sum=0, max/min/avg=“N/A”, top=[].
Given DB lỗi, Then báo lỗi 500 an toàn; không hiện số 0 như dữ liệu thật.

### Edge Cases

Chỉ có phim HIDDEN; view=0; số lượng/lượt xem lớn hơn INT; nhiều join gây nhân SUM; review bỏ mềm; phim ẩn còn review APPROVED; account ADMIN không tính tổng USER; category có nhiều phim/1 phim nhiều category; cập nhật đồng thời khi dashboard tải.

## Requirements

### Chỉ số và mẫu số bắt buộc

| Mã | Nhãn UI | Tập dữ liệu / công thức | Rỗng |
|---|---|---|---|
| KPI-01 | Tổng phim (mọi trạng thái) | COUNT tất cả Movies: DRAFT+PUBLISHED+HIDDEN | 0 |
| KPI-02 | Phim đang công khai | COUNT Movies PUBLISHED | 0 |
| KPI-03 | Người dùng (role USER) | COUNT Users role=USER, cả ACTIVE/INACTIVE, không ADMIN | 0 |
| KPI-04 | Tổng review chưa bỏ | COUNT Reviews deleted_at rỗng, mọi status | 0 |
| KPI-05 | Tổng lượt mở chi tiết, mọi phim | SUM Movies.view_count, mọi status | 0 |
| KPI-06 | Lượt xem cao nhất / thấp nhất | MAX/MIN Movies.view_count, mọi status | N/A nếu không phim; có phim view=0 thì là 0 |
| KPI-07 | Điểm TB review đã duyệt, mọi phim | AVG rating Reviews APPROVED,chưa deleted, kể cả phim ẩn | N/A nếu không review đủ điều kiện |
| KPI-08 | Nội dung chờ duyệt | COUNT review PENDING/chưa deleted + question PENDING + answer PENDING, gồm parent ẩn | 0 |
| KPI-09 | Top 5 phim theo lượt xem | Movies mọi status, viewCount DESC,id DESC, tối đa 5 | [] |

KPI-07 là trung bình có trọng số theo số review, không phải trung bình của trung bình từng phim, không phải điểm public của một phim. Hiển thị rõ “mọi phim, gồm phim ẩn”. Public rating trong 005 chỉ review của phim public. Không thay điểm bằng 0 nếu chưa có đánh giá. Điểm hiển thị 1 chữ số thập phân HALF_UP, count/sum là số nguyên chính xác.

KPI-08 hiển thị thêm ba thành phần review/question/answer và tổng của chúng. Review deleted không tính; parent không public vẫn tính backlog, tương ứng queue 007 có nhãn unavailable. Link top tới admin movie edit, không link public cho phim ẩn; bảng top có status.

Số liệu aggregate từ DB qua JPA, không kéo toàn bộ review/phim về cộng tay, không hardcode. Query cần tránh nhân bản do join category/review. Nếu cache thì phải bảo đảm lần GET sau mutation đã commit phản ánh dữ liệu mới; baseline ưu tiên không cache. Mỗi GET dashboard lấy một snapshot đọc nhất quán, không trộn total/count từ hai trạng thái dữ liệu do nhiều query; plan chọn transaction/isolation thích hợp và có test đồng thời. Không hứa realtime push.

### Tùy chọn P1 FR-26

Biểu đồ/bảng số phim PUBLISHED theo category chưa deleted. Count DISTINCT movie/category; phim nhiều category tính một lần trong mỗi category, vì vậy tổng cột có thể lớn hơn KPI-02; hiển thị chú thích này. Category chưa có phim hiện 0. Order count DESC,name ASC,id ASC. Không thêm thư viện chart mặc định; cách render được quyết định trong plan và phải theo allowlist.

### Functional Requirements / Acceptance Criteria EARS

- ANA-AC-01 (State-driven): WHILE actor không Admin ACTIVE THE system SHALL chặn dashboard theo SYS-01/SYS-04.
- ANA-AC-02 (Event-driven): WHEN mở dashboard THE system SHALL tính đúng KPI-01…09 theo tập dữ liệu/công thức trên.
- ANA-AC-03 (Ubiquitous): THE system SHALL dùng COUNT,SUM,AVG,MAX,MIN từ dữ liệu lưu thật, không nhân aggregate do join.
- ANA-AC-04 (Unwanted): IF aggregate trả null trên tập rỗng THEN THE system SHALL đổi SUM→0 và AVG/MAX/MIN→N/A, không lỗi.
- ANA-AC-05 (Ubiquitous): THE system SHALL tách AVG toàn hệ thống khỏi rating public và ghi rõ mẫu số/phạm vi trên UI.
- ANA-AC-06 (Event-driven): WHEN có nội dung pending THE system SHALL hiển thị tổng và từng loại khớp queue 007.
- ANA-AC-07 (Event-driven): WHEN xếp top THE system SHALL giới hạn 5, tie theo id DESC, hiện status và admin link.
- ANA-AC-08 (Unwanted): IF tải số liệu thất bại THEN THE system SHALL không giả dữ liệu 0; trả error an toàn và log.
- ANA-AC-09 (Ubiquitous): THE system SHALL giữ một snapshot nhất quán trong mỗi lần tải; lần GET sau mutation đã commit dùng dữ liệu hiện hành.
- ANA-AC-10 (Optional/P1): WHERE có FR-26 THE system SHALL dùng DISTINCT theo category và chú thích một phim có thể thuộc nhiều cột.

### Hợp đồng giao tiếp

GET /admin/dashboard không nhận from/to/period để đổi nghĩa KPI. Tham số lạ không thay tập dữ liệu. Thành công 200 dashboard; không auth/role, DB lỗi theo SYS-04. Không export endpoint hay AJAX polling bắt buộc. View admin dưới WEB-INF/views, dynamic title/status đều escape.

### Key Entities

Đọc Movies,Users,Reviews,Questions,Answers; P1 thêm Categories/MovieCategories. Không ghi DB hay tăng view khi mở dashboard. Không có bảng analytics/event mới. Tổng views dùng BIGINT hoặc kiểu số đủ chính xác; không convert qua floating point rồi hiển thị số nguyên.

## Success Criteria

- ANA-SC-01: Fixture acceptance cho đúng mọi KPI, gồm hidden movies, inactive USER và review bị bỏ.
- ANA-SC-02: Hai phim cùng category và nhiều review không làm SUM/COUNT tăng sai do join.
- ANA-SC-03: Tập rỗng hiển thị đúng 0/N/A, không lỗi; lỗi DB không bị diễn giải là tập rỗng.
- ANA-SC-04: Snapshot KPI nhất quán khi có review đang duyệt; refresh sau commit phản ánh quyết định.
- ANA-SC-05: Bằng chứng demo thể hiện đủ COUNT/SUM/AVG/MAX/MIN.

## Assumptions / Out of Scope

Toàn thời gian; không doanh thu, tăng trưởng theo ngày, retention, người xem duy nhất, thời gian xem, lọc 7/30 ngày, export hay SLA 500ms p95. view_count không đủ để tái tạo các chỉ số thời gian đó.
