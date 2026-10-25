# MovieHub SQL Server Database Implementation Plan

> **For agentic workers:** Use executing-plans to implement this plan task-by-task in the current checkout. Database setup is explicitly requested by the user.

**Goal:** Thiết lập schema SQL Server MovieHub, giữ nguyên dữ liệu Users hiện có.

**Architecture:** SQL deployment scripts độc lập với CRUD của ứng dụng. PowerShell dùng SqlClient có sẵn để chạy DDL/tests; web app vẫn dùng JPA. Không tạo lại database, seed business data hoặc tự cấp quyền.

**Tech Stack:** SQL Server 2022 local, Windows PowerShell 5.1/.NET SqlClient, Java 17/Ant hiện tại.

**Spec:** [Database design](../../architecture/database.md), [data contract](../../../specs/shared/data-contract.md), R-01.

## Global Constraints

- Giữ 5 Users hiện có; không đổi password/hash/role/status, không cascade delete.
- Tám bảng nghiệp vụ; không tạo bảng token mới; không thêm JAR.
- Không ghi mật khẩu vào script hoặc tài liệu mới. Giữ cấu hình JPA đã đúng theo yêu cầu.
- Scope chỉ schema/setup; không thay UI, không seed catalog hoặc triển khai DAO mới.

## Review Focus

- Nâng cấp Users hiện có: bảo toàn toàn bộ dữ liệu và phát hiện schema không tương thích.
- Chạy lại setup: không thay dữ liệu hoặc tạo trùng constraint/index.
- Case/space duplicates và category có dấu: unique đúng canonical.
- FK, rating/status, audit sai và soft-delete uniqueness phải bị từ chối.
- Fixture test rollback ngay cả khi lỗi; không dùng transaction kiểm tra để reset database.

## Tasks

- [x] Kiểm kê schema, kết nối sa, đọc entity User và các spec dữ liệu.
- [x] Viết SQL integration assertions và chạy RED trên schema thiếu bảng.
- [x] Viết schema idempotent/transactional, runner setup và hướng dẫn dùng.
- [x] Chạy setup hai lần; so sánh checksum toàn bộ Users trước/sau; chạy SQL tests GREEN.
- [x] Smoke test EntityManager đọc/ghi/rollback; chạy Ant compile/test; review độc lập và sửa lỗi nếu có.
- [x] Ghi kết quả kiểm chứng; tạo nhánh giao feat/sqlserver-database. Trạng thái commit/push được ghi trong Git.

## Rulings

- Làm trong checkout hiện tại, dùng feature branch khi giao; không cần tạo worktree để thêm script triển khai local.
- R-01/data-contract mới quyết định số bảng đang dùng; dòng 9 bảng trong overview cũ chỉ là lịch sử.
- Thiết kế/setup đã được yêu cầu trực tiếp; không thêm vòng phê duyệt để thực hiện thao tác bổ sung, không phá dữ liệu.
- Review phát hiện collation ngôn ngữ gộp Straße/Strasse: chuyển Category sang key do Service chuẩn hóa, DB so sánh BIN2; thêm kiểm tra enum padding. Regression tests đã RED rồi GREEN.
- Kết quả chi tiết: [verification](../../../database/VERIFICATION.md).
