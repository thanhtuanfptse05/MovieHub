-- =========================================================================
-- MovieHub | 04_seed_categories.sql
-- 13 thể loại phim. name_key = tên viết thường (khớp cách ứng dụng chuẩn hóa).
-- =========================================================================
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

USE MovieHub;
GO

DECLARE @cats TABLE (name nvarchar(100), slug varchar(120) COLLATE Latin1_General_100_BIN2, days_ago int);

INSERT INTO @cats (name, slug, days_ago) VALUES
(N'Hành Động',  'hanh-dong',  200),
(N'Viễn Tưởng', 'vien-tuong', 200),
(N'Phiêu Lưu',  'phieu-luu',  200),
(N'Tâm Lý',     'tam-ly',     200),
(N'Kinh Dị',    'kinh-di',    200),
(N'Hoạt Hình',  'hoat-hinh',  200),
(N'Hài Hước',   'hai-huoc',   200),
(N'Tình Cảm',   'tinh-cam',   200),
(N'Hình Sự',    'hinh-su',    190),
(N'Giật Gân',   'giat-gan',   190),
(N'Giả Tưởng',  'gia-tuong',  190),
(N'Gia Đình',   'gia-dinh',   190),
(N'Lịch Sử',    'lich-su',    190);

INSERT INTO dbo.Categories (name, name_key, slug, created_at, version)
SELECT c.name, LOWER(LTRIM(RTRIM(c.name))), c.slug, DATEADD(DAY, -c.days_ago, SYSUTCDATETIME()), 1
FROM @cats c
WHERE NOT EXISTS (SELECT 1 FROM dbo.Categories x WHERE x.slug = c.slug);

PRINT N'[04] Đã nạp thể loại.';
GO
