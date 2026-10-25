# MovieHub: quy tắc UI bắt buộc cho agent

Phiên bản 1.0.0 | Ngày 2026-10-25 | Hiệu lực: yêu cầu trực tiếp của chủ dự án, áp dụng mọi module và mọi môi trường ứng dụng.

Tài liệu này là quy định thực thi. [design.md](design.md) mô tả hình thức; [specs](specs/overview.md) mô tả nghiệp vụ. Agent phải đọc cả ba trước công việc giao diện. Dữ liệu mẫu trong HTML đính kèm chỉ để tham khảo bố cục, không được mang vào sản phẩm.

## 1. Hai điều cấm chính

### UI-DATA-01: cấm hardcode dữ liệu nghiệp vụ

Mọi dữ liệu nghiệp vụ đã lưu hoặc cần được quản lý trong MovieHub phải đến từ database qua JPA/Service/DTO/Servlet. Giao diện không được có phim, user, category, review, câu hỏi, câu trả lời, favorite, poster/avatar/media thực thể, rating, views, tổng bản ghi, KPI hoặc trạng thái tài khoản viết sẵn.

Điều cấm áp dụng cho JSP/HTML/JS/CSS, data-* attributes, hidden input, JSON inline, localStorage/sessionStorage, mock API, static JSON/CSV và các mảng/list/map/DTO cố định trong Java dùng để lấp giao diện. Chuyển hardcode từ JS sang Servlet/Service không làm dữ liệu thành hợp lệ. Tên biến như demoData/temporaryData/mockData không tạo ngoại lệ.

Không được “tạm làm đẹp trước rồi nối DB sau” trong giao diện ứng dụng. Khi backend/DB chưa sẵn sàng, dựng layout không có business records, dùng empty/error/loading đúng nghĩa và ghi phần chưa tích hợp trong báo cáo developer. Không phát hành screenshot có dữ liệu giả như bằng chứng ứng dụng đã hoạt động.

### UI-COPY-01: cấm hiển thị tài liệu Business Rules trên UI

Không có section/card/banner/badge/footer/dialog/toast/tooltip/placeholder/accessible name giải thích Business Rules, BusinessRule, business_rule, mã BR/FR/UC/NFR, acceptance criteria, schema, JPA, transaction hoặc ghi chú dành cho agent/developer.

Không đưa lên public hoặc admin những câu như “Tuân thủ BR-23”, “Hệ thống BR-24”, “FR-17 kho số liệu”, “UNIQUE(user_id,movie_id)”, “COUNT/SUM/AVG từ SQL Server”, “Session invalidate theo SEC-02” hoặc “Business Rules đang áp dụng”. Không render một block rồi giấu bằng display:none/sr-only để né kiểm tra.

UI chỉ hiển thị nội dung sản phẩm, dữ liệu thực, hành động và phản hồi cần để sử dụng. Quy tắc nghiệp vụ vẫn được thực thi đầy đủ trên server; việc không in quy tắc ra màn hình không cho phép bỏ validation/quyền/transaction.

## 2. Nguồn dữ liệu và ranh giới trình bày

### UI-DATA-02: đường đi dữ liệu

```text
SQL Server
  → JPA DAO/repository (named/bound parameters)
  → Service (quyền, validation, aggregate, transaction)
  → DTO/view model
  → Servlet request/session attributes đã guard
  → JSP/JSTL/EL có escaping
  → browser hiển thị
```

DAO/Service là nơi lọc điều kiện public/owner và tính count/rating/KPI. Không kéo tất cả phim về rồi c:if ẩn phim HIDDEN trong JSP, không tính điểm trung bình từ10 review đang thấy, không lấy số card trang hiện tại làm totalCount. Count/paging/filter phải cùng predicate ở server.

Session có thể giữ danh tính/CSRF/context theo auth spec; dữ liệu user/role phải đối chiếu DB ở thời điểm quy định, không tự gán tên/avatar/Admin trong header. Query người dùng nhập được giữ lại để điền form, không phải dữ liệu DB giả.

### UI-DATA-03: các giá trị được phép tĩnh

Phân biệt hằng số giao diện với bản ghi nghiệp vụ. Các mục sau được phép trong mã khi phục vụ đúng vai trò:

| Được phép | Ví dụ/giới hạn |
|---|---|
| Nhãn/brand/copy tác vụ | MovieHub, “Đăng nhập”, “Lưu thay đổi”, “Chưa có phim”; không giả tên người/phim |
| Design token và component geometry | Màu, font, spacing, radius, breakpoint, aspect-ratio |
| Asset nhận diện/placeholder trung tính | Logo, icon, nền CSS, poster trống; không thay bằng thực thể khác |
| Mapping nhãn enum | PUBLISHED→“Công khai”, không tự quyết định phim nào có status đó |
| Miền lựa chọn cố định của nghiệp vụ | Rating1–5, sort whitelist, enum trạng thái từ domain/server; không sao chép danh sách category hoặc record cố định |
| Dữ liệu form người dùng đang nhập | q/email/content sau lỗi; escape, không lộ password, không biến thành dữ liệu đã lưu |
| Giá trị môi trường/runtime | CSRF/flowVersion từ server, năm hiện tại từ clock, media currentTime/duration từ video thật; không dựng thời gian/progress giả |

Nếu một giá trị mô tả một thực thể/tương tác/thống kê thì phải truy về DB hoặc kết quả tính từ DB. Nếu là lựa chọn domain/nhãn UI thì không cần tạo bảng DB chỉ để lưu chữ nút. Ngoại lệ trong bảng không cho phép đóng gói business records vào “cấu hình” để né UI-DATA-01.

### UI-DATA-04: hợp đồng nguồn theo khu vực

| Khu vực | Nguồn bắt buộc | Không được làm |
|---|---|---|
| Hero/Home sections | Movies public/featured; aggregate Reviews | Chọn một phim cố định trong JSP để luôn có hero |
| Catalog/search/similar | Movies,Categories,MovieCategories + Service filter/order/page | Mảng phim, filter browser trên dataset mẫu, random similar |
| Category menu/filter | Categories chưa deleted từ DB | Viết sẵn5 thể loại giống mockup |
| Year options | Năm có phim public theo003 | Danh sách năm mẫu giả được trình bày như dữ liệu catalog |
| Detail/poster/media | DTO từ movie ID đã kiểm public; URL lưu trong DB | Mapping title/id→URL ảnh trong JS, player poster cố định |
| Rating/reviewCount | Review APPROVED/chưa bỏ theo005 | Default4.8 hoặc tính từ review mẫu/đang hiện |
| User header/profile | Users của session hiện hành đã guard | Tên/avatar/role giả hoặc đọc role từ localStorage |
| Favorites và badge count nếu có | Favorites active của actor +movie public | Badge5 cố định hoặc chỉ đổi màu nút trên client |
| Review/Q&A/author | Reviews,Questions,Answers,Users đúng quyền/status | Review/testimonial minh họa làm nội dung cộng đồng thật |
| Admin list/status | DB entities theo007 | Rows cố định hoặc status gắn theo index |
| Dashboard/top/pending | Aggregate query theo008 | KPI/percent tăng trưởng/chart data hardcode |
| Count/page/empty | DTO từ count query cùng tập dữ liệu | totalCount=10 vì có10 card, page1…99 cố định |
| Dữ liệu video đang phát | Media lấy URL từ DB; time/state từ HTMLMediaElement | Progress84%, quality4K, nhiều server không tồn tại |

Backdrops/ảnh banner dùng posterUrl của movie nếu schema chưa có backdrop riêng; không thêm trường/feature ngoài spec chỉ để giống ảnh rộng trong reference. Giữ tính trung thực hơn sự đầy đủ của mockup.

### UI-DATA-05: không fallback sang dữ liệu giả

- Query thành công và rỗng →empty state thật, count0 nếu đúng nghĩa.
- Query thất bại/DB mất kết nối →error theo SYS-04, không trả empty0 hoặc mock records.
- Chưa tích hợp DAO →ghi rõ trạng thái chưa tích hợp trong báo cáo; trang ứng dụng không được giả đã có dữ liệu.
- Ảnh lỗi →placeholder trung tính, không poster/avatar của người khác.
- Aggregate không có mẫu số →“Chưa đánh giá”/N/A theo spec, không điểm mặc định.
- Không đủ item cho5 cột/10 item →render đúng số có thật, không nhân đôi card để lấp hàng.

Không có fallback kiểu `items.length ? items : demoMovies`, `rating || 4.8`, `total || 1250`, hoặc catch DB exception rồi trả list viết sẵn. Các đoạn trên là ví dụ bị cấm trong tài liệu, không phải mã để copy vào ứng dụng.

### UI-DATA-06: seed và test fixture

Dữ liệu demo được tạo bằng seed vào DB test/demo có chủ đích rồi đọc qua chính DAO/Service như dữ liệu thường. Seed là artifact dữ liệu riêng ngoài view; có idempotency và trạng thái/unique/FK hợp lệ. Không dùng controller tự insert seed mỗi lần GET, không đóng gói fixture vào runtime UI, không để flag demo tự bật khi DB lỗi.

Test fixture trong test suite được phép để kiểm chứng nghiệp vụ; không được import fixture/test helper vào application path. Preview để nghiệm thu UI ứng dụng cũng phải dùng DB fixture, không có chế độ mock bypass hai rule này nếu chưa được người dùng yêu cầu riêng.

### UI-DATA-07: thông báo và cập nhật sau hành động

Thông báo thành công, state “Đã lưu”, count mới và trạng thái duyệt chỉ hiện sau server xác nhận commit. JS không tự cộng1 view/favorite/review để giả kết quả DB. Với enhancement bất đồng bộ, đọc response authoritative và xử lý rollback/error; baseline JSP dùng Post/Redirect/Get.

Định dạng số có thể rút gọn/thêm phân cách theo quy ước chung nhưng phải giữ nghĩa; không đổi thang1–5 thành1–10 hoặc gắn IMDb khi không có nguồn đó. Trạng thái metadata phải cùng movie/user với card, không copy chéo do fallback.

## 3. Copy sản phẩm và nội dung bị loại

### UI-COPY-02: phạm vi cấm bao gồm mọi bề mặt UI

Áp dụng header/footer, headline/subtitle, KPI caption, bảng, hint/error, tooltip title, aria-label/aria-describedby, text sr-only, dialog, toast, placeholder, empty state và trang403/404/500. Admin là người dùng sản phẩm, không phải ngoại lệ để trình bày đặc tả hay stack triển khai.

Không có đoạn giới thiệu “ứng dụng dùng Java17/Ant/Tomcat/SQL Server”, panel “kiến trúc MVC”, giải thích BCrypt/JPA/CSRF, bảng rubric PRJ301 hoặc prompt agent. Các thông tin đó thuộc docs/design/spec/code comments phù hợp, không thuộc UI.

Quy tắc không tự kiểm duyệt dữ liệu người dùng: nếu một review/tên phim thật trong DB tình cờ chứa chữ “Business Rules” hoặc “BR-23”, đó là nội dung thực thể được escape và xử lý theo quy trình moderation. Không thêm bộ lọc xóa chữ trong view. Điều cấm là sản phẩm tự sinh tài liệu nghiệp vụ/engineering copy trên màn hình.

### UI-COPY-03: phản hồi tác vụ được phép

| Nên hiện | Không hiện |
|---|---|
| “Đã lưu thay đổi” | “Commit EntityTransaction thành công” |
| “Nội dung đang chờ duyệt” | “PENDING theo BR-12” |
| “Email đã được sử dụng” | “Vi phạm UNIQUE Users.email” |
| “Bạn đã đánh giá phim này. Bạn có thể sửa đánh giá” | “UNIQUE(user_id,movie_id) theo BR-11” |
| “Thể loại đang được sử dụng” | “Foreign key MovieCategories ngăn DELETE” |
| “Không thể thay đổi quyền tài khoản này” | “COUNT ADMIN ACTIVE phải≥1 theo BR-16” |
| “Dữ liệu đã thay đổi. Vui lòng tải lại” | “OptimisticLockException/version mismatch” |
| “Mật khẩu chưa hợp lệ” +hướng sửa ngắn tại field | Panel giải thích BCrypt/cost/72-byte specification |
| “Phim hiện không công khai” | “APPROVE predicate failed theo ADM-AC-11” |
| “Mọi phim, gồm phim ẩn” ở KPI thích hợp | “AVG JPQL gồm các entity HIDDEN” |

Hướng dẫn ngắn để nhập đúng/chữa lỗi là copy sản phẩm, được phép khi gắn trực tiếp tác vụ. Không in toàn bộ chính sách, các mã rule, thuật toán hoặc mô hình dữ liệu dưới form. Field maxlength/min/max vẫn được phép để hỗ trợ input; không tạo section “Quy tắc nghiệp vụ”.

### UI-COPY-04: không hứa chức năng/dữ liệu chưa có

Không hiển thị 4K/Dolby/HDR, “xem nhiều tuần này”, % tăng trưởng, hàng nghìn user, SLA duyệt2h, “bản quyền đầy đủ” hoặc “được xác minh” khi schema/spec/dữ liệu chưa cung cấp bằng chứng đó. Không dùng số đẹp để lấp KPI.

Theo R-01, forgot không xác minh chủ email: UI không được ghi “Đã xác minh email” hoặc thêm mail sent/OTP page. Cảnh báo kỹ thuật/giải thích quyết định R-01 thuộc docs; UI chỉ dẫn nhập email rồi password theo auth spec. Không tự đổi luồng đã được yêu cầu trong khi thiết kế.

## 4. Logic và phạm vi không đặt trong view

### UI-LOGIC-01: server là nguồn quyết định

User/owner/role/status/public predicates do Filter/Servlet/Service xác định, DB là nguồn dữ liệu bền vững. JSP chỉ render trạng thái và quyền đã cấp; JS chỉ hỗ trợ tương tác/validation, không cấp quyền, không quyết định ai được approve, không dùng client-side filter để che dữ liệu private đã gửi xuống.

Không viết SQL/JPQL/JPA/Java scriptlet trong JSP; không logic BCrypt/token/password tại JS. Không đưa hash/password/secret hoặc dữ liệu review/Q&A riêng tư của người khác vào hidden DOM/inline JSON dù UI không hiện.

### UI-SCOPE-01: reference không mở rộng MVP

Không tự thêm director/cast/search đạo diễn, accepted answer, like/report/share, notification, nhiều video server, audit-log route, bulk edit/delete, chart theo ngày, user growth hoặc change-password/profile bio. Một control chỉ có mặt khi spec có hành vi và backend thực hiện được. Nếu chỉ có thiết kế nhưng chưa có chức năng, chưa coi là xong; không gắn `href="#"` hoặc fake toast để tạo cảm giác đã chạy.

Đây là giới hạn của MVP hiện hành, không cấm chủ dự án yêu cầu tính năng mới sau này. Khi có yêu cầu mới, cập nhật spec/dữ liệu trước UI; UI-DATA-01/UI-COPY-01 tiếp tục áp dụng.

## 5. Quy tắc kỹ thuật và hình thức

### UI-TECH-01

- View chỉ dưới `/WEB-INF/views/`, CSS/JS/asset đúng thư mục assets.
- Zero scriptlet, dynamic DB/user text escape bằng JSTL, URL validate và escape đúng ngữ cảnh.
- Không thêm runtime Tailwind CDN/inline config vào bản Ant chỉ vì nguồn mẫu có CDN; palette/type được chuyển thành CSS local.
- Component dùng tokens/design.md; không tạo theme admin khác hoặc sửa palette theo một lần skill draw mới.
- Icon/label/keyboard/focus/reduced-motion theo design; không dùng hover-only làm đường thao tác duy nhất.
- Static business content không được giấu trong CSS content:, background-image URL theo tên phim, fallback avatar URL hoặc JS dataset.
- Mọi control mutation dùng method/CSRF/role đúng spec; ẩn nút không thay guard server.

### UI-CHANGE-01: duy trì một nguồn chuẩn

Agent bắt đầu công việc đọc AGENTS.md →ui_rule.md →design.md →spec/shared contracts liên quan. Mọi thay đổi token/component chung phải cập nhật design.md và kiểm tra trang ảnh hưởng, không chữa riêng từng trang. Không tự nới hai điều cấm chính vì thiếu dữ liệu, deadline, screenshot hoặc đề xuất của skill.

Quyết định nguồn và các mã rule tồn tại trong docs để agent/reviewer truy vết, không in vào sản phẩm. Chỉ yêu cầu trực tiếp mới của chủ dự án mới thay đổi chính sách này; lựa chọn triển khai thường nhật tiếp tục tự xử lý trong phạm vi đã giao.

## 6. Khai báo nguồn dữ liệu khi giao việc

Trước khi code một trang, ghi trong plan/PR hoặc báo cáo developer bảng gồm: block/field hiển thị, entity/query/service cấp dữ liệu, thuộc tính DTO, predicate quyền/status, trạng thái empty/error và định dạng. Không đưa bảng này vào JSP dưới dạng panel debug.

Ví dụ tên thuộc tính minh họa, không tự thay hợp đồng module:

| Block | Data lineage | Trạng thái không có dữ liệu |
|---|---|---|
| Tên phim detail | Movies.title→MovieService→detail DTO | Phim không public/không có→404 |
| Điểm phim | Reviews đủ điều kiện→aggregate service→rating summary | count0→“Chưa đánh giá” |
| Thể loại menu | Categories chưa deleted→category DTO list | Không có→không tạo link giả |
| Hàng chờ | Review/Question/Answer→ModerationService→page DTO | Empty đúng bộ lọc |
| Tổng lượt xem | Movies.view_count→aggregate→dashboard DTO | Tập rỗng SUM0; query lỗi→error |

Không ghi “data từ backend” chung chung: một list hardcode trong backend vẫn vi phạm. Người review phải truy được từ giá trị hiển thị tới truy vấn DB hoặc ngoại lệ UI tĩnh tại UI-DATA-03.

## 7. Kiểm chứng bắt buộc khi triển khai

### Checklist của mỗi màn hình

- [ ] UI-CHK-01: Đọc design/ui_rule/spec và xác định nguồn từng business field.
- [ ] UI-CHK-02: Không business records cố định trong view/JS/CSS/JSON hoặc fallback ở Java.
- [ ] UI-CHK-03: Đổi dữ liệu fixture trong DB rồi reload, đúng dữ liệu mới xuất hiện mà không sửa source; ghi bằng chứng và cấu hình cache nếu có.
- [ ] UI-CHK-04: DB rỗng hiện empty; DB lỗi hiện error, không mock/zero giả.
- [ ] UI-CHK-05: Public không lộ phim/nội dung ẩn; private chỉ đúng actor, role thay đổi được phản ánh theo spec.
- [ ] UI-CHK-06: Count/rating/paging/KPI khớp query và cùng predicate; không tính từ mẫu hoặc số item trang hiện tại.
- [ ] UI-CHK-07: Không product-generated Business Rules/BR/FR/UC/NFR/stack/SQL trong text, tooltip, aria hoặc hidden template block.
- [ ] UI-CHK-08: Nhãn/hint/error nói việc người dùng cần biết, không giải thích thuật toán/constraint.
- [ ] UI-CHK-09: Không control ngoài scope hoặc nút/link không thực hiện tác vụ.
- [ ] UI-CHK-10: Submit chỉ báo thành công sau commit và phản ánh state DB thật.
- [ ] UI-CHK-11: Kiểm tra ảnh lỗi, media lỗi,0 rating, title/content dài và Unicode tiếng Việt.
- [ ] UI-CHK-12: Screenshot desktop/tablet/mobile, keyboard/focus và reduced motion được kiểm tra.
- [ ] UI-CHK-13: Route/context path, JSP escaping, CSRF/role/ownership và không lộ secret được xác nhận.
- [ ] UI-CHK-14: Browser console/network không có fallback mock, lỗi font/CDN hoặc placeholder copy sai nghĩa.
- [ ] UI-CHK-15: Báo cáo nêu trang đã kiểm tra, DB fixture, commit/lệnh/bằng chứng và phần chưa chạy.

Checklist này là cổng nghiệm thu UI, chưa mục nào được coi là pass chỉ từ việc soạn tài liệu. Khi dữ liệu/rules sai, đó là lỗi chặn bàn giao kể cả screenshot đẹp.

### Tìm dấu hiệu vi phạm

Dùng rg hoặc công cụ source scan phù hợp để tìm chuỗi mẫu, array records, mock fallback, số KPI cố định và tech copy trong template/JS. Sau đó kiểm tra DOM/browser text và accessible names. Chỉ quét source chưa chứng minh runtime lấy DB; một literal code có thể nằm trong comment, nhãn enum hoặc user content hợp lệ nên phải phân loại bằng ngữ cảnh.

Không dùng regex tự xóa từ khóa để “làm sạch” UI vì có thể phá dữ liệu người dùng hoặc bỏ mất label hữu ích. Sửa nguồn product copy hoặc đường dữ liệu gây vi phạm. Không cần viết thêm unit test chỉ để khẳng định một chuỗi tĩnh trong docs; ưu tiên integration/browser check cho nguồn DB và quyền thực.

## 8. Báo cáo và mức độ vi phạm

| Mức | Trường hợp | Xử lý |
|---|---|---|
| Chặn bàn giao | Business data hardcode/mock fallback; UI tài liệu nghiệp vụ; lộ private/secret; fake success | Sửa trước khi báo hoàn tất |
| Chặn visual acceptance | Sai token/layout; overflow; keyboard không dùng được; media/control giả | Sửa và chụp lại bằng chứng |
| Cần ghi rõ | DB/backend chưa có, font/asset chưa cung cấp, scenario chưa chạy | Báo trạng thái thật; không thay bằng dữ liệu/claim giả |

Báo cáo cho chủ dự án có thể dùng thuật ngữ kỹ thuật khi cần giải thích công việc. Điều cấm UI-COPY-01 áp dụng lên giao diện sản phẩm, không cấm docs/PR/log kỹ thuật an toàn hoặc câu trả lời developer.
