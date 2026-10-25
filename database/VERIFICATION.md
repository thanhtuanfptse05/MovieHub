# Kết quả kiểm chứng — 2026-10-25

Môi trường thực tế: SQL Server 2022 Developer 16.0.1000.6, instance MSSQLSERVER tại localhost:1433; Windows PowerShell/.NET SqlClient; Hibernate và JDBC driver đang có trong dự án. Login sa kết nối thành công bằng credential chủ dự án cung cấp. Không cài hoặc thay thư viện.

| Kiểm tra | Kết quả |
|---|---|
| Baseline | MovieHub có duy nhất dbo.Users, 5 hàng |
| SQL tests trước schema | FAIL đúng nguyên nhân thiếu 8 bảng |
| Setup lần đầu và chạy lại | PASS; 8 bảng, 5 Users, các bảng nghiệp vụ khác 0 hàng |
| Bảo toàn Users | COUNT=5, fingerprint BINARY_CHECKSUM tất cả 11 cột nghiệp vụ trước/sau cùng 620758416; không có thao tác ghi Users được commit |
| FK/check constraints | 13 FK không cascade, 34 CHECK; tất cả enabled/trusted |
| SQL integration tests sau sửa review | PASS; Unicode, defaults, canonical key, soft delete, audit, FK, rating/views/status/slug; mọi fixture rollback |
| Enum padding/canonical Unicode regression | FAIL với schema đầu, PASS sau sửa; phân biệt Straße/Strasse và i/i có dấu chấm |
| Database mới | Tạo database kiểm thử riêng, chạy cùng schema chỉ đổi guard DB_NAME, chạy schema lần hai và SQL assertions: PASS; đã xóa database kiểm thử do phiên này tạo |
| JPA smoke | Mở MovieHubPU, persist/flush/refresh User tiếng Việt, đọc named query, kiểm tra timestamp, rollback; COUNT Users vẫn 5 |
| Ant compile | BUILD SUCCESSFUL |
| Ant test | BUILD SUCCESSFUL; AuthServiceTest: 12 tests, 0 failures, 0 errors |
| Git diff whitespace | PASS |

Review độc lập đã phát hiện hai điểm: collation tên thể loại và enum có padding. Đã thêm regression coverage và sửa cả hai trước giao. Bootstrap hỗ trợ database mới/Users tương thích; không thực hiện migration tùy ý cho schema khác.

Các kiểm tra này không đồng nghĩa hoàn thành các module web hoặc bộ dữ liệu demo. Chưa seed catalog, chưa tạo Admin website, chưa kiểm thử UI/media hay luồng Service của các module chưa triển khai. Không đổi UI/JSP, servlet, DAO, hash của người dùng, cấu hình login SQL Server hoặc thư viện. Các thư viện đã có ngoài allowlist là trạng thái baseline, không được thay đổi trong task này. Cảnh báo Hibernate built-in pool/dialect hiện có vẫn xuất hiện nhưng smoke test kết thúc thành công.

Lệnh kiểm tra có thể chạy lại:

```powershell
.\database\Setup-Database.ps1
.\database\Test-Database.ps1
& 'C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat' compile
& 'C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat' test
```
