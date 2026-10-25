# MovieHub SQL Server setup

Thiết kế và ERD: [database.md](../docs/architecture/database.md). Các script hỗ trợ SQL Server, không phải MySQL. Không tải thư viện; cần Windows PowerShell 5.1+ và SQL Server đang chạy.

## Thiết lập

Chạy tại thư mục gốc MovieHub:

```powershell
.\database\Setup-Database.ps1
```

Mặc định server `localhost,1433`, database `MovieHub`, login `sa`. Script hỏi mật khẩu bằng ô nhập ẩn; dùng mật khẩu SQL Server của bạn. Có thể nhận `DB_PASSWORD` từ môi trường của process thay vì hỏi. Không truyền mật khẩu vào command line, không ghi vào repo. `-Server` hỗ trợ instance/port khác; `-Username` đổi login; `-Credential (Get-Credential)` truyền credential đã nhập an toàn.

Script tạo database nếu chưa có, rồi chạy schema trong transaction. Có thể chạy lại. Chỉ hỗ trợ database mới hoặc baseline Users tương thích; nếu có schema khác cần migration riêng, không dùng script để tự sửa kiểu cột. Dữ liệu vi phạm constraint mới làm script dừng/rollback, không tự sửa hoặc xóa. Không reset password, thay login sa, bật TCP, đổi isolation hoặc ngắt phiên khác. Users cũ được giữ nguyên; các bảng mới ban đầu rỗng.

File SQL dùng trực tiếp trong SSMS: chạy `000-create-database.sql` trên `master`, chọn database `MovieHub`, rồi chạy `001-schema.sql`. Không chạy schema trên master. DDL tách khỏi ứng dụng; ứng dụng vẫn dùng JPA và `hibernate.hbm2ddl.auto=none`.

## Kiểm tra

```powershell
.\database\Test-Database.ps1
```

Test xác nhận Unicode/defaults, canonical uniqueness, phân biệt dấu category, soft-delete uniqueness, miền rating/status/views/slug, audit duyệt, FK và không cascade delete. Fixture được rollback; IDENTITY có thể có khoảng trống sau test, là hành vi bình thường của SQL Server. Chạy test lúc không có thao tác sửa dữ liệu để tránh tranh chấp khóa. Test không xác nhận toàn bộ quy tắc Service, các quy tắc đó được phân định trong tài liệu thiết kế.

Khi thêm category, Service/seed phải ghi `name_key` đã chuẩn hóa NFC → trim → lowercase Locale.ROOT cùng `name`. Database unique theo key nhị phân; không dùng collation ngôn ngữ để gộp các tên Unicode khác nhau. Xem [thiết kế](../docs/architecture/database.md) trước khi map entity Category.

## Kết nối ứng dụng

JPA unit `MovieHubPU` ở `src/conf/persistence.xml` đã trỏ `localhost:1433;databaseName=MovieHub`. `JPAUtil` hỗ trợ override bằng `DB_URL`, `DB_USER`, `DB_PASSWORD`; các biến này phải có trong process chạy Tomcat/NetBeans để có hiệu lực. Script chỉ dùng biến mật khẩu của process hiện tại, không ghi cấu hình môi trường toàn máy. Thông tin đăng nhập SQL Server khác với tài khoản đăng nhập website.

## Phạm vi dữ liệu

Không seed phim, tài khoản, review hoặc reset token khi setup. Giữ nguyên Users có sẵn; không tự đổi role thành ADMIN. Bộ dữ liệu demo theo `specs/shared/data-contract.md` là bước riêng. Không tạo bảng PasswordResetTokens mới vì luồng R-01 đã bỏ token.
