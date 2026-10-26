-- =========================================================================
-- MovieHub | 03_seed_users.sql
-- 1 quản trị viên + 17 thành viên đang hoạt động + 2 tài khoản bị khóa.
--
-- Mật khẩu của TẤT CẢ tài khoản mẫu: Password123!
-- (BCrypt cost 12; hãy đổi mật khẩu quản trị trước khi đưa lên môi trường thật)
-- =========================================================================
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

USE MovieHub;
GO

DECLARE @hash varchar(255) = '$2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q';

DECLARE @users TABLE (
    full_name  nvarchar(100),
    email      varchar(255),
    role       varchar(10),
    status     varchar(10),
    avatar_url nvarchar(1000),
    days_ago   int
);

INSERT INTO @users (full_name, email, role, status, avatar_url, days_ago) VALUES
(N'Admin MovieHub',      'admin@moviehub.vn',       'ADMIN', 'ACTIVE',   N'https://i.pravatar.cc/300?img=68', 150),
(N'Nguyễn Thanh Tuấn',   'tuan.nguyen@moviehub.vn', 'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=12', 120),
(N'Lê Thị Tuyết Mai',    'mai.le@moviehub.vn',      'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=47', 112),
(N'Trần Minh Đức',       'duc.tran@moviehub.vn',    'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=33', 104),
(N'Phạm Hương Lan',      'lan.pham@moviehub.vn',    'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=45', 97),
(N'Vũ Hoàng Nam',        'hoang.vu@moviehub.vn',    'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=15', 90),
(N'Nguyễn Phương Thảo',  'thao.nguyen@moviehub.vn', 'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=44', 84),
(N'Đặng Anh Khoa',       'khoa.dang@moviehub.vn',   'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=52', 77),
(N'Bùi Khánh Linh',      'linh.bui@moviehub.vn',    'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=32', 71),
(N'Hoàng Trường Sơn',    'son.hoang@moviehub.vn',   'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=59', 66),
(N'Đỗ Thu Trang',        'trang.do@moviehub.vn',    'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=48', 60),
(N'Võ Thành Long',       'long.vo@moviehub.vn',     'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=14', 54),
(N'Lý Bảo Ngọc',         'ngoc.ly@moviehub.vn',     'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=23', 49),
(N'Đinh Hồng Phúc',      'phuc.dinh@moviehub.vn',   'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=60', 43),
(N'Trương Hải Yến',      'yen.truong@moviehub.vn',  'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=25', 37),
(N'Huỳnh Gia Bảo',       'bao.huynh@moviehub.vn',   'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=51', 31),
(N'Phan Thảo Vy',        'vy.phan@moviehub.vn',     'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=38', 24),
(N'Ngô Minh Quân',       'quan.ngo@moviehub.vn',    'USER',  'ACTIVE',   N'https://i.pravatar.cc/300?img=11', 17),
(N'Lâm Quốc Hưng',       'hung.lam@moviehub.vn',    'USER',  'INACTIVE', NULL,                                 95),
(N'Trịnh Văn Dũng',      'dung.trinh@moviehub.vn',  'USER',  'INACTIVE', NULL,                                 58);

INSERT INTO dbo.Users (full_name, email, password_hash, role, status, avatar_url,
                       created_at, updated_at, version, credentials_version)
SELECT u.full_name, u.email, @hash, u.role, u.status, u.avatar_url,
       DATEADD(DAY, -u.days_ago, SYSUTCDATETIME()),
       DATEADD(DAY, -u.days_ago, SYSUTCDATETIME()),
       1, 1
FROM @users u
WHERE NOT EXISTS (SELECT 1 FROM dbo.Users x WHERE x.email = u.email);

PRINT N'[03] Đã nạp người dùng mẫu.';
GO
