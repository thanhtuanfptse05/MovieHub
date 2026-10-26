-- =========================================================================
-- MovieHub | 08_seed_qa.sql
-- Hỏi & Đáp: 28 câu hỏi và 40 câu trả lời của cộng đồng.
--   * Câu trả lời chỉ gắn với câu hỏi đã được duyệt (APPROVED).
--   * Có đủ ba trạng thái APPROVED / PENDING / REJECTED để kiểm thử trang kiểm duyệt.
-- =========================================================================
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

USE MovieHub;
GO

DECLARE @admin bigint = (SELECT id FROM dbo.Users WHERE email = 'admin@moviehub.vn');
IF @admin IS NULL THROW 51002, N'Chưa có tài khoản admin. Hãy chạy 03_seed_users.sql trước.', 1;

-- ---------------------------------------------------------------------
-- Câu hỏi
-- ---------------------------------------------------------------------
DECLARE @q TABLE (
    qkey        int,
    email_local varchar(100),
    movie_slug  varchar(250) COLLATE Latin1_General_100_BIN2,
    status      varchar(10)  COLLATE Latin1_General_100_BIN2,
    content     nvarchar(500)
);

INSERT INTO @q (qkey, email_local, movie_slug, status, content) VALUES
(1,  'duc.tran',    'interstellar',  'APPROVED', N'Vì sao 1 giờ ở hành tinh nước của Miller lại bằng 7 năm trên Trái Đất?'),
(2,  'lan.pham',    'inception',     'APPROVED', N'Con quay ở cuối phim có dừng lại không mọi người ơi?'),
(3,  'hoang.vu',    'dune-part-1',   'PENDING',  N'Hương dược (Spice) trên hành tinh cát có tác dụng gì quan trọng nhất?'),
(4,  'bao.huynh',   'the-dark-knight', 'APPROVED', N'Tại sao Batman nhận hết tội về mình ở cuối phim vậy mọi người?'),
(5,  'linh.bui',    'oppenheimer',   'APPROVED', N'Phim dùng cảnh đen trắng và cảnh màu xen kẽ có ý nghĩa gì vậy ạ?'),
(6,  'thao.nguyen', 'mai',           'APPROVED', N'Bài hát nhạc phim Mai tên là gì vậy mọi người, nghe hay quá?'),
(7,  'long.vo',     'parasite',      'APPROVED', N'Mùi hương của gia đình Ki-taek có ý nghĩa gì trong phim vậy mọi người?'),
(8,  'trang.do',    'spirited-away', 'APPROVED', N'Phim này có phù hợp cho bé 6 tuổi xem không ạ? Mình sợ có cảnh đáng sợ.'),
(9,  'khoa.dang',   'the-matrix',    'APPROVED', N'Neo chọn viên thuốc đỏ thật ra có ý nghĩa gì với người xem hiện đại?'),
(10, 'vy.phan',     'nha-ba-nu',     'PENDING',  N'Ai biết quán bánh canh trong phim được quay ở đâu không ạ?'),
(11, 'quan.ngo',    'dat-rung-phuong-nam', 'APPROVED', N'Phim được chuyển thể từ tác phẩm văn học nào vậy mọi người?'),
(12, 'long.vo',     'the-platform',  'APPROVED', N'Cái kết của The Platform có nghĩa là gì vậy, mình xem xong vẫn chưa hiểu?'),
(13, 'duc.tran',    'mad-max-fury-road', 'APPROVED', N'Phim này có cần xem ba phần trước để hiểu cốt truyện không ạ?'),
(14, 'lan.pham',    'the-conjuring', 'APPROVED', N'Phim này dựa trên câu chuyện có thật phải không mọi người?'),
(15, 'hoang.vu',    'despicable-me-4', 'APPROVED', N'Phim có cảnh sau credit không các bạn? Mình sợ ra về sớm bị lỡ mất.'),
(16, 'yen.truong',  'spider-man-across-the-spider-verse', 'APPROVED', N'Phim này có cần xem phần 1 trước không ạ?'),
(17, 'phuc.dinh',   'dune-part-2',   'APPROVED', N'Mình chưa xem phần 1 thì xem thẳng phần 2 được không mọi người?'),
(18, 'ngoc.ly',     'mai',           'APPROVED', N'Phim có phù hợp để cả gia đình cùng xem không ạ?'),
(19, 'son.hoang',   'the-godfather', 'APPROVED', N'Nên xem theo thứ tự phần 1 rồi mới đến phần 2 đúng không mọi người?'),
(20, 'thao.nguyen', 'oz-the-great-and-powerful', 'APPROVED', N'Phim này có liên quan gì đến bộ phim Phù thủy xứ Oz bản cũ không ạ?'),
(21, 'bao.huynh',   'inception',     'REJECTED', N'Cho mình xin link tải phim full HD không che với các bạn ơi.'),
(22, 'linh.bui',    'the-tragedy-of-macbeth', 'APPROVED', N'Phim này có bám sát vở kịch gốc của Shakespeare không ạ?'),
(23, 'trang.do',    'incredibles-2', 'PENDING',  N'Bé nhà mình 4 tuổi xem phim này được không các bạn?'),
(24, 'lan.pham',    'a-quiet-place', 'APPROVED', N'Phim có nhiều cảnh máu me không ạ, mình hơi nhát gan?'),
(25, 'hoang.vu',    'avatar-the-way-of-water', 'APPROVED', N'Xem bản 3D hay 2D thì đẹp hơn vậy mọi người?'),
(26, 'mai.le',      'train-to-busan', 'APPROVED', N'Phim này có đáng sợ như phim zombie phương Tây không ạ?'),
(27, 'tuan.nguyen', 'oppenheimer',   'APPROVED', N'Mình chưa rành lịch sử Mỹ thì xem phim có hiểu được không ạ?'),
(28, 'bao.huynh',   'interstellar',  'PENDING',  N'Cảnh trong căn phòng sách của Murph ở đoạn cuối là gì vậy, mình hơi rối?');

-- Thời gian: câu hỏi đã xử lý nằm trong khoảng [ngày mới nhất giữa đăng ký/phim tạo .. 8 ngày trước];
-- câu hỏi chờ duyệt nằm trong 3 ngày gần nhất.
INSERT INTO dbo.Questions (movie_id, user_id, content, status, moderated_by, moderated_at, created_at, version)
SELECT s.movie_id, s.user_id, s.content, s.status,
       CASE WHEN s.status = 'PENDING' THEN NULL ELSE @admin END,
       CASE WHEN s.status = 'PENDING' THEN NULL
            ELSE DATEADD(MINUTE, 45 + ABS(CHECKSUM(s.user_id, s.movie_id, 3)) % 1200, s.created_at) END,
       s.created_at, 1
FROM (
    SELECT u.id AS user_id, m.id AS movie_id, q.content, q.status,
           CASE WHEN q.status = 'PENDING'
                THEN DATEADD(MINUTE, -(20 + ABS(CHECKSUM(q.qkey, 11)) % 4000), SYSUTCDATETIME())
                ELSE DATEADD(MINUTE,
                             ABS(CHECKSUM(q.qkey, u.id)) % NULLIF(DATEDIFF(MINUTE,
                                 CASE WHEN u.created_at > m.created_at THEN u.created_at ELSE m.created_at END,
                                 DATEADD(DAY, -8, SYSUTCDATETIME())), 0),
                             CASE WHEN u.created_at > m.created_at THEN u.created_at ELSE m.created_at END)
           END AS created_at
    FROM @q q
    JOIN dbo.Users  u ON u.email = q.email_local + '@moviehub.vn'
    JOIN dbo.Movies m ON m.slug  = q.movie_slug AND m.status = 'PUBLISHED'
) s
WHERE NOT EXISTS (SELECT 1 FROM dbo.Questions x
                  WHERE x.movie_id = s.movie_id AND x.user_id = s.user_id AND x.content = s.content);

-- ---------------------------------------------------------------------
-- Câu trả lời (chỉ cho câu hỏi đã được duyệt)
-- ---------------------------------------------------------------------
DECLARE @a TABLE (
    qkey        int,
    email_local varchar(100),
    status      varchar(10) COLLATE Latin1_General_100_BIN2,
    content     nvarchar(1000)
);

INSERT INTO @a (qkey, email_local, status, content) VALUES
(1,  'tuan.nguyen', 'APPROVED', N'Do hành tinh Miller nằm rất gần siêu lỗ đen Gargantua, trường hấp dẫn khổng lồ đã bẻ cong không thời gian theo thuyết tương đối rộng của Einstein.'),
(1,  'quan.ngo',    'APPROVED', N'Bổ sung thêm: Nolan đã nhờ nhà vật lý Kip Thorne tư vấn nên hiệu ứng giãn nở thời gian trong phim khá sát với lý thuyết thật.'),
(2,  'mai.le',      'APPROVED', N'Đạo diễn Christopher Nolan từng chia sẻ rằng điểm cốt lõi là Cobb đã không còn quan tâm con quay có ngã hay không, vì anh đã chấp nhận thực tại hạnh phúc bên các con.'),
(2,  'khoa.dang',   'APPROVED', N'Nhiều người để ý chiếc nhẫn cưới: trong giấc mơ Cobb luôn đeo nhẫn, còn ngoài đời thì không. Ở cảnh cuối anh không đeo nhẫn nên có thể đó là thực tại.'),
(2,  'phuc.dinh',   'PENDING',  N'Mình thấy con quay hơi chao đảo trước khi màn hình tắt, nhưng chưa chắc nó sẽ đổ.'),
(4,  'son.hoang',   'APPROVED', N'Vì Batman muốn giữ hình ảnh Harvey Dent như biểu tượng hy vọng của Gotham. Nếu người dân biết Dent đã giết người thì niềm tin vào công lý sẽ sụp đổ.'),
(4,  'duc.tran',    'APPROVED', N'Ngoài ra đây cũng là sự hy sinh của Bruce: anh chấp nhận trở thành kẻ bị truy nã để thành phố có một người hùng mà họ tin tưởng.'),
(5,  'quan.ngo',    'APPROVED', N'Cảnh màu là góc nhìn chủ quan của Oppenheimer, còn cảnh đen trắng là góc nhìn của Strauss, mang tính khách quan hơn. Nolan dùng hai kiểu hình ảnh để phân biệt hai dòng thời gian.'),
(6,  'ngoc.ly',     'APPROVED', N'Đó là bài Sau Lời Từ Khước của Phan Mạnh Quỳnh, bạn có thể nghe MV chính thức trong phần video của phim nhé.'),
(7,  'vy.phan',     'APPROVED', N'Mùi là chi tiết tượng trưng cho giai cấp. Dù ăn mặc sang trọng thì gia đình Ki-taek vẫn không thoát khỏi mùi của căn hầm nghèo, và ông chủ Park luôn nhắc đến điều đó.'),
(7,  'linh.bui',    'APPROVED', N'Chính câu nói về mùi hương đó cũng là giọt nước làm Ki-taek bùng nổ ở cảnh cuối.'),
(8,  'yen.truong',  'APPROVED', N'Mình cho bé 7 tuổi xem rồi, hơi sợ ở cảnh Vô Diện nhưng nhìn chung bé rất thích. Bạn nên xem cùng con nhé.'),
(8,  'lan.pham',    'APPROVED', N'Phim phù hợp mọi lứa tuổi nhưng có vài cảnh kỳ ảo hơi tối. Bạn thử xem trước phần đầu cùng con xem bé phản ứng thế nào.'),
(9,  'bao.huynh',   'APPROVED', N'Viên thuốc đỏ là lựa chọn đối diện với sự thật dù khó chịu, còn viên thuốc xanh là tiếp tục sống trong sự an toàn giả tạo.'),
(9,  'hoang.vu',    'PENDING',  N'Mình thấy viên thuốc đỏ giống việc bỏ điện thoại xuống và nhìn thế giới thật xung quanh.'),
(11, 'thao.nguyen', 'APPROVED', N'Phim chuyển thể từ tiểu thuyết Đất rừng phương Nam của nhà văn Đoàn Giỏi, xuất bản năm 1957.'),
(12, 'khoa.dang',   'APPROVED', N'Cô bé chính là thông điệp, không phải bữa ăn. Goreng gửi đi thông điệp rằng hệ thống chỉ thay đổi nếu những người ở tầng trên biết chia sẻ.'),
(13, 'son.hoang',   'APPROVED', N'Không cần nhé, Fury Road là phim độc lập, bạn có thể xem thẳng.'),
(13, 'hoang.vu',    'APPROVED', N'Mình cũng xem thẳng phần này mà vẫn hiểu hết. Các phần cũ chỉ giúp bạn hiểu thế giới rộng hơn một chút.'),
(13, 'long.vo',     'REJECTED', N'Link xem phim miễn phí ở đây nhé các bạn, vào ngay kẻo hết.'),
(14, 'long.vo',     'APPROVED', N'Phim lấy cảm hứng từ hồ sơ có thật của vợ chồng Ed và Lorraine Warren, nhưng nhiều chi tiết đã được thêm thắt để kịch tính hơn.'),
(15, 'trang.do',    'APPROVED', N'Có đấy, vẫn còn một cảnh Minions ở cuối nên bạn ở lại thêm chút nhé.'),
(16, 'bao.huynh',   'APPROVED', N'Nên xem phần 1 trước, vì phần 2 tiếp nối trực tiếp và nhiều nhân vật được nhắc lại.'),
(17, 'tuan.nguyen', 'APPROVED', N'Có thể xem được nhưng bạn sẽ bỏ lỡ nhiều chi tiết về gia tộc và hành trình của Paul, nên xem phần 1 trước thì tốt hơn.'),
(18, 'mai.le',      'APPROVED', N'Phim có chủ đề tình cảm của người lớn nên mình nghĩ phù hợp với khán giả từ tuổi teen trở lên.'),
(19, 'duc.tran',    'APPROVED', N'Đúng rồi bạn, phần 2 vừa kể tiếp vừa kể quá khứ của Vito nên phải xem phần 1 trước.'),
(20, 'trang.do',    'APPROVED', N'Đây là phần tiền truyện, kể về nguồn gốc của ông phù thủy trước khi Dorothy đến xứ Oz.'),
(20, 'admin',       'APPROVED', N'Bạn có thể xem thêm phim Phù thủy xứ Oz năm 1939 để thấy rõ các chi tiết được nhắc lại trong phần tiền truyện này.'),
(22, 'vy.phan',     'APPROVED', N'Phim bám rất sát thoại và cốt truyện của vở kịch gốc, chỉ khác ở phần dàn dựng đen trắng và bối cảnh sân khấu hóa.'),
(24, 'long.vo',     'APPROVED', N'Có vài cảnh căng thẳng và máu nhưng không quá nhiều. Chủ yếu là hồi hộp vì sự im lặng.'),
(25, 'khoa.dang',   'APPROVED', N'Bản 3D đáng tiền hơn hẳn, đặc biệt các cảnh dưới nước có chiều sâu rất đẹp. Nên chọn rạp có IMAX 3D nếu được.'),
(25, 'phuc.dinh',   'APPROVED', N'Mình xem cả hai bản, 3D cho trải nghiệm tốt hơn nhưng cần kính vừa vặn, nếu hay bị đau đầu thì bạn chọn 2D.'),
(26, 'lan.pham',    'APPROVED', N'Nhịp phim nhanh, zombie cũng ghê hơn nhưng quan trọng là cảm xúc. Mình thấy cảm động nhiều hơn đáng sợ.'),
(27, 'duc.tran',    'APPROVED', N'Bạn nên đọc sơ qua về dự án Manhattan trước khi xem. Dù vậy phim vẫn dễ theo dõi nhờ diễn xuất và nhịp dựng.'),
(27, 'quan.ngo',    'APPROVED', N'Mình xem mà không biết gì về lịch sử vẫn hiểu được phần lớn, chỉ cần chú ý các mốc thời gian hiện trên màn hình.'),
(6,  'mai.le',      'APPROVED', N'Mình cũng rất thích bài này, nghe trong phim càng thấy hay hơn.'),
(12, 'lan.pham',    'APPROVED', N'Mình cũng xem xong phải đọc giải thích mới hiểu hết, đoạn cuối nhiều ẩn ý thật.'),
(16, 'mai.le',      'APPROVED', N'Mình xem thẳng phần 2 vẫn hiểu nhưng quay lại xem phần 1 thì mới thấy hết tình cảm giữa các nhân vật.'),
(18, 'thao.nguyen', 'APPROVED', N'Mình cũng nghĩ vậy, nhưng nếu có bé nhỏ thì nên cân nhắc vì có vài cảnh tình cảm người lớn.'),
(19, 'quan.ngo',    'APPROVED', N'Đúng thế, xem hết cả ba phần thì mới thấy trọn vẹn bi kịch của gia đình Corleone.');

-- Thời gian: câu trả lời luôn sau câu hỏi và sau ngày đăng ký của người trả lời.
INSERT INTO dbo.Answers (question_id, user_id, content, status, moderated_by, moderated_at, created_at, version)
SELECT s.question_id, s.user_id, s.content, s.status,
       CASE WHEN s.status = 'PENDING' THEN NULL ELSE @admin END,
       CASE WHEN s.status = 'PENDING' THEN NULL
            ELSE DATEADD(MINUTE, 30 + ABS(CHECKSUM(s.question_id, s.user_id, 5)) % 900, s.created_at) END,
       s.created_at, 1
FROM (
    SELECT qq.id AS question_id, au.id AS user_id, a.content, a.status,
           CASE WHEN a.status = 'PENDING'
                THEN DATEADD(MINUTE, -(15 + ABS(CHECKSUM(qq.id, au.id)) % 2500), SYSUTCDATETIME())
                ELSE DATEADD(MINUTE, 60 + ABS(CHECKSUM(qq.id, au.id)) % 1380,
                             CASE WHEN au.created_at > qq.created_at THEN au.created_at ELSE qq.created_at END)
           END AS created_at
    FROM @a a
    JOIN @q q ON q.qkey = a.qkey
    JOIN dbo.Users au ON au.email = a.email_local + '@moviehub.vn'
    JOIN dbo.Users qu ON qu.email = q.email_local + '@moviehub.vn'
    JOIN dbo.Movies m ON m.slug = q.movie_slug
    JOIN dbo.Questions qq ON qq.movie_id = m.id AND qq.user_id = qu.id AND qq.content = q.content
) s
WHERE NOT EXISTS (SELECT 1 FROM dbo.Answers x WHERE x.question_id = s.question_id AND x.user_id = s.user_id);

PRINT N'[08] Đã nạp hỏi đáp.';
GO
