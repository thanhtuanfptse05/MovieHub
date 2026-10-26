-- =========================================================================
-- MovieHub | 06_seed_favorites.sql
-- Danh sách phim yêu thích của 17 thành viên (chỉ phim đã công khai).
-- Thời điểm thêm yêu thích luôn nằm sau ngày đăng ký và sau ngày phim được tạo.
-- =========================================================================
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

USE MovieHub;
GO

DECLARE @fav TABLE (
    email_local varchar(100),
    movie_slug  varchar(250) COLLATE Latin1_General_100_BIN2
);

INSERT INTO @fav VALUES
('tuan.nguyen', 'interstellar'), ('tuan.nguyen', 'inception'), ('tuan.nguyen', 'dune-part-1'),
('tuan.nguyen', 'the-dark-knight'), ('tuan.nguyen', 'oppenheimer'), ('tuan.nguyen', 'the-matrix'),

('mai.le', 'spirited-away'), ('mai.le', 'mai'), ('mai.le', 'parasite'),
('mai.le', 'spider-man-across-the-spider-verse'), ('mai.le', 'nha-ba-nu'), ('mai.le', 'despicable-me-4'),

('duc.tran', 'oppenheimer'), ('duc.tran', 'the-godfather'), ('duc.tran', 'dune-part-2'),
('duc.tran', 'the-dark-knight'), ('duc.tran', 'mad-max-fury-road'),

('lan.pham', 'the-conjuring'), ('lan.pham', 'a-quiet-place'), ('lan.pham', 'train-to-busan'),
('lan.pham', 'the-platform'),

('hoang.vu', 'incredibles-2'), ('hoang.vu', 'despicable-me-4'), ('hoang.vu', 'the-matrix'),
('hoang.vu', 'mad-max-fury-road'), ('hoang.vu', 'avatar-the-way-of-water'),

('thao.nguyen', 'mai'), ('thao.nguyen', 'nha-ba-nu'), ('thao.nguyen', 'dat-rung-phuong-nam'),
('thao.nguyen', 'spirited-away'), ('thao.nguyen', 'oz-the-great-and-powerful'),

('khoa.dang', 'inception'), ('khoa.dang', 'the-matrix'), ('khoa.dang', 'interstellar'),
('khoa.dang', 'dune-part-2'), ('khoa.dang', 'avatar-the-way-of-water'), ('khoa.dang', 'mad-max-fury-road'),

('linh.bui', 'parasite'), ('linh.bui', 'mai'), ('linh.bui', 'oppenheimer'),
('linh.bui', 'the-tragedy-of-macbeth'),

('son.hoang', 'the-godfather'), ('son.hoang', 'the-dark-knight'), ('son.hoang', 'oppenheimer'),
('son.hoang', 'mad-max-fury-road'),

('trang.do', 'spirited-away'), ('trang.do', 'oz-the-great-and-powerful'), ('trang.do', 'incredibles-2'),
('trang.do', 'despicable-me-4'), ('trang.do', 'spider-man-across-the-spider-verse'), ('trang.do', 'nha-ba-nu'),

('long.vo', 'train-to-busan'), ('long.vo', 'the-platform'), ('long.vo', 'the-conjuring'),
('long.vo', 'a-quiet-place'), ('long.vo', 'parasite'),

('ngoc.ly', 'mai'), ('ngoc.ly', 'dat-rung-phuong-nam'), ('ngoc.ly', 'nha-ba-nu'), ('ngoc.ly', 'parasite'),

('phuc.dinh', 'dune-part-1'), ('phuc.dinh', 'dune-part-2'), ('phuc.dinh', 'interstellar'),
('phuc.dinh', 'avatar-the-way-of-water'), ('phuc.dinh', 'inception'),

('yen.truong', 'spirited-away'), ('yen.truong', 'spider-man-across-the-spider-verse'),
('yen.truong', 'mai'), ('yen.truong', 'oz-the-great-and-powerful'),

('bao.huynh', 'the-dark-knight'), ('bao.huynh', 'inception'), ('bao.huynh', 'the-matrix'),
('bao.huynh', 'spider-man-across-the-spider-verse'), ('bao.huynh', 'dune-part-2'),

('vy.phan', 'mai'), ('vy.phan', 'nha-ba-nu'), ('vy.phan', 'parasite'),
('vy.phan', 'spirited-away'), ('vy.phan', 'the-tragedy-of-macbeth'),

('quan.ngo', 'oppenheimer'), ('quan.ngo', 'interstellar'), ('quan.ngo', 'the-godfather'),
('quan.ngo', 'dat-rung-phuong-nam');

INSERT INTO dbo.Favorites (user_id, movie_id, created_at)
SELECT s.user_id, s.movie_id,
       DATEADD(MINUTE,
               ABS(CHECKSUM(s.user_id, s.movie_id)) % NULLIF(DATEDIFF(MINUTE, s.base_at, SYSUTCDATETIME()), 0),
               s.base_at)
FROM (
    SELECT u.id AS user_id, m.id AS movie_id,
           CASE WHEN u.created_at > m.created_at THEN u.created_at ELSE m.created_at END AS base_at
    FROM @fav f
    JOIN dbo.Users  u ON u.email = f.email_local + '@moviehub.vn'
    JOIN dbo.Movies m ON m.slug  = f.movie_slug AND m.status = 'PUBLISHED'
) s
WHERE NOT EXISTS (SELECT 1 FROM dbo.Favorites x WHERE x.user_id = s.user_id AND x.movie_id = s.movie_id);

PRINT N'[06] Đã nạp danh sách yêu thích.';
GO
