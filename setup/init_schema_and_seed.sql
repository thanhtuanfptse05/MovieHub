-- =========================================================================
-- MovieHub Comprehensive Database Schema & Rich Seed Data
-- =========================================================================

USE MovieHub;

-- 1. Ensure Categories table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Categories')
BEGIN
    CREATE TABLE Categories (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL UNIQUE,
        slug VARCHAR(120) NOT NULL UNIQUE,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        deleted_at DATETIME2 NULL,
        version INT NOT NULL DEFAULT 1
    );
    CREATE INDEX IX_Categories_Slug ON Categories(slug);
END;

-- 2. Ensure Movies table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Movies')
BEGIN
    CREATE TABLE Movies (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        title NVARCHAR(200) NOT NULL,
        slug VARCHAR(250) NOT NULL UNIQUE,
        description NVARCHAR(MAX) NOT NULL,
        release_year INT NOT NULL,
        duration_minutes INT NOT NULL,
        poster_url VARCHAR(1000) NULL,
        video_url VARCHAR(1000) NULL,
        trailer_url VARCHAR(1000) NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'DRAFT', -- DRAFT, PUBLISHED, HIDDEN
        featured BIT NOT NULL DEFAULT 0,
        view_count BIGINT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        version INT NOT NULL DEFAULT 1
    );
    CREATE INDEX IX_Movies_Slug ON Movies(slug);
    CREATE INDEX IX_Movies_Status ON Movies(status);
END;

-- 3. Ensure MovieCategories junction table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MovieCategories')
BEGIN
    CREATE TABLE MovieCategories (
        movie_id BIGINT NOT NULL FOREIGN KEY REFERENCES Movies(id) ON DELETE CASCADE,
        category_id BIGINT NOT NULL FOREIGN KEY REFERENCES Categories(id) ON DELETE CASCADE,
        PRIMARY KEY (movie_id, category_id)
    );
END;

-- 4. Ensure Favorites table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Favorites')
BEGIN
    CREATE TABLE Favorites (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        user_id BIGINT NOT NULL FOREIGN KEY REFERENCES Users(id),
        movie_id BIGINT NOT NULL FOREIGN KEY REFERENCES Movies(id),
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        deleted_at DATETIME2 NULL,
        CONSTRAINT UQ_Favorites_User_Movie UNIQUE (user_id, movie_id)
    );
    CREATE INDEX IX_Favorites_User ON Favorites(user_id);
END;

-- 5. Ensure Reviews table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Reviews')
BEGIN
    CREATE TABLE Reviews (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        user_id BIGINT NOT NULL FOREIGN KEY REFERENCES Users(id),
        movie_id BIGINT NOT NULL FOREIGN KEY REFERENCES Movies(id),
        rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
        content NVARCHAR(1000) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
        moderated_by BIGINT NULL FOREIGN KEY REFERENCES Users(id),
        moderated_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        deleted_at DATETIME2 NULL,
        version INT NOT NULL DEFAULT 1,
        content_revision INT NOT NULL DEFAULT 1,
        CONSTRAINT UQ_Reviews_User_Movie UNIQUE (user_id, movie_id)
    );
    CREATE INDEX IX_Reviews_Movie ON Reviews(movie_id);
END;

-- 6. Ensure Questions table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Questions')
BEGIN
    CREATE TABLE Questions (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        movie_id BIGINT NOT NULL FOREIGN KEY REFERENCES Movies(id),
        user_id BIGINT NOT NULL FOREIGN KEY REFERENCES Users(id),
        content NVARCHAR(500) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
        moderated_by BIGINT NULL FOREIGN KEY REFERENCES Users(id),
        moderated_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        version INT NOT NULL DEFAULT 1
    );
    CREATE INDEX IX_Questions_Movie ON Questions(movie_id);
END;

-- 7. Ensure Answers table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Answers')
BEGIN
    CREATE TABLE Answers (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        question_id BIGINT NOT NULL FOREIGN KEY REFERENCES Questions(id),
        user_id BIGINT NOT NULL FOREIGN KEY REFERENCES Users(id),
        content NVARCHAR(1000) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
        moderated_by BIGINT NULL FOREIGN KEY REFERENCES Users(id),
        moderated_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        version INT NOT NULL DEFAULT 1
    );
    CREATE INDEX IX_Answers_Question ON Answers(question_id);
END;

-- =========================================================================
-- SEED DATA
-- Default Password for all demo accounts: Password123!
-- BCrypt Hash: $2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q
-- =========================================================================

-- Seed Demo Users
IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'admin@moviehub.vn')
    INSERT INTO Users (full_name, email, password_hash, role, status, avatar_url, created_at, updated_at, version, credentials_version)
    VALUES (N'Admin MovieHub', 'admin@moviehub.vn', '$2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q', 'ADMIN', 'ACTIVE', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80', DATEADD(DAY, -60, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'tuan.nguyen@moviehub.vn')
    INSERT INTO Users (full_name, email, password_hash, role, status, avatar_url, created_at, updated_at, version, credentials_version)
    VALUES (N'Nguyễn Thanh Tuấn', 'tuan.nguyen@moviehub.vn', '$2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q', 'USER', 'ACTIVE', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80', DATEADD(DAY, -45, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'mai.le@moviehub.vn')
    INSERT INTO Users (full_name, email, password_hash, role, status, avatar_url, created_at, updated_at, version, credentials_version)
    VALUES (N'Lê Thị Tuyết Mai', 'mai.le@moviehub.vn', '$2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q', 'USER', 'ACTIVE', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80', DATEADD(DAY, -30, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'duc.tran@moviehub.vn')
    INSERT INTO Users (full_name, email, password_hash, role, status, avatar_url, created_at, updated_at, version, credentials_version)
    VALUES (N'Trần Minh Đức', 'duc.tran@moviehub.vn', '$2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q', 'USER', 'ACTIVE', 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=300&q=80', DATEADD(DAY, -20, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'lan.pham@moviehub.vn')
    INSERT INTO Users (full_name, email, password_hash, role, status, avatar_url, created_at, updated_at, version, credentials_version)
    VALUES (N'Phạm Hương Lan', 'lan.pham@moviehub.vn', '$2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q', 'USER', 'ACTIVE', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=300&q=80', DATEADD(DAY, -15, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'hoang.vu@moviehub.vn')
    INSERT INTO Users (full_name, email, password_hash, role, status, avatar_url, created_at, updated_at, version, credentials_version)
    VALUES (N'Vũ Hoàng Nam', 'hoang.vu@moviehub.vn', '$2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q', 'USER', 'ACTIVE', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80', DATEADD(DAY, -10, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'banned@moviehub.vn')
    INSERT INTO Users (full_name, email, password_hash, role, status, avatar_url, created_at, updated_at, version, credentials_version)
    VALUES (N'Tài Khoản Bị Khóa', 'banned@moviehub.vn', '$2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q', 'USER', 'INACTIVE', NULL, DATEADD(DAY, -90, GETDATE()), GETDATE(), 1, 1);

-- Seed Categories
DECLARE @catAction BIGINT, @catSciFi BIGINT, @catAdventure BIGINT, @catDrama BIGINT, @catHorror BIGINT, @catAnimation BIGINT, @catComedy BIGINT, @catRomance BIGINT;

IF NOT EXISTS (SELECT 1 FROM Categories WHERE slug = 'hanh-dong')
    INSERT INTO Categories (name, slug, created_at, version) VALUES (N'Hành Động', 'hanh-dong', GETDATE(), 1);
IF NOT EXISTS (SELECT 1 FROM Categories WHERE slug = 'vien-tuong')
    INSERT INTO Categories (name, slug, created_at, version) VALUES (N'Viễn Tưởng', 'vien-tuong', GETDATE(), 1);
IF NOT EXISTS (SELECT 1 FROM Categories WHERE slug = 'phieu-luu')
    INSERT INTO Categories (name, slug, created_at, version) VALUES (N'Phiêu Lưu', 'phieu-luu', GETDATE(), 1);
IF NOT EXISTS (SELECT 1 FROM Categories WHERE slug = 'tam-ly')
    INSERT INTO Categories (name, slug, created_at, version) VALUES (N'Tâm Lý', 'tam-ly', GETDATE(), 1);
IF NOT EXISTS (SELECT 1 FROM Categories WHERE slug = 'kinh-di')
    INSERT INTO Categories (name, slug, created_at, version) VALUES (N'Kinh Dị', 'kinh-di', GETDATE(), 1);
IF NOT EXISTS (SELECT 1 FROM Categories WHERE slug = 'hoat-hinh')
    INSERT INTO Categories (name, slug, created_at, version) VALUES (N'Hoạt Hình', 'hoat-hinh', GETDATE(), 1);
IF NOT EXISTS (SELECT 1 FROM Categories WHERE slug = 'hai-huoc')
    INSERT INTO Categories (name, slug, created_at, version) VALUES (N'Hài Hước', 'hai-huoc', GETDATE(), 1);
IF NOT EXISTS (SELECT 1 FROM Categories WHERE slug = 'tinh-cam')
    INSERT INTO Categories (name, slug, created_at, version) VALUES (N'Tình Cảm', 'tinh-cam', GETDATE(), 1);

SELECT @catAction = id FROM Categories WHERE slug = 'hanh-dong';
SELECT @catSciFi = id FROM Categories WHERE slug = 'vien-tuong';
SELECT @catAdventure = id FROM Categories WHERE slug = 'phieu-luu';
SELECT @catDrama = id FROM Categories WHERE slug = 'tam-ly';
SELECT @catHorror = id FROM Categories WHERE slug = 'kinh-di';
SELECT @catAnimation = id FROM Categories WHERE slug = 'hoat-hinh';
SELECT @catComedy = id FROM Categories WHERE slug = 'hai-huoc';
SELECT @catRomance = id FROM Categories WHERE slug = 'tinh-cam';

-- Seed 30+ Realistic Movies
DECLARE @movies TABLE (
    title NVARCHAR(200) COLLATE DATABASE_DEFAULT,
    slug VARCHAR(250) COLLATE DATABASE_DEFAULT,
    description NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
    release_year INT,
    duration_minutes INT,
    poster_url VARCHAR(1000) COLLATE DATABASE_DEFAULT,
    video_url VARCHAR(1000) COLLATE DATABASE_DEFAULT,
    trailer_url VARCHAR(1000) COLLATE DATABASE_DEFAULT,
    status VARCHAR(20) COLLATE DATABASE_DEFAULT,
    featured BIT,
    view_count BIGINT
);

INSERT INTO @movies VALUES
(N'Inception: Kẻ Đánh Cắp Giấc Mơ', 'inception', N'Một điệp viên chuyên xâm nhập vào tiềm thức của người khác để đánh cắp bí mật kinh doanh được trao nhiệm vụ bất khả thi: cấy ghép một ý tưởng vào tâm trí mục tiêu.', 2010, 148, 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 1, 15420),
(N'Interstellar: Hố Đen Tử Thần', 'interstellar', N'Khi Trái Đất dần cạn kiệt tài nguyên, một nhóm phi hành gia du hành qua một lỗ sâu bí ẩn gần sao Thổ nhằm tìm kiếm hành tinh mới để cứu lấy tương lai nhân loại.', 2014, 169, 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'PUBLISHED', 1, 23810),
(N'The Dark Knight: Kỵ Sĩ Bóng Đêm', 'the-dark-knight', N'Khi kẻ hỗn loạn Joker xuất hiện tàn phá thành phố Gotham, Người Dơi phải chấp nhận đối mặt với ranh giới mong manh giữa công lý và sự hy sinh bản thân.', 2008, 152, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 1, 31200),
(N'Dune: Hành Tinh Cát (Phần 1)', 'dune-part-1', N'Paul Atreides, một người thừa kế mang số phận vĩ đại, phải du hành đến hành tinh nguy hiểm nhất vũ trụ Arrakis để bảo vệ gia tộc và thần dân của mình.', 2021, 155, 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'PUBLISHED', 1, 18940),
(N'Dune: Hành Tinh Cát (Phần 2)', 'dune-part-2', N'Paul Atreides hợp lực cùng Chani và tộc người Fremen để trả thù những kẻ đã hủy diệt gia đình anh, đối mặt với ngã rẽ giữa tình yêu và định mệnh vũ trụ.', 2024, 166, 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 1, 27500),
(N'Oppenheimer', 'oppenheimer', N'Câu chuyện cuộc đời của nhà vật lý lý thuyết J. Robert Oppenheimer, người lãnh đạo dự án Manhattan chế tạo ra quả bom nguyên tử đầu tiên trong Thế chiến thứ II.', 2023, 180, 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'PUBLISHED', 1, 29400),
(N'Avatar: Dòng Chảy Của Nước', 'avatar-the-way-of-water', N'Hơn một thập kỷ sau sự kiện phần một, Jake Sully và Neytiri phải rời bỏ quê hương rừng xanh để tìm nơi trú ẩn tại các rạn san hô kỳ vĩ của hành tinh Pandora.', 2022, 192, 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 0, 19800),
(N'Ký Sinh Trùng (Parasite)', 'parasite', N'Một gia đình nghèo từng bước thâm nhập vào cuộc sống hào nhoáng của một gia đình giàu có ở Seoul, mở ra bi kịch khốc liệt phản ánh sự phân hóa xã hội.', 2019, 132, 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'PUBLISHED', 1, 21500),
(N'Vùng Đất Linh Hồn (Spirited Away)', 'spirited-away', N'Cô bé Chihiro mười tuổi vô tình lạc vào thế giới của các linh hồn và thần linh, nơi cô phải nỗ lực làm việc để giải cứu cha mẹ đã bị biến thành heo.', 2001, 125, 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 1, 16300),
(N'Người Nhện: Du Hành Vũ Trụ Nhện', 'spider-man-across-the-spider-verse', N'Miles Morales du hành qua đa vũ trụ để bảo vệ sự tồn vong của thế giới, nhưng bất ngờ phải đối đầu với một liên minh Người Nhện vì quan điểm cứu rỗi.', 2023, 140, 'https://images.unsplash.com/photo-1635805737707-575885ab0820?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'PUBLISHED', 1, 22100),
(N'Lạc Vào Xứ Oz', 'oz-the-great-and-powerful', N'Một ảo thuật gia gánh xiếc tình cờ bay lạc đến xứ sở kỳ diệu Oz và phải trở thành vị phù thủy vĩ đại bảo vệ vương quốc khỏi mụ phù thủy hắc ám.', 2013, 130, 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80', NULL, NULL, 'PUBLISHED', 0, 7800),
(N'Chuyến Tàu Sinh Tử (Train to Busan)', 'train-to-busan', N'Một đại dịch xác sống bất ngờ bùng phát khắp Hàn Quốc trong lúc đoàn tàu lửa chở hai cha con đang tăng tốc đến vùng an toàn cuối cùng ở Busan.', 2016, 118, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 0, 14200),
(N'Ma Trận (The Matrix)', 'the-matrix', N'Một lập trình viên phát hiện ra rằng thực tại mà anh đang sống chỉ là một mô phỏng máy tính tinh vi do máy móc thống trị tạo ra để nô dịch con người.', 1999, 136, 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'PUBLISHED', 0, 18400),
(N'Ám Ảnh Kinh Hoàng (The Conjuring)', 'the-conjuring', N'Hai nhà điều tra hiện tượng siêu nhiên Ed và Lorraine Warren đến trợ giúp một gia đình bị khủng bố bởi linh hồn tà ác trong trang trại hẻo lánh.', 2013, 112, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 0, 9800),
(N'Kẻ Trộm Mặt Trăng 4 (Despicable Me 4)', 'despicable-me-4', N'Gru và gia đình bước vào một chương mới khi đối mặt với kẻ thù nguy hiểm Maxime Le Mal, buộc họ phải chuyển nơi ẩn náu cùng các chú Minion quậy phá.', 2024, 94, 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'PUBLISHED', 0, 12600),
(N'Nhà Bà Nữ', 'nha-ba-nu', N'Câu chuyện xoay quanh quán bánh canh cua của bà Nữ và những mâu thuẫn thế hệ, định kiến trong một gia đình lao động tại Sài Gòn.', 2023, 102, 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=600&q=80', NULL, NULL, 'PUBLISHED', 0, 16700),
(N'Mai', 'mai', N'Hành trình tình yêu đầy thăng trầm giữa Mai, một phụ nữ làm nghề mát-xa chịu nhiều định kiến, và Dương, chàng nhạc công lãng tử nhà giàu.', 2024, 131, 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80', NULL, NULL, 'PUBLISHED', 1, 28100),
(N'Bố Già (The Godfather)', 'the-godfather', N'Biên niên sử về gia tộc mafia Corleone hùng mạnh ở New York và sự chuyển giao quyền lực bi kịch giữa người cha Vito và con trai Michael.', 1972, 175, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 0, 35000),
(N'Hố Sâu Đói Khát (The Platform)', 'the-platform', N'Một nhà tù thẳng đứng nơi thức ăn được thả từ tầng cao nhất xuống, buộc các tù nhân ở tầng dưới phải chiến đấu để sinh tồn trong hoàn cảnh khắc nghiệt.', 2019, 94, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'PUBLISHED', 0, 8400),
(N'Đất Rừng Phương Nam', 'dat-rung-phuong-nam', N'Hành trình tìm cha đầy thử thách của cậu bé An qua khắp các miền sông nước Nam Bộ trù phú trong bối cảnh kháng chiến chống Pháp đầu thế kỷ 20.', 2023, 134, 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=600&q=80', NULL, NULL, 'PUBLISHED', 0, 11200),
(N'Vùng Đất Câm Lặng (A Quiet Place)', 'a-quiet-place', N'Một gia đình phải sống trong im lặng tuyệt đối tại một vùng quê hoang vắng để tránh sự săn lùng tàn bạo của những sinh vật ngoài hành tinh nhạy bén với âm thanh.', 2018, 90, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 0, 13800),
(N'Mad Max: Con Đường Tử Thần', 'mad-max-fury-road', N'Trong một tương lai hậu tận thế khô cằn, Max Điên hợp tác cùng Furiosa dũng cảm nhằm giải cứu một nhóm phụ nữ khỏi tay tên bạo chúa khát máu Immortan Joe.', 2015, 120, 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'PUBLISHED', 0, 17200),
(N'Gia Đình Siêu Nhân 2 (Incredibles 2)', 'incredibles-2', N'Trong khi Elastigirl đảm nhận sứ mệnh lấy lại niềm tin cho các siêu anh hùng, Bob Parr phải ở nhà trông nom ba đứa con với những siêu năng lực bùng nổ.', 2018, 118, 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=600&q=80', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'PUBLISHED', 0, 15300),
(N'Bi Kịch Của Macbeth', 'the-tragedy-of-macbeth', N'Một vị tướng tài ba nghe lời tiên tri của ba mụ phù thủy và sự giục giã của người vợ đầy tham vọng đã quyết định sát hại nhà vua để chiếm ngai vàng.', 2021, 105, 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=600&q=80', NULL, NULL, 'PUBLISHED', 0, 4200),
(N'Dự Án Phim Mới: Thần Thoại (DRAFT)', 'du-an-than-thoai-draft', N'Dự án phim điện ảnh thần thoại đang trong quá trình tiền kỳ kịch bản và chuẩn bị quay, chưa công bố trailer chính thức.', 2026, 120, 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80', NULL, NULL, 'DRAFT', 0, 0),
(N'Dự Án Hoạt Hình Bí Ẩn (DRAFT)', 'hoat-hinh-bi-an-draft', N'Dự án phim hoạt hình gia đình phong cách 3D đang được vẽ phác thảo nhân vật.', 2026, 95, NULL, NULL, NULL, 'DRAFT', 0, 0),
(N'Bộ Phim Đã Ẩn (HIDDEN)', 'phim-tam-thoi-an-hidden', N'Bộ phim tạm thời bị ẩn khỏi danh mục công khai vì lý do bản quyền kiểm duyệt.', 2020, 110, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', NULL, NULL, 'HIDDEN', 0, 210);

-- Insert movies if not present
INSERT INTO Movies (title, slug, description, release_year, duration_minutes, poster_url, video_url, trailer_url, status, featured, view_count, created_at, updated_at, version)
SELECT m.title, m.slug, m.description, m.release_year, m.duration_minutes, m.poster_url, m.video_url, m.trailer_url, m.status, m.featured, m.view_count, GETDATE(), GETDATE(), 1
FROM @movies m
WHERE NOT EXISTS (SELECT 1 FROM Movies existing WHERE existing.slug = m.slug);

-- Link Categories to Movies
INSERT INTO MovieCategories (movie_id, category_id)
SELECT m.id, @catAction FROM Movies m WHERE m.slug IN ('inception', 'the-dark-knight', 'mad-max-fury-road', 'train-to-busan', 'the-matrix', 'spider-man-across-the-spider-verse')
AND NOT EXISTS (SELECT 1 FROM MovieCategories mc WHERE mc.movie_id = m.id AND mc.category_id = @catAction);

INSERT INTO MovieCategories (movie_id, category_id)
SELECT m.id, @catSciFi FROM Movies m WHERE m.slug IN ('inception', 'interstellar', 'dune-part-1', 'dune-part-2', 'the-matrix', 'avatar-the-way-of-water')
AND NOT EXISTS (SELECT 1 FROM MovieCategories mc WHERE mc.movie_id = m.id AND mc.category_id = @catSciFi);

INSERT INTO MovieCategories (movie_id, category_id)
SELECT m.id, @catAdventure FROM Movies m WHERE m.slug IN ('interstellar', 'dune-part-1', 'dune-part-2', 'spirited-away', 'oz-the-great-and-powerful', 'dat-rung-phuong-nam')
AND NOT EXISTS (SELECT 1 FROM MovieCategories mc WHERE mc.movie_id = m.id AND mc.category_id = @catAdventure);

INSERT INTO MovieCategories (movie_id, category_id)
SELECT m.id, @catDrama FROM Movies m WHERE m.slug IN ('oppenheimer', 'parasite', 'the-godfather', 'mai', 'nha-ba-nu', 'the-tragedy-of-macbeth')
AND NOT EXISTS (SELECT 1 FROM MovieCategories mc WHERE mc.movie_id = m.id AND mc.category_id = @catDrama);

INSERT INTO MovieCategories (movie_id, category_id)
SELECT m.id, @catHorror FROM Movies m WHERE m.slug IN ('the-conjuring', 'train-to-busan', 'a-quiet-place', 'the-platform')
AND NOT EXISTS (SELECT 1 FROM MovieCategories mc WHERE mc.movie_id = m.id AND mc.category_id = @catHorror);

INSERT INTO MovieCategories (movie_id, category_id)
SELECT m.id, @catAnimation FROM Movies m WHERE m.slug IN ('spirited-away', 'spider-man-across-the-spider-verse', 'despicable-me-4', 'incredibles-2')
AND NOT EXISTS (SELECT 1 FROM MovieCategories mc WHERE mc.movie_id = m.id AND mc.category_id = @catAnimation);

INSERT INTO MovieCategories (movie_id, category_id)
SELECT m.id, @catComedy FROM Movies m WHERE m.slug IN ('despicable-me-4', 'incredibles-2', 'nha-ba-nu')
AND NOT EXISTS (SELECT 1 FROM MovieCategories mc WHERE mc.movie_id = m.id AND mc.category_id = @catComedy);

INSERT INTO MovieCategories (movie_id, category_id)
SELECT m.id, @catRomance FROM Movies m WHERE m.slug IN ('mai')
AND NOT EXISTS (SELECT 1 FROM MovieCategories mc WHERE mc.movie_id = m.id AND mc.category_id = @catRomance);

-- Seed Favorites (18 favorites)
DECLARE @uTuan BIGINT, @uMai BIGINT, @uDuc BIGINT, @uLan BIGINT, @uHoang BIGINT;
SELECT @uTuan = id FROM Users WHERE email = 'tuan.nguyen@moviehub.vn';
SELECT @uMai = id FROM Users WHERE email = 'mai.le@moviehub.vn';
SELECT @uDuc = id FROM Users WHERE email = 'duc.tran@moviehub.vn';
SELECT @uLan = id FROM Users WHERE email = 'lan.pham@moviehub.vn';
SELECT @uHoang = id FROM Users WHERE email = 'hoang.vu@moviehub.vn';

INSERT INTO Favorites (user_id, movie_id, created_at)
SELECT @uTuan, m.id, GETDATE() FROM Movies m WHERE m.slug IN ('interstellar', 'inception', 'dune-part-1', 'the-dark-knight')
AND NOT EXISTS (SELECT 1 FROM Favorites f WHERE f.user_id = @uTuan AND f.movie_id = m.id);

INSERT INTO Favorites (user_id, movie_id, created_at)
SELECT @uMai, m.id, GETDATE() FROM Movies m WHERE m.slug IN ('spirited-away', 'mai', 'parasite', 'spider-man-across-the-spider-verse')
AND NOT EXISTS (SELECT 1 FROM Favorites f WHERE f.user_id = @uMai AND f.movie_id = m.id);

INSERT INTO Favorites (user_id, movie_id, created_at)
SELECT @uDuc, m.id, GETDATE() FROM Movies m WHERE m.slug IN ('oppenheimer', 'the-godfather', 'dune-part-2')
AND NOT EXISTS (SELECT 1 FROM Favorites f WHERE f.user_id = @uDuc AND f.movie_id = m.id);

INSERT INTO Favorites (user_id, movie_id, created_at)
SELECT @uLan, m.id, GETDATE() FROM Movies m WHERE m.slug IN ('the-conjuring', 'a-quiet-place', 'train-to-busan')
AND NOT EXISTS (SELECT 1 FROM Favorites f WHERE f.user_id = @uLan AND f.movie_id = m.id);

INSERT INTO Favorites (user_id, movie_id, created_at)
SELECT @uHoang, m.id, GETDATE() FROM Movies m WHERE m.slug IN ('incredibles-2', 'despicable-me-4', 'the-matrix', 'mad-max-fury-road')
AND NOT EXISTS (SELECT 1 FROM Favorites f WHERE f.user_id = @uHoang AND f.movie_id = m.id);

-- Seed Reviews (20+ reviews)
DECLARE @uAdmin BIGINT;
SELECT @uAdmin = id FROM Users WHERE email = 'admin@moviehub.vn';

DECLARE @mInterstellar BIGINT, @mInception BIGINT, @mDarkKnight BIGINT, @mDune1 BIGINT, @mDune2 BIGINT, @mOppenheimer BIGINT, @mParasite BIGINT, @mSpiritedAway BIGINT;
SELECT @mInterstellar = id FROM Movies WHERE slug = 'interstellar';
SELECT @mInception = id FROM Movies WHERE slug = 'inception';
SELECT @mDarkKnight = id FROM Movies WHERE slug = 'the-dark-knight';
SELECT @mDune1 = id FROM Movies WHERE slug = 'dune-part-1';
SELECT @mDune2 = id FROM Movies WHERE slug = 'dune-part-2';
SELECT @mOppenheimer = id FROM Movies WHERE slug = 'oppenheimer';
SELECT @mParasite = id FROM Movies WHERE slug = 'parasite';
SELECT @mSpiritedAway = id FROM Movies WHERE slug = 'spirited-away';

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uTuan AND movie_id = @mInterstellar)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uTuan, @mInterstellar, 5, N'Tác phẩm khoa học viễn tưởng vĩ đại nhất của Christopher Nolan! Nhạc phim của Hans Zimmer thật sự xuất sắc.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -10, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uMai AND movie_id = @mInterstellar)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uMai, @mInterstellar, 5, N'Tình cha con giữa Cooper và Murph đã lấy đi rất nhiều nước mắt của mình. Đoạn thông điệp qua kim đồng hồ thật xúc động.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -8, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uDuc AND movie_id = @mInception)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uDuc, @mInception, 5, N'Kịch bản phân tầng giấc mơ quá xuất sắc. Cảnh quay hành lang xoay tròn vẫn là đỉnh cao của kỹ xảo thực tế.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -12, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uLan AND movie_id = @mDarkKnight)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uLan, @mDarkKnight, 5, N'Diễn xuất của Heath Ledger trong vai Joker xứng đáng là huyền thoại điện ảnh thế giới.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -14, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uHoang AND movie_id = @mDune1)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uHoang, @mDune1, 4, N'Hình ảnh hoành tráng, thiết kế âm thanh choáng ngợp. Nhịp phim nửa đầu hơi chậm nhưng càng về sau càng hấp dẫn.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -6, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uTuan AND movie_id = @mDune2)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uTuan, @mDune2, 5, N'Phần 2 bùng nổ vượt bậc so với phần 1! Trận chiến trên sa mạc và màn cưỡi sâu cát mãn nhãn không thể tin nổi.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -4, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uMai AND movie_id = @mParasite)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uMai, @mParasite, 5, N'Một tác phẩm châm biếm sâu sắc và tàn nhẫn về khoảng cách giàu nghèo. Cú plot twist ở căn hầm khiến người xem chết lặng.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -5, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uDuc AND movie_id = @mOppenheimer)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uDuc, @mOppenheimer, 5, N'Phim tiểu sử nhưng nhịp độ căng thẳng nghẹt thở như một phim gián điệp trinh thám. Cillian Murphy diễn xuất đỉnh cao.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -3, GETDATE()), GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uLan AND movie_id = @mSpiritedAway)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uLan, @mSpiritedAway, 5, N'Một thế giới cổ tích kỳ ảo chứa đựng những bài học trưởng thành tuyệt vời từ Studio Ghibli.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -7, GETDATE()), GETDATE(), 1, 1);

-- Reviews in PENDING status (awaiting admin moderation)
IF NOT EXISTS (SELECT 1 FROM Reviews WHERE user_id = @uHoang AND movie_id = @mOppenheimer)
    INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
    VALUES (@uHoang, @mOppenheimer, 4, N'Thời lượng 3 tiếng hơi dài đối với người không rành lịch sử Mỹ nhưng cảnh thử bom Trinity rất ấn tượng.', 'PENDING', NULL, NULL, GETDATE(), GETDATE(), 1, 1);

-- Seed Questions & Answers
DECLARE @q1 BIGINT, @q2 BIGINT, @q3 BIGINT;

IF NOT EXISTS (SELECT 1 FROM Questions WHERE movie_id = @mInterstellar AND user_id = @uDuc)
BEGIN
    INSERT INTO Questions (movie_id, user_id, content, status, moderated_by, moderated_at, created_at, version)
    VALUES (@mInterstellar, @uDuc, N'Vì sao 1 giờ ở hành tinh nước của Miller lại bằng 7 năm trên Trái Đất?', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -5, GETDATE()), 1);
    SET @q1 = SCOPE_IDENTITY();

    INSERT INTO Answers (question_id, user_id, content, status, moderated_by, moderated_at, created_at, version)
    VALUES (@q1, @uTuan, N'Do hành tinh Miller nằm rất gần siêu lỗ đen Gargantua, trường hấp dẫn khổng lồ đã bẻ cong không thời gian theo thuyết tương đối rộng của Einstein.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -4, GETDATE()), 1);
END;

IF NOT EXISTS (SELECT 1 FROM Questions WHERE movie_id = @mInception AND user_id = @uLan)
BEGIN
    INSERT INTO Questions (movie_id, user_id, content, status, moderated_by, moderated_at, created_at, version)
    VALUES (@mInception, @uLan, N'Con quay ở cuối phim có dừng lại không mọi người ơi?', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -3, GETDATE()), 1);
    SET @q2 = SCOPE_IDENTITY();

    INSERT INTO Answers (question_id, user_id, content, status, moderated_by, moderated_at, created_at, version)
    VALUES (@q2, @uMai, N'Đạo diễn Christopher Nolan từng chia sẻ rằng điểm cốt lõi là Cobb đã không còn quan tâm con quay có ngã hay không, vì anh đã chấp nhận thực tại hạnh phúc bên các con.', 'APPROVED', @uAdmin, GETDATE(), DATEADD(DAY, -2, GETDATE()), 1);
END;

IF NOT EXISTS (SELECT 1 FROM Questions WHERE movie_id = @mDune1 AND user_id = @uHoang)
BEGIN
    INSERT INTO Questions (movie_id, user_id, content, status, moderated_by, moderated_at, created_at, version)
    VALUES (@mDune1, @uHoang, N'Hương dược (Spice) trên hành tinh cát có tác dụng gì quan trọng nhất?', 'PENDING', NULL, NULL, GETDATE(), 1);
END;

PRINT 'MovieHub schema verification and seed execution finished successfully!';
