# 🎬 HƯỚNG DẪN CÀI ĐẶT & CHẠY DỰ ÁN MOVIEHUB TRÊN MÁY MỚI

Tài liệu này hướng dẫn chi tiết từng bước (Step-by-step) để thiết lập, cấu hình cơ sở dữ liệu và khởi chạy ứng dụng web **MovieHub** trên một máy tính mới từ file nén ZIP.

---

## 📋 MỤC LỤC
1. [Yêu cầu môi trường & Phần mềm cần cài trước](#1-yêu-cầu-môi-trường--phần-mềm-cần-cài-trước)
2. [Bước 1: Giải nén mã nguồn dự án](#bước-1-giải-nén-mã-nguồn-dự-án)
3. [Bước 2: Cài đặt và nạp Cơ sở Dữ liệu (Microsoft SQL Server)](#bước-2-cài-đặt-và-nạp-cơ-sở-dữ-liệu-microsoft-sql-server)
4. [Bước 3: Cấu hình kết nối CSDL trong mã nguồn](#bước-3-cấu-hình-kết-nối-csdl-trong-mã-nguồn)
5. [Bước 4: Mở dự án trong NetBeans & Cấu hình Tomcat 10.1](#bước-4-mở-dự-án-trong-netbeans--cấu-hình-tomcat-101)
6. [Bước 5: Build và Khởi chạy ứng dụng](#bước-5-build-và-khởi-chạy-ứng-dụng)
7. [Danh sách tài khoản kiểm thử có sẵn](#7-danh-sách-tài-khoản-kiểm-thử-có-sẵn)
8. [Xử lý các lỗi thường gặp (Troubleshooting)](#8-xử-lý-các-lỗi-thường-gặp-troubleshooting)
9. [Lưu ý quan trọng dành cho người đóng gói (ZIP file)](#9-lưu-ý-quan-trọng-dành-cho-người-đóng-gói-zip-file)

---

## 1. Yêu cầu môi trường & Phần mềm cần cài trước

Trước khi bắt đầu, hãy đảm bảo máy tính của bạn đã được cài đặt các phần mềm sau:

| STT | Phần mềm | Phiên bản yêu cầu | Ghi chú quan trọng |
| :---: | :--- | :--- | :--- |
| **1** | **Java Development Kit (JDK)** | **JDK 17 LTS** | Kiểm tra bằng lệnh: `java -version` trong CMD/Terminal. |
| **2** | **Apache Tomcat** | **Tomcat 10.1.x** | ⚠️ **BẮT BUỘC Tomcat 10.1.x** (dự án chạy Jakarta EE 10, **KHÔNG** dùng Tomcat 9 hoặc cũ hơn). |
| **3** | **Apache NetBeans IDE** | **NetBeans 17 trở lên** | (Khuyến nghị NetBeans 17, 18, 19, 20 hoặc mới nhất). |
| **4** | **Microsoft SQL Server** | **2019 / 2022 / Express** | Cổng mặc định **1433**, đã kích hoạt tài khoản `sa`. |
| **5** | **SQL Server Management Studio (SSMS)** | Phiên bản bất kỳ | Dùng để quản lý và kiểm tra dữ liệu SQL. |

---

## Bước 1: Giải nén mã nguồn dự án

1. Nhận file `MovieHub.zip` và giải nén ra một thư mục trên ổ đĩa máy tính (ví dụ: `D:\NetBeansProjects\MovieHub` hoặc `C:\Projects\MovieHub`).
2. ⚠️ **Lưu ý:** 
   - Đường dẫn thư mục **KHÔNG** nên chứa dấu tiếng Việt có dấu (ví dụ: tránh `D:\Bài tập\...`), không chứa ký tự đặc biệt để tránh lỗi trình biên dịch Ant và máy chủ web.

---

## Bước 2: Cài đặt và nạp Cơ sở Dữ liệu (Microsoft SQL Server)

Hệ thống MovieHub đi kèm bộ dữ liệu mẫu chuẩn điện ảnh (20 tài khoản, 13 thể loại, 27 bộ phim, 105 đánh giá, 28 câu hỏi Q&A).

### 2.1. Kiểm tra cấu hình SQL Server (Bắt buộc)
1. **Bật xác thực SQL Server (Mixed Mode):**
   - Mở SSMS, kết nối vào Server.
   - Chuột phải vào tên Server trên cùng -> Chọn **Properties** -> Chọn tab **Security**.
   - Tại mục *Server authentication*, tích chọn **SQL Server and Windows Authentication mode** -> Nhấn **OK**.
2. **Kích hoạt tài khoản `sa`:**
   - Mở mục `Security` -> `Logins` -> Chuột phải vào `sa` -> **Properties**.
   - Tab **General**: Đặt mật khẩu (khuyến nghị đặt là `123` để khớp cấu hình mặc định).
   - Tab **Status**: Chọn **Login: Enabled** -> Nhấn **OK**.
3. **Bật giao thức TCP/IP (Port 1433):**
   - Mở ứng dụng **SQL Server Configuration Manager** trên Windows.
   - Chọn mục **SQL Server Network Configuration** -> **Protocols for MSSQLSERVER** (hoặc SQLEXPRESS).
   - Kiểm tra **TCP/IP**: Nếu đang `Disabled`, hãy nhấp đúp và đổi thành **Enabled**.
   - Nhấp đúp vào **TCP/IP** -> tab **IP Addresses** -> cuộn xuống mục **IPAll** -> đảm bảo ô **TCP Port** là `1433`.
   - Vào mục **SQL Server Services** -> Chuột phải vào `SQL Server (...)` -> Chọn **Restart**.

---

### 2.2. Khởi tạo Database & Nạp dữ liệu

Khách hàng có thể chọn **1 trong 2 cách** sau:

#### Cách A: Tự động bằng 1-Click (Khuyến nghị - Nhanh nhất)
1. Mở thư mục `database/` trong thư mục dự án vừa giải nén.
2. Nhấp đúp chuột vào file `install.bat`.
3. Cửa sổ dòng lệnh hiện ra:
   - **SQL Server:** Nhấn `Enter` để nhận giá trị mặc định (`localhost`) hoặc nhập tên server của bạn.
   - **Tài khoản:** Nhấn `Enter` để nhận `sa`.
   - **Mật khẩu:** Nhấn `Enter` để nhận `123` (hoặc nhập mật khẩu `sa` trên máy bạn).
4. Chương trình sẽ tự động tạo CSDL `MovieHub`, tạo bảng và nạp toàn bộ 8 file dữ liệu mẫu tiếng Việt chuẩn Unicode.
5. Khi màn hình báo `HOÀN TẤT CÀI ĐẶT CƠ SỞ DỮ LIỆU MOVIEHUB THÀNH CÔNG!`, nhấn phím bất kỳ để đóng.

#### Cách B: Chạy thủ công bằng SSMS
1. Mở **SQL Server Management Studio (SSMS)** và đăng nhập vào SQL Server.
2. Vào thư mục `database/` của dự án, mở và nhấn **Execute (F5)** lần lượt từng file theo đúng thứ tự sau:
   - `01_schema.sql` *(Tạo Database MovieHub, bảng, khóa ngoại, index)*
   - `02_reset_data.sql` *(Dọn dẹp và reset ID)*
   - `03_seed_users.sql` *(Tạo 20 tài khoản mẫu)*
   - `04_seed_categories.sql` *(Tạo 13 thể loại phim)*
   - `05_seed_movies.sql` *(Tạo 27 phim điện ảnh kèm poster, trailer)*
   - `06_seed_favorites.sql` *(Tạo danh sách yêu thích)*
   - `07_seed_reviews.sql` *(Tạo 105 đánh giá phim)*
   - `08_seed_qa.sql` *(Tạo 28 câu hỏi và 40 câu trả lời cộng đồng)*

---

## Bước 3: Cấu hình kết nối CSDL trong mã nguồn

Mặc định dự án kết nối đến:
- **Server:** `localhost:1433`
- **Database:** `MovieHub`
- **User:** `sa`
- **Password:** `123`

👉 **Nếu mật khẩu `sa` hoặc cổng SQL Server trên máy bạn KHÁC `123`**, hãy chỉnh sửa:
1. Mở file: `src/conf/persistence.xml`
2. Tìm đến các dòng sau (khoảng dòng 18 - 21):
   ```xml
   <property name="jakarta.persistence.jdbc.driver" value="com.microsoft.sqlserver.jdbc.SQLServerDriver" />
   <property name="jakarta.persistence.jdbc.url" value="jdbc:sqlserver://localhost:1433;databaseName=MovieHub;encrypt=false;trustServerCertificate=true;" />
   <property name="jakarta.persistence.jdbc.user" value="sa" />
   <property name="jakarta.persistence.jdbc.password" value="123" />
   ```
3. Đổi giá trị `value` của `jakarta.persistence.jdbc.password` thành mật khẩu `sa` trên máy của bạn (và sửa lại `user` hoặc `url` nếu cần).
4. Lưu file lại (`Ctrl + S`).

---

## Bước 4: Mở dự án trong NetBeans & Cấu hình Tomcat 10.1

### 4.1. Thêm Apache Tomcat 10.1 vào NetBeans (nếu chưa có)
1. Mở **Apache NetBeans**.
2. Trên thanh menu, chọn: **Tools** -> **Servers**.
3. Nhấn nút **Add Server...**:
   - Chọn **Apache Tomcat or TomEE** -> Nhấn **Next**.
   - Tại ô **Server Location**: Nhấn **Browse...** và trỏ đến thư mục đã giải nén/cài đặt Tomcat 10.1 trên máy bạn (ví dụ: `C:\Program Files\Apache Software Foundation\Tomcat 10.1` hoặc `D:\apache-tomcat-10.1.x`).
   - Đặt Username / Password cho Manager (nếu có, hoặc để mặc định).
   - Nhấn **Finish**.

### 4.2. Mở dự án
1. Chọn menu: **File** -> **Open Project...** (hoặc `Ctrl + Shift + O`).
2. Trỏ đến thư mục `MovieHub` vừa giải nén (biểu tượng dự án sẽ có hình quả địa cầu Web Application).
3. Nhấn **Open Project**.

### 4.3. Khắc phục lỗi "Missing Server" (Cảnh báo vàng khi mở trên máy mới)
Vì đường dẫn Tomcat trên máy người gửi khác với máy của bạn, NetBeans có thể hiển thị biểu tượng chấm than vàng hoặc thông báo thiếu Server:
1. Chuột phải vào tên project **MovieHub** -> Chọn **Properties** (dưới cùng).
2. Tại danh mục bên trái, chọn thẻ **Run**.
3. Tại ô **Server**: Nhấp vào danh sách thả xuống và chọn Server **Tomcat 10.1** vừa thêm ở bước 4.1.
4. Đảm bảo ô **Java EE Version** hiển thị tương ứng với Tomcat 10 (Jakarta EE).
5. Nhấn **OK** để lưu lại cấu hình.

---

## Bước 5: Build và Khởi chạy ứng dụng

1. **Clean and Build dự án:**
   - Chuột phải vào project **MovieHub** -> Chọn **Clean and Build**.
   - Mở cửa sổ *Output* bên dưới và đợi cho đến khi xuất hiện thông báo:
     ```text
     BUILD SUCCESSFUL
     ```
2. **Khởi chạy ứng dụng (Run):**
   - Chuột phải vào project **MovieHub** -> Chọn **Run** (hoặc bấm phím tắt **F6**).
   - NetBeans sẽ tự động bật máy chủ Tomcat 10.1, triển khai ứng dụng và mở trình duyệt mặc định.
3. **Đường dẫn truy cập trực tiếp:**
   - Trang chủ người dùng:
     👉 **`http://localhost:8080/MovieHub/`**
   - Trang quản trị Admin:
     👉 **`http://localhost:8080/MovieHub/admin`**
   *(Nếu Tomcat của bạn cấu hình cổng khác như 8084, hãy thay 8080 bằng cổng tương ứng).*

---

## 7. Danh sách tài khoản kiểm thử có sẵn

Hệ thống đã nạp sẵn các tài khoản với đầy đủ dữ liệu lịch sử xem, đánh giá, danh sách yêu thích:

| Phân quyền | Email đăng nhập | Mật khẩu chung | Họ và tên | Chức năng kiểm thử |
| :--- | :--- | :---: | :--- | :--- |
| **QUẢN TRỊ VIÊN (Admin)** | `admin@moviehub.vn` | **`Password123!`** | Admin MovieHub | Toàn quyền trang `/admin`: Quản lý phim, thể loại, duyệt đánh giá/hỏi đáp, xem báo cáo phân tích KPI. |
| **THÀNH VIÊN (Member)** | `tuan.nguyen@moviehub.vn` | **`Password123!`** | Nguyễn Thanh Tuấn | Xem phim, thêm phim vào Watchlist, đánh giá 5 sao, tương tác Q&A. |
| **THÀNH VIÊN (Member)** | `mai.le@moviehub.vn` | **`Password123!`** | Lê Thị Tuyết Mai | Bình luận, hỏi đáp phim điện ảnh. |
| **THÀNH VIÊN (Member)** | `duc.tran@moviehub.vn` | **`Password123!`** | Trần Minh Đức | Xem phim viễn tưởng, viết đánh giá. |
| **TÀI KHOẢN KHÓA (Inactive)**| `hung.lam@moviehub.vn` | **`Password123!`** | Lâm Quốc Hưng | Kiểm thử chức năng bảo mật chặn đăng nhập tài khoản vô hiệu hóa. |

---

## 8. Xử lý các lỗi thường gặp (Troubleshooting)

### ❌ Lỗi 1: `Login failed for user 'sa'` hoặc `Cannot open database "MovieHub"`
- **Nguyên nhân:** Mật khẩu `sa` trong `src/conf/persistence.xml` không khớp với mật khẩu của SQL Server trên máy bạn, hoặc chưa tạo Database `MovieHub`.
- **Cách sửa:**
  1. Kiểm tra lại xem đã chạy script `database/install.bat` chưa.
  2. Mở SSMS xem đã có database `MovieHub` chưa.
  3. Mở file `src/conf/persistence.xml` và cập nhật mật khẩu `sa` chính xác.

---

### ❌ Lỗi 2: `The TCP/IP connection to the host localhost, port 1433 has failed`
- **Nguyên nhân:** Cổng 1433 của SQL Server chưa được kích hoạt hoặc dịch vụ SQL Server chưa chạy.
- **Cách sửa:**
  1. Mở **SQL Server Configuration Manager**.
  2. Chọn **SQL Server Network Configuration** -> **Protocols for ...** -> Bật **TCP/IP** thành **Enabled**.
  3. Nhấp đúp vào **TCP/IP**, chọn tab **IP Addresses**, kéo xuống dưới cùng mục **IPAll** điền **TCP Port = 1433**.
  4. Khởi động lại dịch vụ SQL Server (**Restart** service).

---

### ❌ Lỗi 3: `HTTP Status 500` hoặc `ClassNotFoundException: jakarta.servlet...`
- **Nguyên nhân:** Bạn đang sử dụng **Apache Tomcat 9 hoặc cũ hơn**. Từ phiên bản Jakarta EE 10, toàn bộ tiền tố package đã chuyển từ `javax.*` sang `jakarta.*`.
- **Cách sửa:**
  - Bắt buộc tải và cấu hình **Apache Tomcat 10.1.x**.
  - Vào NetBeans -> Chuột phải Project -> **Properties** -> **Run** -> Chọn đúng Server Tomcat 10.1.

---

### ❌ Lỗi 4: `Port 8080 already in use`
- **Nguyên nhân:** Có một phần mềm khác (như Oracle, IIS, ứng dụng khác) đang chiếm cổng 8080.
- **Cách sửa:**
  - Vào thư mục cài đặt Tomcat -> thư mục `conf/` -> mở file `server.xml`.
  - Tìm dòng: `<Connector port="8080" protocol="HTTP/1.1"`
  - Đổi `8080` thành cổng khác, ví dụ `8088` hoặc `8888`.
  - Khởi động lại Tomcat trong NetBeans.

---

### ❌ Lỗi 5: Chữ tiếng Việt bị vỡ font / lỗi mã hóa khi hiển thị
- **Đảm bảo:** Toàn bộ dự án đã được thiết lập UTF-8 chuẩn. Khi chạy script bằng `sqlcmd`, phải kèm cờ `-f 65001` (file `install.bat` đã tích hợp sẵn). Nếu chạy thủ công trong SSMS, các file SQL đều đã có ký tự `N'...'` bảo vệ Unicode.

---


🎉 **Chúc bạn cài đặt và trải nghiệm thành công ứng dụng MovieHub!**
