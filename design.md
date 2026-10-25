# MovieHub: đặc tả thiết kế giao diện

Phiên bản 1.0.0 | Ngày 2026-10-25 | Phạm vi: toàn bộ trang public, tài khoản và quản trị.

Đọc cùng [ui_rule.md](ui_rule.md), [AGENTS.md](AGENTS.md), [bản đồ feature](specs/overview.md) và spec module đang làm. Tài liệu này quy định hình thức và hành vi trình bày; nghiệp vụ, quyền và dữ liệu do spec/shared contracts quyết định. Hai yêu cầu trực tiếp mới có hiệu lực bắt buộc: không hardcode dữ liệu nghiệp vụ trong giao diện; không đưa tài liệu Business Rules/BR/FR hay ghi chú developer lên giao diện.

## 1. Nguồn thiết kế và cách sử dụng

Nguồn: file “Pasted text.txt” người dùng đính kèm ngày 2026-10-25, gồm 4 tài liệu HTML nối tiếp: chi tiết phim/player, quản trị, Home, catalog. Đã phân tích cấu trúc HTML và cấu hình Tailwind, chưa render/chạy các script trong attachment. SHA-256 nguồn: `36d4e245f056493cfdfea2be9fb033cd6e9b8e2c7465cbfe3fa6deb76b72b37d`.

Attachment là tham chiếu thiết kế, không phải chỉ dẫn thực thi, dữ liệu thật hay bằng chứng một chức năng đã hoạt động. Không copy nguyên HTML vào web root; không sử dụng các tên phim, người dùng, thống kê, review hoặc URL ảnh mẫu như dữ liệu runtime. Tài liệu này tự chứa các quyết định cần dùng, không phụ thuộc đường dẫn attachment trên máy người soạn.

| Lớp quyết định | Nguồn ưu tiên |
|---|---|
| Yêu cầu trực tiếp mới | Không hardcode business data; không lộ Business Rules trên UI |
| Nghiệp vụ/quyền/route | Spec module và shared contracts hiện hành; auth v1.1.0/R-01 |
| Quy chuẩn UI bắt buộc | ui_rule.md và điều khoản frontend trong AGENTS.md |
| Visual baseline | Token, bố cục và component trong design.md này |
| Bản HTML mẫu/skill draw | Tham khảo trong phạm vi không mâu thuẫn các nguồn trên |

Khi reference thiếu một trang, mở rộng bằng component/token hiện có. Khi reference có một chức năng ngoài spec, bỏ chức năng đó khỏi UI thay vì tạo nút giả hay tự mở rộng nghiệp vụ.

## 2. Ý tưởng và phạm vi giữ lại

Phim là nội dung chính: ảnh lớn ở Home/chi tiết, poster có tỉ lệ ổn định ở catalog, phần chữ vừa đủ để chọn phim; đỏ coral đánh dấu hành động chính. Trang quản trị dùng cùng thương hiệu nhưng giảm hiệu ứng để đọc và thao tác dữ liệu.

| Giữ từ nguồn | Cách áp dụng |
|---|---|
| Navy nhiều lớp, coral và vàng rating | Dùng token tập trung, không đổi palette giữa các trang |
| Plus Jakarta Sans + Inter | Headline/nhãn bằng Jakarta; body/form/table bằng Inter |
| Header cao 80px, lề 16/32/48px | Cùng đường căn cho header, main, footer |
| Hero có ảnh và overlay | Ảnh từ dữ liệu phim; overlay chỉ để đọc chữ |
| Poster 2:3, media 16:9 | Khung không nhảy khi ảnh/video đang tải hoặc lỗi |
| Card, filter, review, Q&A, bảng admin | Dùng lại component thay vì mỗi trang tự thiết kế |
| Badge trạng thái và tương tác | Trạng thái thật từ server, có text ngoài màu sắc |

### Các phần trong mẫu phải đổi hoặc loại bỏ

| Trong reference | Quyết định cho dự án |
|---|---|
| Hệ Thống BR-24, FR-17 Kho số liệu, BR-23 SLA, Audit compliance | Không render; thay bằng nhãn sản phẩm ngắn khi thật sự cần, ví dụ “Tổng phim”, “Chờ duyệt” |
| Footer PRJ301/Ant/Tomcat/SQL Server, đoạn quảng bá kiến trúc | Không hiển thị trên sản phẩm; thông tin triển khai ở docs |
| User mẫu và Admin link hiện đồng thời | Render theo user/role thật đã được guard |
| Điểm 8.9/10 xen 4.8/5 | Toàn hệ thống dùng thang 1–5 theo spec, hiển thị 1 số lẻ |
| Xem nhiều tuần này, tăng trưởng +18% | Chỉ “Xem nhiều”; không có event theo tuần thì không đặt nhãn theo tuần hoặc % tăng trưởng |
| 4K/HDR/IMAX/Dolby, nhiều server, timeline 84% | Không có dữ liệu/chức năng xác nhận thì bỏ. Progress/time lấy từ media đang phát thật |
| Cast/director/production country/age rating | Chưa có schema/spec trong MVP, không dựng thêm block hoặc filter |
| Notification, Audit Log, Share, Report, Like, Bulk actions | Bỏ nếu chưa được spec; không có nút mở modal giả hoặc không phản hồi |
| Dropdown chỉ mở bằng hover, scrollbar bị ẩn toàn trang | Có click/keyboard/touch; giữ khả năng nhận biết và sử dụng vùng cuộn |
| href="#", data-path nội bộ của công cụ mockup | Route/context path thật; anchor chỉ dùng khi có đích trong trang |
| Tailwind CDN và inline config/style rải rác | Chuyển thành CSS/JS local theo mục 13, không phụ thuộc CDN runtime |
| Văn bản sai entity/ký tự như &Dstilde | Dùng tiếng Việt UTF-8 chuẩn; không sửa dữ liệu gốc bằng chuỗi thay thế trong view |

## 3. Hệ màu

Mã màu lấy từ cấu hình được lặp trong cả 4 HTML. Đây là hằng số thiết kế, được phép có trong CSS; không phải dữ liệu nghiệp vụ. Chỉ đặt tại lớp token, component tham chiếu token.

| Token chuẩn | Giá trị | Vai trò |
|---|---|---|
| --mh-bg | #0f131d | Nền trang |
| --mh-surface-lowest | #0a0e18 | Header nền sâu, player, vùng tối ảnh |
| --mh-surface-low | #171b26 | Input, panel nhẹ |
| --mh-surface | #1c1f2a | Card/panel chính |
| --mh-surface-high | #262a35 | Menu nổi, hover panel |
| --mh-surface-highest | #313540 | Trạng thái active nhẹ, track control |
| --mh-surface-bright | #353944 | Nền nổi khi thật sự cần |
| --mh-text | #dfe2f1 | Chữ chính |
| --mh-text-muted | #e4bebc | Metadata/nhãn phụ; không tiếp tục giảm opacity tới khó đọc |
| --mh-accent | #ff535b | Nền hành động chính |
| --mh-on-accent | #5b000e | Chữ/icon trên nền coral |
| --mh-accent-soft | #ffb3b1 | Link/focus/chữ nhấn trên nền tối |
| --mh-accent-hover | #ffb3b1 | Nền primary hover, giữ chữ sẫm |
| --mh-rating | #fbb400 | Sao/rating thật |
| --mh-on-rating | #694900 | Chữ trên badge vàng |
| --mh-rating-text | #ffd795 | Rating text trên nền tối |
| --mh-outline | #ab8987 | Viền cần nhận biết rõ |
| --mh-control-border | #ab8987 | Viền input/select/control trên nền tối, alias cùng màu outline |
| --mh-outline-subtle | #5b403f | Đường chia/panel trang trí, không dùng làm viền duy nhất nhận biết input |
| --mh-error | #ffb4ab | Lỗi trên nền tối |
| --mh-error-bg | #93000a | Vùng lỗi có nền |
| --mh-on-error-bg | #ffdad6 | Chữ trên nền lỗi |
| --mh-disabled-opacity | 0.45 | Control disabled, không áp vào text nội dung bình thường |

Không lấy #E63946 rải rác trong một vài button admin của mẫu làm accent thứ hai; dùng coral thống nhất. Không thêm neon cyan/purple/gradient nhiều màu chỉ vì trang có khoảng trống.

Các cặp đặc tính được tính từ màu solid: text/background khoảng14.40:1; muted/surface-low10.15:1; on-accent/accent4.58:1; on-rating/rating4.55:1. Chữ trắng trên coral chỉ khoảng3.16:1 nên không dùng cho chữ nhỏ. Kiểm tra lại màu sau opacity/overlay/focus thực tế; số này không thay thế kiểm tra screenshot.

```css
:root {
  color-scheme: dark;
  --mh-bg: #0f131d;
  --mh-surface-lowest: #0a0e18;
  --mh-surface-low: #171b26;
  --mh-surface: #1c1f2a;
  --mh-surface-high: #262a35;
  --mh-text: #dfe2f1;
  --mh-text-muted: #e4bebc;
  --mh-accent: #ff535b;
  --mh-on-accent: #5b000e;
  --mh-accent-soft: #ffb3b1;
  --mh-rating: #fbb400;
  --mh-outline-subtle: #5b403f;
}
```

Đây là đoạn minh họa token cho CSS sau này, không phải file stylesheet đã được triển khai. Khi lập tokens.css phải đủ các token trong bảng, không chỉ đoạn rút gọn trên.

## 4. Chữ và ngôn ngữ

| Vai trò | Font | Desktop size/line-height | Mobile | Weight |
|---|---|---|---|---|
| Hero title | Plus Jakarta Sans | 56/64px | 36/44px | 800 |
| H1 trang/detail | Plus Jakarta Sans | 32/40px | 24/32px | 700 |
| H2 section | Plus Jakarta Sans | 22/28px | 22/28px | 600–700 |
| H3/card title | Plus Jakarta Sans | 18/24px | 16/22px | 600 |
| Body mô tả chính | Inter | 16/26px | 16/26px | 400 |
| Body/form/table | Inter | 14/22px | 14/22px; input16px | 400–500 |
| Button/label | Plus Jakarta Sans | 14/20px | 14/20px | 600 |
| Metadata/badge | Inter/Jakarta theo vai trò | 13/18px | 13/18px | 500–600 |
| KPI value | Inter | 28/34px | 24/30px | 500–600 |

Nguồn có nhãn11–12px; baseline tăng lên13px để dễ đọc. Không dùng monospace làm font dashboard chung; bảng số dùng font-variant-numeric: tabular-nums. Số căn phải, cùng số chữ số thập phân theo spec.

Tiếng Việt sentence case: “Phim mới cập nhật”, “Đã lưu”, “Tạo phim”, “Chờ duyệt”. Không Title Case mọi từ hoặc tracking rộng trên cả câu. Uppercase chỉ khi cần giữ nguyên mã trạng thái trong vùng quản trị; ưu tiên nhãn tiếng Việt với enum thật làm giá trị server.

Hero headline mục tiêu2 dòng với dữ liệu thông thường, nhưng title phim dài được xuống dòng và tăng chiều cao; không cắt mất tên ở detail. Card được clamp2 dòng và có tên đầy đủ trong accessible link; không dùng tooltip là cách duy nhất đọc tên trên mobile. Nội dung dài dùng overflow-wrap, không làm tràn viewport.

Font fallback: Jakarta → system-ui,sans-serif; Inter → system-ui,sans-serif. Chỉ dùng font file có nguồn/license phù hợp, ưu tiên local với font-display:swap. Không tuyên bố font đã tải đúng nếu chưa kiểm tra computed font thực tế; fallback không được làm vỡ layout.

## 5. Khoảng cách, kích thước và lớp

Spacing scale theo reference: 4,8,12,16,24,32,40,48,64px. Không thêm những giá trị chỉ để chữa lệch một trang nếu có thể dùng scale chung.

| Thành phần | Quy định |
|---|---|
| Lề ngoài | <768px:16px; 768–1023:32px; ≥1024:48px |
| Bề rộng khung | Nội dung tối đa1440px, căn giữa; lề hai bên bằng nhau |
| Gap poster | Mobile12px, tablet/desktop24px |
| Section gap | Public48–64px; admin24–32px |
| Padding panel/form | Mobile16px; desktop24px |
| Button/input chuẩn | Cao44px; admin compact40px nếu không làm touch target nhỏ hơn44px |
| Icon button | Vùng bấm44×44px, icon20–24px |
| Radius | Input/button8px; card/menu12px; player/hero16px; pill/avatar9999px |
| Dialog | Max-width560px; form dài640px; mobile rộng viewport trừ32px |
| Viền | Input/select1px control-border; table/panel có thể dùng outline-subtle cho separator; không trang trí viền mọi section |
| Z-index | Base0, sticky filter10, header40, menu50, overlay90, dialog100, toast110 |

Public được dùng shadow cho menu nổi/player và overlay ảnh giúp đọc chữ. Admin panel nằm phẳng, phân lớp bằng màu nền/đường chia, không glow/shadow lớn. Không backdrop blur cho toàn bộ nội dung; header có thể blur nhẹ với nền đủ đục khi không hỗ trợ.

## 6. Responsive và shell chung

| Viewport | Poster grid | Điều hướng/filter | Admin |
|---|---|---|---|
| 320–767px | 2 cột | Menu sheet; search riêng trong menu/toolbar; filter stack | Nav sheet; panel1 cột, bảng cuộn trong vùng |
| 768–1023px | 3 cột | Search hiện; filter2 cột | KPI2 cột khi đủ, không ép6 card |
| 1024–1279px | 5 cột | Thanh search + menu gọn; không ép toàn navbar | Module switcher gọn, table đủ rộng |
| ≥1280px | 5 cột | Navbar đầy đủ khi không va search/user | Nội dung phẳng, lưới KPI tối đa3 cột nếu nhãn dài |

Header cao80px theo nguồn; main có offset đúng80px nếu fixed. Không thêm thanh trạng thái giả ở trên làm sai offset. Mobile cũng dùng80px để đồng nhất, không tự đổi header height một trang. Khi zoom/text lớn, header được chuyển composition thay vì tràn hoặc cắt nút menu.

Header public: MovieHub/brand, Home, Khám phá, Thể loại lấy DB, Favorites khi login, tài khoản. Navbar search là FR-25/P1: chỉ bật khi phần P1 được chọn triển khai; mọi mô tả search ở bảng responsive áp dụng khi nó đã bật. Nếu chưa làm P1 thì dùng link “Khám phá phim”, chức năng tìm/lọc P0 vẫn ở catalog; không tạo ô search không hoạt động để giống reference. Admin link chỉ Admin ACTIVE. Guest thấy “Đăng nhập”, “Đăng ký”; không thấy avatar/tên mẫu. Dropdown mở bằng click/keyboard, Escape đóng, trả focus về trigger; hover chỉ hỗ trợ thêm.

Header admin vẫn nhận diện MovieHub; module nav dẫn Dashboard/Phim/Thể loại/Người dùng/Duyệt nội dung và link về public. Reference dùng module switcher; baseline giữ switcher trên desktop và menu sheet trên mobile, không buộc thêm một sidebar thứ hai. Active route có aria-current, không chỉ đổi màu.

Footer tối giản: thương hiệu, điều hướng thật nếu có, copyright year từ server clock. Không có tech badges, số user/review viết sẵn, tuyên bố 4K/bản quyền chưa chứng minh hoặc đoạn “Business Rules”. Không tạo dead links “Privacy/Terms/Help” khi chưa có trang.

## 7. Quy chuẩn component

### 7.1 Button và form control

Primary coral/on-accent chỉ cho hành động chính trong vùng nhìn; secondary nền surface/viền nhẹ; tertiary là text action. Destructive cần nhãn cụ thể, không tái sử dụng “OK” cho cả Ẩn/Khóa/Xóa. Hover đổi tone, focus outline2px accent-soft offset2px; pressed có phản hồi ngắn; disabled có thuộc tính disabled và lý do cần thiết bằng ngôn ngữ người dùng.

Label luôn nhìn thấy, input có id/label, hint chỉ khi giúp thao tác. Input/select chưa focus phải có đường viền nhận biết rõ: dùng control-border, không chỉ surface-low gần trùng nền hoặc outline-subtle. Error cạnh field + aria-describedby/aria-invalid; khi submit lỗi focus lỗi đầu hoặc summary liên kết field. Không dùng placeholder thay label. Password không render lại value sau lỗi. Chờ submit: disable nút chống click lặp, nhãn “Đang lưu…”; server vẫn chịu trách nhiệm idempotency/transaction.

### 7.2 Poster card

Poster2:3, object-fit:cover; ảnh/alt/title từ cùng movie. Image placeholder trung tính local khi URL rỗng/lỗi, không thay bằng poster phim khác. Card có title,year,rating khi có; thể loại chỉ nếu có payload từ DB. Không chồng hơn2 badge hữu ích. Card link đến detail ID server, nút favorite tách vùng bấm khỏi link, accessible name có tên phim.

Hover nâng hoặc scale ảnh tối đa1.03, không dịch layout/đổi kích thước card. CTA không chỉ xuất hiện khi hover trên touch; nội dung/tác vụ chính vẫn có link/nút truy cập được. Không gắn “4K”, “Mới”, “Hot” theo index card hoặc tên phim cố định.

### 7.3 Badge và trạng thái

Guest/public: trạng thái cá nhân “Đã lưu”, “Chờ duyệt”, “Chưa đánh giá” dùng dữ liệu hiện hành. Admin: DRAFT→“Bản nháp”, PUBLISHED→“Công khai”, HIDDEN→“Đã ẩn”; ACTIVE→“Hoạt động”, INACTIVE→“Đã khóa”; PENDING→“Chờ duyệt”, APPROVED→“Đã duyệt”, REJECTED→“Từ chối”. Mapping là nhãn UI, không tự tạo enum mới.

Không đổi nghĩa màu theo trang. PUBLISHED/APPROVED có thể dùng accent-soft nhẹ với text; PENDING dùng vàng có label; HIDDEN/INACTIVE dùng muted; REJECTED/error dùng error. Không phát sáng/pulse liên tục; một nhãn vai trò ADMIN không được dùng thay guard server.

### 7.4 Pagination

Server cấp currentPage,totalPages,totalCount và query đã chuẩn hóa. UI render page links, previous/next đúng đích, aria-current cho trang hiện tại, không biến disabled thành href="#". 10 item/trang là nghiệp vụ, không đóng đinh10 card giả trong DOM. Khi dataset rỗng giữ empty state, không tạo số trang1…99.

### 7.5 Dialog/toast/menu

Xác nhận trước ẩn phim/khóa user/hạ role theo spec; dialog nói rõ đối tượng từ DB và hành động, không giải thích BR/FK/transaction. Focus trap, Escape hủy, có nút hủy, khôi phục focus. Toast chỉ sau server xác nhận thành công, role=status; lỗi quan trọng ở trong form, không tự biến mất trước khi đọc.

## 8. Blueprint các trang public

### 8.1 Home

Thứ tự: header → hero1 phim featured → category links DB → mới cập nhật → xem nhiều → điểm cao →footer. Hero ảnh phủ có overlay tối trái/dưới, title và synopsis căn trái, một CTA “Xem chi tiết” hoặc “Xem trailer” chỉ khi có media hợp lệ; nếu CTA mở detail thì dùng đúng nhãn/đích. Dữ liệu featured/section có thể lặp cùng phim theo spec.

Không featured thì bỏ hero phim, dùng tiêu đề khám phá và link catalog, không dựng featured cố định. Mỗi section giới hạn theo003, desktop5 poster/hàng; nhiều hơn5 thì hàng tiếp hoặc link catalog, không random slider. Không dựng showcase “năng lực kiến trúc PRJ301” ở cuối trang. Không có phim public thì empty toàn trang, không làm đủ số ảnh bằng mẫu.

### 8.2 Catalog

Tiêu đề “Khám phá phim” →toolbar q/category/year/sort →active filters/count →poster grid →pagination. Search placeholder “Tìm tên phim”, không nhắc đạo diễn. Category và year options từ DB theo003. Sort có nhãn dễ hiểu: “Mới cập nhật”, “Lượt xem”, “Đánh giá”, “Tên phim”. Reset filter là link GET catalog mặc định.

Active chips chỉ phản ánh query đang áp dụng; remove chip giữ điều kiện khác và page=1. 10/trang = hai hàng5 trên desktop khi có đủ10 dữ liệu; trang cuối ít item giữ card width theo grid. Không stretch2 card thành hai banner khổng lồ.

### 8.3 Detail và player

Thứ tự chuẩn: breadcrumb nếu bật P1 →player →metadata/poster/actions →synopsis →review →Q&A →similar →footer. Player là điểm nhìn lớn đầu trang; metadata grid desktop12 phần, poster/actions4 và nội dung8, gap24; mobile1 cột, poster không chiếm hết chiều cao màn trước nội dung.

Khung media aspect-ratio16/9, width100%; video object-fit:contain, nền deepest; không chép max-height640px từ mẫu theo cách ép méo aspect trên container lớn. Native HTML5 controls là baseline. Custom controls chỉ khi đọc currentTime/duration/paused/volume/buffered thật và đủ keyboard; không thanh84%, thời lượng mẫu, server2, chất lượng giả hay nút play chỉ đổi icon.

Poster2:3. Title đầy đủ; year,duration,categories,viewCount,avg/reviewCount từ DTO hiện hành. Description plain text escape, giữ xuống dòng phù hợp. Không có director/cast/spec-sheet chưa được schema cấp. Favorite state từ actor/movie thật; Guest có CTA login, Admin public cũng không thấy phim ẩn. Lượt xem không tăng do animation hoặc bấm play, theo SYS-07.

Nếu không có video/trailer: vùng “Chưa có video”, không play overlay khả dụng. Nếu media lỗi: thông báo và fallback trailer thật nếu có; không loop reload hoặc thay clip ngẫu nhiên. Similar tối đa6 theo003; không dùng một hàng cố định tên phim trong reference.

### 8.4 Review và Q&A

Review: summary avg1–5 +countpublic, form rating/content theo quyền, list approved10/trang; own review PENDING/REJECTED ở vùng riêng. Empty “Chưa có đánh giá”, không có sao trung bình5.0 giả. Star selector là input thật có nhãn, keyboard, value thuộc domain; không tự gửi hoặc thành công khi chưa nhận server response.

Q&A: header +nút/form đặt câu hỏi theo quyền, list public, mở answers một question theo006, private “Nội dung tôi gửi” chỉ của actor. Empty không có tên người/nội dung mẫu. Không accepted/best answer, like/report/collapse có dữ liệu giả. Trạng thái “Chờ duyệt” được phép vì giúp người dùng theo dõi nội dung; không kèm bảng chính sách hoặc câu “theo BR-12”.

### 8.5 Favorites

Tiêu đề “Phim yêu thích”, count từ cùng predicate với list, poster grid, nút “Bỏ yêu thích”, pagination. Chỉ phim public của actor. Nếu hết dữ liệu hiện lời mời khám phá catalog, không lấp card từ Home. Bỏ item cuối trang quay lại trang hợp lệ theo server; không giữ badge count cũ trong header.

## 9. Trang tài khoản và lỗi

Auth dùng shell tối giản cùng palette/type, brand link, form width440px, không sidebar marketing/dữ liệu minh họa. Field label16/14 rõ, lỗi cụ thể, password visibility button keyboard dùng được. Không prefill tài khoản/password demo.

Register/login theo001. Forgot theo R-01: email →form password/confirm →login, không email sent page, OTP hoặc countdown15 phút. UI không in đoạn mô tả rủi ro/kiến trúc/contextVersion; đây là nội dung docs. flowVersion/CSRF là field kỹ thuật ẩn cần thiết, không thành nhãn sản phẩm. Không tự tạo bước xác thực mới.

Profile: avatar/placeholder, tên sửa được, email read-only, ngày tham gia; dữ liệu actor từ DB. Không thêm bio/đổi password/đổi email/activity timeline ngoài002.

403/404/500: cùng shell, H1 dễ hiểu, một lời giải thích và link Home/catalog. 500 có mã tra cứu opaque nếu server cấp, không SQL/stacktrace/FK/EntityManager. Giữ HTTP status, không redirect lỗi thành200 để “trang đẹp”.

## 10. Blueprint quản trị

Admin tách công việc qua module nav; không dồn dashboard +toàn bộ CRUD +mọi queue thành một trang dài chỉ vì mẫu chứa cả ba section. Hero marketing bị loại bỏ; H1 24–32px, một action chính phù hợp màn hình.

### Dashboard

KPI theo008, panel phẳng, nhãn người dùng như “Tổng phim”, “Phim công khai”, “Người dùng”, “Tổng lượt xem”, “Điểm trung bình”, “Chờ duyệt”. Không nhãn COUNT/SUM/AVG/MAX/MIN/BR-24 trên tile; công thức nằm docs. Caption “Mọi phim, gồm phim ẩn” được phép vì giúp hiểu số liệu, không phải bài giảng nghiệp vụ.

Grid desktop tối đa3 cột có khoảng cách24px, tablet2,mobile1; không ép6 tile hẹp gây cắt số. Top5 bảng cùng status/link admin. Không growth sparkline, date picker 7/30ngày hay SLA2h do DB hiện không có nghĩa đó. P1 category chart chỉ sau spec cho phép và lấy DB thật.

### Phim/thể loại/người dùng

Toolbar tên mục +search/filter +action tạo đúng phạm vi; table header nhỏ vừa đọc, không uppercase tracking dài. Row phim có poster40×60,title,year,status,views và tác vụ được spec; số căn phải/tabular. Không checkbox bulk/select-all khi không có nghiệp vụ bulk. Mỗi action icon có tên truy cập được, không title chứa FR/BR.

Form group theo nội dung: thông tin chính →poster/media →category/publish. Không show field chỉ để giống mockup nếu schema chưa có. Status/category thực nhận từ server; group readonly/server-managed không cho user gán ID/viewCount.

User list không lộ password/hash/reset context, không tự tạo account Admin mẫu. Tên/email/avatar/status lấy DB; nút khóa/hạ role theo quyền server, dialog ngôn ngữ tác vụ; lỗi409 đề nghị tải lại, không show tên invariant hay số BR.

### Moderation

Filter loại/trạng thái, list oldest-first theo007, mỗi item có tác giả/context/content/rating thật, nút “Duyệt” và “Từ chối”. Có trạng thái cha “Phim hiện không công khai” để giải thích nút không khả dụng; không block “BR-23 Compliance”, SLA giả hoặc developer audit notice.

Moderator/time có thể hiện như thông tin quyết định hiện hành khi view model cung cấp; dữ liệu chỉ giữ người/thời gian của quyết định hiện tại, không gọi đó là lịch sử đầy đủ. Không làm trang Audit Log hoặc timeline quyết định ngoài scope. Action chỉ thành công sau commit; stale form409 giữ nội dung hiện hành và cho tải lại.

## 11. Empty, loading, error và dữ liệu dài

| Trạng thái | Cách thể hiện |
|---|---|
| DB truy vấn thành công,0 phim | Empty phù hợp màn hình, link catalog/reset filter nếu có ích |
| DB unavailable/query lỗi | Error đúng status, không chuyển thành0 và không chèn seed từ view |
| Đang gửi form | Nút disabled/nhãn đang gửi; không in số liệu tạm như dữ liệu đã lưu |
| Ảnh thiếu/lỗi | Placeholder local trung tính, giữ2:3 hoặc khung avatar, alt đúng |
| Chưa có rating | “Chưa đánh giá”, không0 sao/5 sao mặc định |
| Aggregate null | Theo008: SUM0 khi tập rỗng, AVG/MAX/MIN N/A tương ứng |
| Text dài/tên200ký tự | Wrap/clamp theo vai trò, không overflow hoặc đẩy action ra ngoài |
| Không đủ ảnh cho hero | Layout text hợp lệ hoặc placeholder, không lấy ảnh phim khác làm dữ liệu |

Skeleton chỉ nếu thật sự có tải bất đồng bộ; shape placeholder không chứa tên/count giả và phải được thay bằng dữ liệu thật hoặc error/empty. Server-render bình thường không chèn spinner/skeleton giả để khoe hiệu ứng.

## 12. Accessibility và motion

Toàn bộ thao tác dùng keyboard, focus thấy rõ, menu/dialog đúng focus management. Nút có accessible name kể cả icon-only. Không nested button trong anchor; landmark header/nav/main/footer, một H1, heading order hợp lý. Contrast chữ thường≥4.5:1, chữ lớn≥3:1; trạng thái không chỉ dựa màu. Ranh giới hoặc dấu hiệu cần để nhận biết control đang hoạt động phải đạt≥3:1 với màu kề theo [hướng dẫn non-text contrast của W3C](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html). Đường chia chỉ trang trí có thể dùng subtle; không áp dụng ngoại lệ đó cho input trống/select/icon thao tác.

Hover/focus120–180ms, menu/dialog160–220ms, ảnh hover≤300ms; transform/opacity ưu tiên. Không pulse badge/sao/counter liên tục, marquee/poster tự chạy hoặc scroll hijack. prefers-reduced-motion bỏ chuyển động không thiết yếu, vẫn giữ trạng thái cuối. Không autoplay có tiếng. Không ẩn scrollbar toàn trang như source.

Kiểm tra tại320,375/390,768,1366/1440px và zoom200%; không horizontal scroll toàn trang. Bảng admin có vùng cuộn riêng có tên, header/action vẫn tiếp cận; nhãn/câu lỗi không nhỏ đi để ép vừa.

## 13. Chuyển thành JSP/CSS/JS

View dưới WEB-INF/views, static asset dưới assets/css, assets/js, assets/img hoặc assets/fonts. Không scriptlet/SQL/JPA tại JSP. Stylesheet đề nghị: tokens.css,base.css,components.css,public.css,admin.css; đây là tên định hướng, chưa phải file đã tạo. Khi repo có file tương đương thì mở rộng nó thay vì tạo hệ CSS cạnh tranh.

Class namespace mh-, component modifier rõ; JS hook bằng data-action/id, không phụ thuộc chuỗi utility có thể đổi. Không inline color/spacing rải rác. Không Tailwind CDN runtime hoặc script config CDN từ reference; dùng CSS local thuần phù hợp Ant hiện có, không tự chuyển stack/bổ sung npm build.

Icon một hệ outline: ưu tiên SVG local hoặc font icon đã được duyệt, accessible name riêng; không ghép emoji/multiple packs. Logo/icon/placeholder là asset tĩnh được phép; poster/avatar/video của thực thể phải có tham chiếu từ DB, không mapping URL theo title/id trong JavaScript.

DB →JPA DAO →Service/DTO →Servlet request attributes →JSTL/EL escaped. Formatted numeric/date chỉ biến đổi biểu diễn, không thay meaning/công thức. Dynamic URL được validate và escape đúng ngữ cảnh. Không truyền dữ liệu vào inline script/style bằng string nối từ DB.

## 14. Kiểm chứng và bàn giao

Trước khi code: đọc design/ui_rule/spec, liệt kê nguồn DB cho mỗi block và loại bỏ component ngoài scope. Khi hoàn thành một màn: kiểm tra dữ liệu bằng thay đổi DB fixture, so screenshot các viewport, kiểm tra empty/error/long text/keyboard, sau đó ghi bằng chứng theo ui_rule.

Đã dùng design-taste-frontend để deal public/admin với palette/type giữ theo reference. Deal đầu có giant wordmark/light admin, bị loại vì mâu thuẫn reference. Đã đổi public sang dark-room và admin theme dark/data-terminal; đây là tham chiếu chất lượng, không thay shell/tokens nguồn bằng bố cục hoặc time-series ngoài spec. Không lấy ảnh architecture/picsum từ deal làm poster hay background phim giả. Generic skill yêu cầu motion/ảnh không được dùng để vượt hai rule dữ liệu/copy của người dùng.

Chưa xây UI trong lần soạn tài liệu này nên chưa có screenshot hoặc kết quả browser/Ant. Khi triển khai phải chạy inspect.mjs phù hợp public/app, review screenshot thật, ghi mọi ngoại lệ có lý do gắn reference; không đánh dấu visual pass chỉ từ lint. Không sửa giao diện chỉ để qua checker nếu làm sai dữ liệu hoặc spec.
