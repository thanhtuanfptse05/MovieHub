# Kịch bản nghiệm thu và oracle liên module

Ngày 2026-10-25 | Thiết kế test; TẤT CẢ CHƯA CHẠY. Không đánh dấu Passed cho đến khi có ứng dụng và bằng chứng. TC-06 và INT-08/09 đã thay theo R-01, không còn kiểm tra reset email/token.

## 1. Fixture tính toán riêng

Chạy trên DB test riêng, không xóa DB người dùng. ID dưới đây là nhãn fixture, không yêu cầu auto-ID thực tế bằng tên nhãn. Chụp view_count trước khi mở detail vì mở detail có thể tăng view.

- A1,A2: Admin ACTIVE. U1: User ACTIVE. U2: User INACTIVE. Tổng user role USER=2, không gồm Admin.
- C1,C2: category chưa deleted. M1=PUBLISHED,views=100,categories=C1+C2; M2=PUBLISHED,views=40,category=C1; M3=HIDDEN,views=60,category=C2.
- R1(U1,M1)=5 APPROVED; R2(A1,M1)=3 APPROVED; R3(U2,M1)=1 PENDING; R4(U1,M3)=1 APPROVED; R5(A2,M2)=4 APPROVED nhưng deleted_at khác null.
- Q1(M1)=APPROVED; Q2(M1)=PENDING; Q3(M3)=REJECTED; Q4(M3)=PENDING. A11(Q1)=APPROVED; A12(Q1)=PENDING; A13(Q3)=PENDING (fixture lịch sử: Q3 từng APPROVED lúc gửi answer rồi bị từ chối, M3 từng public rồi bị ẩn). Không tạo answer qua service khi parent PENDING/REJECTED.

Oracle ban đầu: KPI tổng phim=3,public=2,USER=2,review chưa bỏ=4,SUM views=200,MAX=100,MIN=40,AVG approved chưa bỏ=(5+3+1)/3=3.0,pending review=1/question=2/answer=2,total=5. Top M1,M3,M2. Rating public M1=4.0,count=2; M2 chưa đánh giá,count=0. Q1 public chỉ A11,answerCount=1; Q2/Q3 không public. Hãy reset fixture trước mỗi scenario độc lập.

## 2. Giữ truy vết 25 test nguồn

| TC nguồn | Thực hiện và kết quả phải quan sát | AC chính |
|---|---|---|
| TC-01 | Register email mới →USER ACTIVE, hash, về login chưa auth | AUTH-AC-01,02 |
| TC-02 | Hai email canonical trùng →tối đa 1 user, field error | AUTH-AC-03 |
| TC-03 | Login đúng/sai/INACTIVE, session ID đổi chỉ khi thành công | AUTH-AC-04,05 |
| TC-04 | User ACTIVE direct GET/POST admin →403, không dữ liệu | AUTH-AC-08,ADM-AC-01 |
| TC-05 | Logout POST, cookie cũ không vào favorites | AUTH-AC-07,FAV-AC-01 |
| TC-06 | Reset chưa có context/đã dùng/hết phiên →GET303 forgot hoặc POST có CSRF hợp lệ409; cookie/CSRF cũ403 theo thứ tự SYS-04; password không đổi | AUTH-AC-12 |
| TC-07 | Home không có M3/HIDDEN hoặc DRAFT | CAT-AC-01,02 |
| TC-08 | 23 phim matching →10/10/3; filter/order không mất | CAT-AC-03…07 |
| TC-09 | Sort/keyword injection →không thay query predicate; sort lạ newest | CAT-AC-03,05 |
| TC-10 | Detail ID sai/ẩn →404, không tăng view | CAT-AC-09 |
| TC-11 | Video rỗng/lỗi →fallback/thông báo, detail vẫn đọc được | CAT-AC-10 |
| TC-12 | Favorite add hai lần/song song →một active row | FAV-AC-03 |
| TC-13 | Rating 6/0/1.5 →400, không insert/update | REV-AC-01 |
| TC-14 | Review PENDING không public/không tăng điểm | REV-AC-02,07 |
| TC-15 | Approve R3 →M1=(5+3+1)/3=3.0,count=3 | ADM-AC-10,REV-AC-08 |
| TC-16 | Guest gửi question →login, không lưu | QA-AC-01 |
| TC-17 | Answer cho Q2 PENDING →404, không lưu | QA-AC-03 |
| TC-18 | Create/edit trùng slug →400, rollback links | ADM-AC-03 |
| TC-19 | Hide M1 →detail404, mọi tương tác/FK giữ nguyên | ADM-AC-04 |
| TC-20 | Delete C1 đang liên kết M1/M2 →409 | ADM-AC-06 |
| TC-21 | Self-lock/admin cuối/chỉnh chéo →không mất Admin ACTIVE | ADM-AC-08 |
| TC-22 | Fixture rỗng →0/N/A đúng; chỉ view=0 →MAX/MIN=0 | ANA-AC-04 |
| TC-23 | Text script trong review/Q&A/title →hiện text, không chạy | REV-AC-11,QA-AC-11,CAT-AC-13 |
| TC-24 | Thiếu/sai CSRF mọi POST kể cả auth →403, không mutation | SYS-06 |
| TC-25 | DB unavailable →500 an toàn; không password/token/stacktrace | SYS-04,ANA-AC-08 |

## 3. Nghiệm thu bổ sung bắt buộc

| ID | Scenario và expected result |
|---|---|
| INT-01 | Review R1 APPROVED sửa 5→2 →PENDING; M1 chỉ còn R2=3.0,count=1. Form duyệt R1 cũ →409 |
| INT-02 | Delete review rồi create lại →cùng row, contentRevision tăng, PENDING, không public |
| INT-03 | Hai Admin cùng approve cùng contentRevision →audit người đầu giữ nguyên. Tác giả sửa rồi Admin approve form cũ →409 |
| INT-04 | Reject Q1 →Q1/A11 không public, status A11 vẫn APPROVED; approve Q1 →A11 hiện lại, A12 vẫn ẩn |
| INT-05 | M1 favorite active: hide M1 →không trong favorites count/list; publish lại →hiện lại; remove khi hidden vẫn bỏ được |
| INT-06 | View với đồng hồ kiểm soát: lần đầu +1; +29:59 không; +30:00 thêm1; hai request cùng session tối đa1; hai session mỗi phiên +1 |
| INT-07 | DB tăng view lỗi →detail200 nếu đọc được, view/timestamp không đổi; lần sau retry được |
| INT-08 | Hai context cùng expectedCredentialsVersion reset đồng thời →một commit, một409; phiên cũ/context cũ mất hiệu lực; DB rollback không đổi hash/version và cho retry nếu context còn đúng |
| INT-09 | Nhập email ACTIVE trim/khác hoa thường →mở form password ngay, không mail/OTP/token; email không có/INACTIVE→400, context cũ bị xóa; fake userId/email trên POST reset không đổi target. Hai tab chọn email khác nhau: flowVersion form cũ→409, không đổi password target mới. Lặp lại với ADMIN ACTIVE cũng được reset theo R-01 |
| INT-10 | U1 gửi userId=U2/role=ADMIN ở profile/favorites/review →không đổi owner/quyền; sửa review U2 →403 |
| INT-11 | Admin hạ role/khóa user đang có session →request bảo vệ kế tiếp dùng quyền mới; role cũ session không bypass |
| INT-12 | Hai Admin ACTIVE cùng hạ role người kia trên hai transaction →ít nhất một Admin ACTIVE sau commit |
| INT-13 | Category delete đồng thời movie gán category →không có phim gắn category deleted, một thao tác conflict/rollback |
| INT-14 | Hai create Q&A cùng submissionId →một row; validation/DB lỗi không consume nonce; nonce khác có thể gửi cùng text |
| INT-15 | Pagination: -1/abc/overflow→1; 999→trang cuối; empty→page1,totalPages0; phim nhiều category không duplicate |
| INT-16 | q chứa %/_/backslash →literal; một ký tự hợp lệ; q201/filter invalid→400; sort sai→newest |
| INT-17 | Similar tối đa6 distinct, loại self/hidden, order sharedCategoryCount/views/id chính xác |
| INT-18 | Form phim/user/profile version cũ →409, không mất thay đổi từ tab đầu |
| INT-19 | Password 19 emoji, mỗi emoji một code point/bốn byte UTF-8, tổng76 byte →400 dù đủ số ký tự tối thiểu; không truncate; confirm khác whitespace →không khớp |
| INT-20 | URL javascript/data/file/iframe hoặc HTTP ngoài hai host chính xác localhost/127.0.0.1 trong dev →400; ngoài dev chỉ HTTPS; HTTPS ảnh chết →placeholder |
| INT-21 | returnTo=https://... hoặc //host hoặc traversal →bỏ; returnTo hợp lệ giữ filter và kiểm tra quyền sau login |
| INT-22 | Dashboard dùng oracle fixture, không nhân SUM do M1 có 2 category/3 reviews; refresh sau commit khớp queue |
| INT-23 | Bypass client validation vẫn bị server từ chối; context deploy /MovieHub không làm link mất context |
| INT-24 | GET logout/hide/delete/moderate →405 hoặc route không tồn tại404, không mutation |
| INT-25 | APPROVE lại item đã APPROVED với version hiện hành, cùng contentRevision/parent hợp lệ →no-op, audit/version không đổi |
| INT-26 | Lỗi 403/404/500 render view tiếng Việt riêng, đúng status, không trang mặc định Tomcat/stacktrace hoặc redirect200 |

## 4. Ghi kết quả và release gate

Mỗi kết quả cần ID, ngày/giờ, commit, DB fixture, actor, input (che secret), expected/actual, trạng thái Not run/Passed/Failed/Blocked và bằng chứng screenshot/log/query an toàn. Không chụp password. Với concurrency ghi thứ tự commit và dữ liệu sau cùng; dùng đồng hồ kiểm soát cho session/view để không đợi 30 phút thực.

Nghiệm thu ứng dụng cần: toàn bộ P0 và test liên quan pass; schema/seed idempotent; guard/CSRF/XSS/hash/context reset/rollback; 3 viewport; Ant compile/test/dist; deploy Tomcat/JPA/video thật và README chạy máy khác. Không cần SMTP/mail inbox theo R-01. Thư viện cần inventory được duyệt, không tuyên bố pass trên scaffold chỉ có .gitkeep.
