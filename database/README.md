# Hướng Dẫn Cài Đặt & Nạp Dữ Liệu Cơ Sở Dữ Liệu MovieHub

Tài liệu này hướng dẫn cách tạo bảng và nạp bộ dữ liệu mẫu chuẩn điện ảnh cho hệ thống **MovieHub** trên **Microsoft SQL Server**.

---

## 1. Danh Sách Các File SQL Trong Thư Mục `database/`

Các file được đánh số thứ tự từ `01` đến `08`. Bạn có thể chạy tự động bằng script hoặc chạy thủ công từng file qua **SQL Server Management Studio (SSMS)** hoặc công cụ `sqlcmd`.

| Thứ tự | Tên File | Mô Tả Chức Năng |
| :---: | :--- | :--- |
| **01** | [`01_schema.sql`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/database/01_schema.sql) | Tạo CSDL `MovieHub`, 8 bảng nghiệp vụ, ràng buộc toàn vẹn, khóa ngoại và các chỉ mục tối ưu truy vấn. Có thể chạy nhiều lần an toàn (idempotent). |
| **02** | [`02_reset_data.sql`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/database/02_reset_data.sql) | Dọn sạch toàn bộ dữ liệu test / rác theo đúng thứ tự khóa ngoại và reset lại bộ đếm ID (Identity) về 0. |
| **03** | [`03_seed_users.sql`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/database/03_seed_users.sql) | Nạp 20 tài khoản người dùng: 1 quản trị viên (`admin@moviehub.vn`), 17 thành viên hoạt động (`ACTIVE`) và 2 tài khoản bị khóa (`INACTIVE`). Mật khẩu chung: `Password123!`. |
| **04** | [`04_seed_categories.sql`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/database/04_seed_categories.sql) | Nạp 13 thể loại phim (Hành Động, Viễn Tưởng, Phiêu Lưu, Tâm Lý, Kinh Dị, Hoạt Hình, Hài Hước, Tình Cảm, Hình Sự, Giật Gân, Giả Tưởng, Gia Đình, Lịch Sử). |
| **05** | [`05_seed_movies.sql`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/database/05_seed_movies.sql) | Nạp 27 phim điện ảnh (24 phim công khai `PUBLISHED`, 2 phim nháp `DRAFT`, 1 phim ẩn `HIDDEN`) kèm poster chính thức từ TMDB, trailer/clip YouTube độ nét cao và liên kết thể loại. |
| **06** | [`06_seed_favorites.sql`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/database/06_seed_favorites.sql) | Nạp danh sách phim yêu thích liên kết giữa các thành viên và phim công khai. |
| **07** | [`07_seed_reviews.sql`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/database/07_seed_reviews.sql) | Nạp 105 đánh giá chi tiết với đầy đủ các trạng thái `APPROVED` (đã duyệt), `PENDING` (chờ duyệt), `REJECTED` (từ chối). |
| **08** | [`08_seed_qa.sql`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/database/08_seed_qa.sql) | Nạp 28 câu hỏi và 40 câu trả lời cộng đồng với đầy đủ trạng thái `APPROVED`, `PENDING`, `REJECTED`. |

---

## 2. Cách 1: Cài Đặt Tự Động (Khuyến Nghị Cho Khách Hàng)

### Lựa chọn A — Nhấp đúp chạy file Batch (`.bat`):
1. Mở thư mục `database/` trong Windows Explorer.
2. Nhấp đúp chuột vào file [`install.bat`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/database/install.bat).
3. Nhập thông tin kết nối (nhấn `Enter` để nhận giá trị mặc định `localhost`, user `sa`, password `123`).
4. Hệ thống sẽ tự động thực thi tuần tự 8 file và thông báo hoàn tất.

### Lựa chọn B — Chạy bằng PowerShell:
Mở PowerShell tại thư mục gốc và chạy:
```powershell
.\database\install.ps1 -Server "localhost" -Username "sa" -Password "123"
```

---

## 3. Cách 2: Chạy Thủ Công Từng File Trong SQL Server Management Studio (SSMS)

Nếu khách hàng muốn tự chạy từng file trong SSMS:
1. Mở **SQL Server Management Studio (SSMS)** và kết nối tới SQL Server của bạn.
2. Mở và thực thi lần lượt từng file theo đúng thứ tự:
   - **Bước 1**: Mở `01_schema.sql` -> Nhấn **Execute (F5)**.
   - **Bước 2**: Mở `02_reset_data.sql` -> Nhấn **Execute (F5)**.
   - **Bước 3**: Mở `03_seed_users.sql` -> Nhấn **Execute (F5)**.
   - **Bước 4**: Mở `04_seed_categories.sql` -> Nhấn **Execute (F5)**.
   - **Bước 5**: Mở `05_seed_movies.sql` -> Nhấn **Execute (F5)**.
   - **Bước 6**: Mở `06_seed_favorites.sql` -> Nhấn **Execute (F5)**.
   - **Bước 7**: Mở `07_seed_reviews.sql` -> Nhấn **Execute (F5)**.
   - **Bước 8**: Mở `08_seed_qa.sql` -> Nhấn **Execute (F5)**.

> [!IMPORTANT]
> **Quy tắc mã hóa tiếng Việt (Anti-Mojibake):**
> Tất cả các file SQL được lưu dưới định dạng **UTF-8 with BOM / UTF-8**. Khi chạy bằng `sqlcmd`, bắt buộc phải có cờ `-f 65001` để đảm bảo không bị lỗi font tiếng Việt.

---

## 4. Tài Khoản Đăng Nhập Mẫu

Sau khi chạy xong, bạn có thể đăng nhập vào hệ thống bằng các tài khoản sau (Mật khẩu cho tất cả: **`Password123!`**):

| Quyền | Email | Họ và tên | Chức năng kiểm thử |
| :--- | :--- | :--- | :--- |
| **Quản trị viên (ADMIN)** | `admin@moviehub.vn` | Admin MovieHub | Truy cập `/admin/*`, kiểm duyệt review, câu hỏi, quản lý phim, thể loại, phân tích dashboard. |
| **Người dùng (USER)** | `tuan.nguyen@moviehub.vn` | Nguyễn Thanh Tuấn | Xem phim, quản lý danh sách yêu thích, đánh giá phim, đặt câu hỏi. |
| **Người dùng (USER)** | `mai.le@moviehub.vn` | Lê Thị Tuyết Mai | Xem phim, viết bình luận, tương tác hỏi đáp. |
| **Người dùng (USER)** | `duc.tran@moviehub.vn` | Trần Minh Đức | Xem phim khoa học, đánh giá phim. |
| **Bị khóa (INACTIVE)** | `hung.lam@moviehub.vn` | Lâm Quốc Hưng | Kiểm thử chức năng chặn đăng nhập với tài khoản bị khóa. |
