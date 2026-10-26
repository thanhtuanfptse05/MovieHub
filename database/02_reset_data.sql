-- =========================================================================
-- MovieHub | 02_reset_data.sql
-- Xóa SẠCH toàn bộ dữ liệu nghiệp vụ (cả dữ liệu test) và đặt lại bộ đếm ID về 1.
-- Giữ nguyên cấu trúc bảng. Thứ tự xóa tuân theo khóa ngoại (con trước, cha sau).
--
-- CẢNH BÁO: không thể hoàn tác. Chỉ chạy khi muốn nạp lại dữ liệu mẫu từ đầu.
-- =========================================================================
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

USE MovieHub;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM dbo.Answers;
    DELETE FROM dbo.Questions;
    DELETE FROM dbo.Reviews;
    DELETE FROM dbo.Favorites;
    DELETE FROM dbo.MovieCategories;
    DELETE FROM dbo.Movies;
    DELETE FROM dbo.Categories;
    DELETE FROM dbo.Users;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

DBCC CHECKIDENT (N'dbo.Answers',    RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT (N'dbo.Questions',  RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT (N'dbo.Reviews',    RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT (N'dbo.Favorites',  RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT (N'dbo.Movies',     RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT (N'dbo.Categories', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT (N'dbo.Users',      RESEED, 0) WITH NO_INFOMSGS;
GO

PRINT N'[02] Đã xóa toàn bộ dữ liệu cũ và đặt lại ID.';
GO
