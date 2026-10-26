-- =========================================================================
-- MovieHub | 00_run_all.sql (Chạy toàn bộ theo đúng thứ tự)
-- File này tổng hợp hoặc hướng dẫn thực thi tuần tự 8 file từ 01 đến 08:
--   01_schema.sql          : Tạo cấu trúc bảng, khóa ngoại, ràng buộc, chỉ mục
--   02_reset_data.sql      : Dọn sạch dữ liệu cũ và test data, reset IDENTITY về 0
--   03_seed_users.sql      : Nạp 20 tài khoản mẫu (Admin, Members, Inactive)
--   04_seed_categories.sql : Nạp 13 thể loại phim điện ảnh
--   05_seed_movies.sql     : Nạp 27 phim với trailer/video YouTube và poster chuẩn TMDB
--   06_seed_favorites.sql  : Nạp danh sách yêu thích liên kết người dùng và phim
--   07_seed_reviews.sql    : Nạp 105 đánh giá chi tiết (APPROVED, PENDING, REJECTED)
--   08_seed_qa.sql         : Nạp 28 câu hỏi và 40 câu trả lời cộng đồng
-- =========================================================================
SET NOCOUNT ON;
GO

PRINT N'=========================================================================';
PRINT N'MovieHub - Bắt đầu khởi tạo cơ sở dữ liệu và nạp dữ liệu mẫu...';
PRINT N'=========================================================================';
GO
:r 01_schema.sql
:r 02_reset_data.sql
:r 03_seed_users.sql
:r 04_seed_categories.sql
:r 05_seed_movies.sql
:r 06_seed_favorites.sql
:r 07_seed_reviews.sql
:r 08_seed_qa.sql
GO

PRINT N'=========================================================================';
PRINT N'MovieHub - Khởi tạo và nạp toàn bộ dữ liệu thành công 100%!';
PRINT N'=========================================================================';
GO
