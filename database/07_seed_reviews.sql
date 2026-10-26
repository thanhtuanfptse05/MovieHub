-- =========================================================================
-- MovieHub | 07_seed_reviews.sql
-- 105 đánh giá của thành viên cho 24 phim đã công khai.
--   * APPROVED : hiển thị công khai và được tính vào điểm trung bình
--   * PENDING  : đang chờ quản trị viên kiểm duyệt
--   * REJECTED : đã bị từ chối (spam / ngôn từ không phù hợp)
-- Mỗi thành viên chỉ đánh giá một lần cho mỗi phim (ràng buộc UQ_Reviews_UserMovie).
-- =========================================================================
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

USE MovieHub;
GO

DECLARE @admin bigint = (SELECT id FROM dbo.Users WHERE email = 'admin@moviehub.vn');
IF @admin IS NULL THROW 51001, N'Chưa có tài khoản admin. Hãy chạy 03_seed_users.sql trước.', 1;

DECLARE @r TABLE (
    email_local varchar(100),
    movie_slug  varchar(250) COLLATE Latin1_General_100_BIN2,
    rating      tinyint,
    status      varchar(10) COLLATE Latin1_General_100_BIN2,
    content     nvarchar(1000)
);

INSERT INTO @r (email_local, movie_slug, rating, status, content) VALUES
-- Inception
('tuan.nguyen', 'inception', 5, 'APPROVED', N'Kịch bản phân tầng giấc mơ cực kỳ thông minh. Xem lần thứ ba vẫn còn phát hiện thêm chi tiết mới, đặc biệt là cảnh hành lang xoay tròn.'),
('khoa.dang',   'inception', 5, 'APPROVED', N'Nolan làm phim đầu óc nhưng vẫn giải trí hết cỡ. Nhạc của Hans Zimmer ở đoạn cuối làm mình nổi cả da gà.'),
('bao.huynh',   'inception', 4, 'APPROVED', N'Phần giải thích luật chơi ở nửa đầu hơi nhiều thoại, nhưng từ đoạn tầng khách sạn trở đi thì cuốn không rời mắt được.'),
('phuc.dinh',   'inception', 5, 'APPROVED', N'Kết thúc mở với con quay là một trong những cái kết hay nhất mình từng xem. Xem xong ngồi cãi nhau với bạn cả buổi.'),
('thao.nguyen', 'inception', 3, 'APPROVED', N'Hình ảnh đẹp, diễn viên tốt nhưng mình thấy cốt truyện khá khó theo dõi, phải xem lại lần nữa mới hiểu hết.'),

-- Interstellar
('tuan.nguyen', 'interstellar', 5, 'APPROVED', N'Tác phẩm khoa học viễn tưởng vĩ đại nhất của Christopher Nolan! Nhạc phim của Hans Zimmer thật sự xuất sắc.'),
('mai.le',      'interstellar', 5, 'APPROVED', N'Tình cha con giữa Cooper và Murph đã lấy đi rất nhiều nước mắt của mình. Đoạn gửi thông điệp qua kim đồng hồ thật xúc động.'),
('quan.ngo',    'interstellar', 5, 'APPROVED', N'Cảnh bay qua hố đen Gargantua là một trải nghiệm thị giác khó quên. Phần khoa học trong phim cũng rất chắc chắn.'),
('phuc.dinh',   'interstellar', 4, 'APPROVED', N'Đoạn cuối trong không gian năm chiều hơi khó hiểu với mình nhưng cảm xúc thì trọn vẹn. Rất đáng xem ở rạp IMAX.'),
('khoa.dang',   'interstellar', 5, 'PENDING',  N'Xem lại sau mười năm vẫn thấy hay như lần đầu. Cảnh sóng thần trên hành tinh của Miller vẫn khiến mình nghẹt thở.'),

-- The Dark Knight
('lan.pham',    'the-dark-knight', 5, 'APPROVED', N'Diễn xuất của Heath Ledger trong vai Joker xứng đáng là huyền thoại của điện ảnh thế giới.'),
('bao.huynh',   'the-dark-knight', 5, 'APPROVED', N'Không chỉ là phim siêu anh hùng, đây còn là phim hình sự với những câu hỏi đạo đức rất sâu. Cảnh thẩm vấn quá đỉnh.'),
('son.hoang',   'the-dark-knight', 5, 'APPROVED', N'Màn cướp ngân hàng mở đầu quay bằng máy IMAX đến giờ vẫn là mẫu mực của phim hành động.'),
('duc.tran',    'the-dark-knight', 4, 'APPROVED', N'Phần ba của phim hơi dài vì có thêm nhân vật Harvey Dent, nhưng bù lại bi kịch của ông ấy rất thuyết phục.'),
('tuan.nguyen', 'the-dark-knight', 5, 'APPROVED', N'Phim siêu anh hùng hay nhất mọi thời đại, gần như không có gì để chê.'),
('yen.truong',  'the-dark-knight', 5, 'PENDING',  N'Xem lần đầu mà bị cuốn hẳn, nhất là đoạn Joker hóa trang thành y tá trong bệnh viện.'),

-- Dune: Phần 1
('hoang.vu',    'dune-part-1', 4, 'APPROVED', N'Hình ảnh hoành tráng, thiết kế âm thanh choáng ngợp. Nhịp phim nửa đầu hơi chậm nhưng càng về sau càng hấp dẫn.'),
('phuc.dinh',   'dune-part-1', 5, 'APPROVED', N'Denis Villeneuve dựng thế giới Arrakis rất có hồn. Cảnh con sâu cát xuất hiện lần đầu khiến mình nín thở.'),
('tuan.nguyen', 'dune-part-1', 4, 'APPROVED', N'Đây là phần mở đầu cho cả một sử thi nên hơi thiếu cao trào, nhưng chắc chắn là nền móng tốt cho phần hai.'),
('trang.do',    'dune-part-1', 3, 'APPROVED', N'Đẹp thì đẹp thật nhưng mình thấy phim hơi lạnh và nhiều đoạn nhân vật thì thầm nên khó nghe.'),

-- Dune: Phần 2
('tuan.nguyen', 'dune-part-2', 5, 'APPROVED', N'Phần 2 bùng nổ vượt bậc so với phần 1! Trận chiến trên sa mạc và màn cưỡi sâu cát mãn nhãn không thể tin nổi.'),
('khoa.dang',   'dune-part-2', 5, 'APPROVED', N'Hans Zimmer lại làm nên điều kỳ diệu. Trận đấu ở Giedi Prime quay đen trắng cực kỳ độc đáo.'),
('bao.huynh',   'dune-part-2', 5, 'APPROVED', N'Zendaya và Timothée Chalamet có chemistry tốt, đoạn kết khiến mình ngồi im không nói được gì.'),
('duc.tran',    'dune-part-2', 4, 'APPROVED', N'Phim hay nhưng phần kết hơi vội so với độ dài của cả bộ. Vẫn rất đáng xem trên màn hình lớn.'),
('vy.phan',     'dune-part-2', 4, 'PENDING',  N'Mình không quen thể loại này nhưng được bạn rủ đi xem và phải công nhận rất cuốn. Chờ phần ba.'),

-- Oppenheimer
('duc.tran',    'oppenheimer', 5, 'APPROVED', N'Phim tiểu sử nhưng nhịp độ căng thẳng nghẹt thở như một phim gián điệp trinh thám. Cillian Murphy diễn xuất đỉnh cao.'),
('linh.bui',    'oppenheimer', 5, 'APPROVED', N'Cảnh thử bom Trinity với khoảng im lặng trước khi tiếng nổ vang lên là khoảnh khắc điện ảnh tuyệt vời.'),
('son.hoang',   'oppenheimer', 4, 'APPROVED', N'Phim hơi dài và nhiều thoại về pháp lý, chính trị, nhưng Robert Downey Jr. diễn quá tốt.'),
('quan.ngo',    'oppenheimer', 5, 'APPROVED', N'Cách dựng song song hai dòng thời gian đen trắng và màu rất sáng tạo. Xem xong mình phải đọc thêm về lịch sử.'),
('hoang.vu',    'oppenheimer', 4, 'PENDING',  N'Thời lượng 3 tiếng hơi dài đối với người không rành lịch sử Mỹ nhưng cảnh thử bom Trinity rất ấn tượng.'),

-- Avatar: Dòng Chảy Của Nước
('khoa.dang',   'avatar-the-way-of-water', 4, 'APPROVED', N'Đồ họa dưới nước đẹp mê hồn, xem 3D rất đáng tiền. Cốt truyện đơn giản nhưng vẫn cảm động.'),
('phuc.dinh',   'avatar-the-way-of-water', 5, 'APPROVED', N'James Cameron vẫn là bậc thầy về hình ảnh. Những cảnh săn cá tulkun vừa đẹp vừa đau lòng.'),
('hoang.vu',    'avatar-the-way-of-water', 3, 'APPROVED', N'Phim đẹp nhưng 192 phút hơi mệt, phần giữa phim kéo dài hơn mức cần thiết.'),
('thao.nguyen', 'avatar-the-way-of-water', 4, 'APPROVED', N'Gia đình Sully làm mình nhớ phần một. Rất phù hợp để cả nhà đi xem vào cuối tuần.'),
('ngoc.ly',     'avatar-the-way-of-water', 5, 'REJECTED', N'Xem phim hay hơn tại đường link mình để trong phần giới thiệu nhé mọi người ơi, vào ngay kẻo hết!'),

-- Ký Sinh Trùng
('mai.le',      'parasite', 5, 'APPROVED', N'Một tác phẩm châm biếm sâu sắc và tàn nhẫn về khoảng cách giàu nghèo. Cú plot twist ở căn hầm khiến người xem chết lặng.'),
('linh.bui',    'parasite', 5, 'APPROVED', N'Bong Joon-ho kể chuyện quá tài tình, chuyển từ hài hước sang bi kịch mà không hề gượng ép.'),
('long.vo',     'parasite', 5, 'APPROVED', N'Xứng đáng nhận Oscar Phim hay nhất. Cảnh mưa lớn và gia đình nghèo chạy về nhà làm mình day dứt mãi.'),
('ngoc.ly',     'parasite', 4, 'APPROVED', N'Phim hay, chỉ hơi nặng nề với mình. Diễn xuất của cả gia đình Ki-taek đều rất tự nhiên.'),
('vy.phan',     'parasite', 5, 'APPROVED', N'Xem đi xem lại vẫn thấy chi tiết mới, nhất là hình ảnh cầu thang và mùi hương xuyên suốt phim.'),

-- Vùng Đất Linh Hồn
('lan.pham',    'spirited-away', 5, 'APPROVED', N'Một thế giới cổ tích kỳ ảo chứa đựng những bài học trưởng thành tuyệt vời từ Studio Ghibli.'),
('mai.le',      'spirited-away', 5, 'APPROVED', N'Nhạc của Joe Hisaishi, hình vẽ tay mềm mại, nhân vật Vô Diện ám ảnh. Xem bao nhiêu lần cũng không chán.'),
('trang.do',    'spirited-away', 5, 'APPROVED', N'Phim hoạt hình dành cho mọi lứa tuổi. Mình xem cùng con gái và cả hai mẹ con đều thích mê.'),
('yen.truong',  'spirited-away', 4, 'APPROVED', N'Cốt truyện hơi khó hiểu với trẻ nhỏ nhưng hình ảnh thì đẹp tuyệt vời.'),
('thao.nguyen', 'spirited-away', 5, 'APPROVED', N'Chihiro lớn lên theo cách rất tự nhiên, không cần lời thoại dài dòng. Một kiệt tác thực sự.'),
('ngoc.ly',     'spirited-away', 5, 'PENDING',  N'Phim đẹp quá, cảm giác như đang đọc một cuốn truyện cổ tích được vẽ bằng tay.'),

-- Người Nhện: Du Hành Vũ Trụ Nhện
('trang.do',    'spider-man-across-the-spider-verse', 5, 'APPROVED', N'Phong cách hình ảnh chưa từng có, mỗi vũ trụ có một cách vẽ riêng. Xem như đang lật qua một cuốn truyện tranh sống.'),
('bao.huynh',   'spider-man-across-the-spider-verse', 5, 'APPROVED', N'Hay hơn cả phần một, nhạc nền cũng rất cuốn. Cái kết lơ lửng khiến mình sốt ruột chờ phần tiếp theo.'),
('yen.truong',  'spider-man-across-the-spider-verse', 4, 'APPROVED', N'Hoạt hình đẹp xuất sắc, tuy nhiên nhịp phim hơi dồn dập, có đoạn mình không kịp đọc phụ đề.'),
('mai.le',      'spider-man-across-the-spider-verse', 4, 'APPROVED', N'Gwen có đất diễn nhiều hơn và câu chuyện giàu cảm xúc hơn, mình rất thích.'),

-- Lạc Vào Xứ Oz
('thao.nguyen', 'oz-the-great-and-powerful', 3, 'APPROVED', N'Phim có hình ảnh đẹp và James Franco hợp vai ảo thuật gia, nhưng cốt truyện hơi quen thuộc.'),
('trang.do',    'oz-the-great-and-powerful', 4, 'APPROVED', N'Xem cho vui cuối tuần cùng gia đình rất ổn, màu sắc xứ Oz rực rỡ làm bọn trẻ thích thú.'),
('yen.truong',  'oz-the-great-and-powerful', 3, 'APPROVED', N'Hơi thiếu hồn so với bản gốc năm 1939 nhưng vẫn là một bộ phim giải trí dễ xem.'),
('khoa.dang',   'oz-the-great-and-powerful', 1, 'REJECTED', N'Đạo diễn ngu ngốc, diễn viên như đồ bỏ đi. Ai xem phim này đúng là phí thời gian.'),

-- Chuyến Tàu Sinh Tử
('lan.pham',    'train-to-busan', 5, 'APPROVED', N'Phim zombie nhưng làm mình khóc nhiều hơn sợ. Tình cha con ở cuối phim thật sự rất xúc động.'),
('long.vo',     'train-to-busan', 5, 'APPROVED', N'Nhịp phim dồn dập từ đầu đến cuối, không có phút nào để thở. Cảnh trên tàu cực kỳ ngột ngạt.'),
('hoang.vu',    'train-to-busan', 4, 'APPROVED', N'Zombie chạy nhanh nhìn đã ghê, thêm tiết tấu căng thẳng nữa. Chỉ tiếc vài nhân vật phụ hơi dễ đoán.'),
('bao.huynh',   'train-to-busan', 4, 'APPROVED', N'Một trong những phim zombie hay nhất, vừa kinh dị vừa có chiều sâu về xã hội.'),

-- Ma Trận
('tuan.nguyen', 'the-matrix', 5, 'APPROVED', N'Phim khoa học viễn tưởng mở đường cho cả một thập kỷ, cảnh bullet time đến nay vẫn không bị lỗi thời.'),
('khoa.dang',   'the-matrix', 5, 'APPROVED', N'Câu hỏi về thực tại và lựa chọn viên thuốc đỏ vẫn đúng với thời đại mạng xã hội ngày nay.'),
('hoang.vu',    'the-matrix', 4, 'APPROVED', N'Hành động đẹp mắt, triết lý đủ để suy nghĩ nhưng không quá nặng nề.'),
('bao.huynh',   'the-matrix', 5, 'APPROVED', N'Xem lại sau hai mươi năm vẫn thấy hay. Neo là một biểu tượng của điện ảnh.'),
('phuc.dinh',   'the-matrix', 4, 'PENDING',  N'Phim cũ nhưng kỹ xảo vẫn rất đẹp, hoàn toàn đáng xem lại.'),

-- Ám Ảnh Kinh Hoàng
('lan.pham',    'the-conjuring', 4, 'APPROVED', N'Mình xem một mình ban đêm và không dám ngủ luôn. Không khí rùng rợn được xây dựng từ từ rất khéo.'),
('long.vo',     'the-conjuring', 4, 'APPROVED', N'Ít jump scare rẻ tiền, chủ yếu là không khí ma mị. Đoạn trò chơi trốn tìm là đáng sợ nhất.'),
('vy.phan',     'the-conjuring', 3, 'APPROVED', N'Phim hay nhưng mình sợ quá nên chỉ xem được một nửa, đành chấm 3 sao vì không dám xem tiếp.'),
('son.hoang',   'the-conjuring', 5, 'REJECTED', N'Xem phim miễn phí chất lượng cao tại website của tôi, truy cập ngay để nhận quà tặng!!!'),

-- Kẻ Trộm Mặt Trăng 4
('hoang.vu',    'despicable-me-4', 4, 'APPROVED', N'Minions vẫn dễ thương và gây cười, rất phù hợp để cả nhà xem vào cuối tuần.'),
('trang.do',    'despicable-me-4', 4, 'APPROVED', N'Con gái mình xem cười ngặt nghẽo. Phim nhẹ nhàng, có nhiều tình tiết hài ngắn.'),
('mai.le',      'despicable-me-4', 3, 'APPROVED', N'Hay hơn mình nghĩ nhưng cốt truyện hơi rời rạc, nhiều nhân vật mới chưa được khai thác kỹ.'),

-- Nhà Bà Nữ
('mai.le',      'nha-ba-nu', 5, 'APPROVED', N'Phim Việt hiếm hoi vừa làm mình cười vừa làm mình khóc. Cảnh bữa cơm gia đình đúng với mọi nhà.'),
('thao.nguyen', 'nha-ba-nu', 5, 'APPROVED', N'Diễn viên diễn rất tự nhiên, thoại đời thường, đoạn mâu thuẫn mẹ con xem xong mà thấy mình trong đó.'),
('ngoc.ly',     'nha-ba-nu', 4, 'APPROVED', N'Phim nhiều tầng lớp, vừa hài vừa chạm đến vấn đề thế hệ. Phần kết hơi gấp nhưng vẫn ổn.'),
('vy.phan',     'nha-ba-nu', 5, 'APPROVED', N'Xem cùng cả nhà, ai cũng thích. Hôm xem ở rạp cả phòng chiếu cùng cười rồi cùng khóc.'),
('trang.do',    'nha-ba-nu', 4, 'APPROVED', N'Nhạc nền và bối cảnh quán bánh canh rất đời. Đáng xem vào dịp Tết.'),

-- Mai
('linh.bui',    'mai', 5, 'APPROVED', N'Phim tình cảm Việt đẹp nhất những năm gần đây. Hai diễn viên chính có chemistry rất tự nhiên.'),
('mai.le',      'mai', 4, 'APPROVED', N'Bài Sau Lời Từ Khước nghe xong là nhớ ngay cảnh phim. Phần đầu hơi chậm nhưng cảm xúc về sau rất mạnh.'),
('ngoc.ly',     'mai', 5, 'APPROVED', N'Mình khóc ở đoạn cuối. Một câu chuyện về sự tha thứ và dám yêu đầy cảm xúc.'),
('yen.truong',  'mai', 4, 'APPROVED', N'Phim đẹp, tông màu ấm và nhiều góc quay sáng tạo. Hơi dài so với nội dung.'),
('vy.phan',     'mai', 3, 'APPROVED', N'Phim ổn nhưng mình mong đợi nhiều hơn sau những lời khen. Một số tình tiết hơi quen thuộc.'),
('thao.nguyen', 'mai', 5, 'APPROVED', N'Rất thích cách phim khắc họa nhân vật Mai, mạnh mẽ nhưng vẫn rất mong manh.'),
('trang.do',    'mai', 5, 'PENDING',  N'Cả rạp im phăng phắc ở cảnh cuối, mình nghe rõ cả tiếng sụt sịt của khán giả xung quanh.'),

-- Bố Già
('duc.tran',    'the-godfather', 5, 'APPROVED', N'Kiệt tác không thể bàn cãi. Màn chuyển giao quyền lực từ Vito sang Michael là đỉnh cao của điện ảnh.'),
('son.hoang',   'the-godfather', 5, 'APPROVED', N'Từng câu thoại đều đáng nhớ. Cảnh lễ rửa tội xen kẽ các vụ ám sát là một màn dựng phim bậc thầy.'),
('quan.ngo',    'the-godfather', 5, 'APPROVED', N'Marlon Brando và Al Pacino đều ở đỉnh cao diễn xuất. Xem đi xem lại vẫn thấy mới.'),
('tuan.nguyen', 'the-godfather', 4, 'APPROVED', N'Nhịp phim chậm theo chuẩn thập niên 70 nhưng mỗi cảnh đều có ý nghĩa của nó.'),

-- Hố Sâu Đói Khát
('long.vo',     'the-platform', 4, 'APPROVED', N'Ẩn dụ xã hội rất sâu về giàu nghèo và sự ích kỷ, các cảnh ghê rợn có chủ đích chứ không câu khách.'),
('lan.pham',    'the-platform', 3, 'APPROVED', N'Ý tưởng độc đáo nhưng một số cảnh hơi gây khó chịu, không dành cho người nhạy cảm.'),
('khoa.dang',   'the-platform', 4, 'APPROVED', N'Cái kết mở khiến mình suy nghĩ rất lâu. Phim ngắn gọn nhưng đầy ẩn ý.'),

-- Đất Rừng Phương Nam
('thao.nguyen', 'dat-rung-phuong-nam', 4, 'APPROVED', N'Cảnh quay sông nước miền Tây rất đẹp, nhân vật bé An được diễn rất đáng yêu.'),
('ngoc.ly',     'dat-rung-phuong-nam', 4, 'APPROVED', N'Được nhìn lại một Nam Bộ xưa đầy tình người. Phim có nhiều phân đoạn cảm động.'),
('quan.ngo',    'dat-rung-phuong-nam', 4, 'APPROVED', N'Phim chuyển thể từ tác phẩm văn học quen thuộc, giữ được hồn của nguyên tác dù có lược bớt một số chi tiết.'),

-- Vùng Đất Câm Lặng
('lan.pham',    'a-quiet-place', 5, 'APPROVED', N'Phim kinh dị sáng tạo nhất những năm gần đây, chỉ cần im lặng cũng đủ khiến khán giả nghẹt thở.'),
('long.vo',     'a-quiet-place', 4, 'APPROVED', N'Ý tưởng độc đáo và diễn xuất của Emily Blunt rất thuyết phục. Cảnh sinh nở trong căn nhà làm mình thót tim.'),
('hoang.vu',    'a-quiet-place', 4, 'APPROVED', N'Phim ngắn, gọn, không dư thừa. Gần như không có thoại mà vẫn truyền tải được cảm xúc.'),

-- Mad Max: Con Đường Tử Thần
('duc.tran',    'mad-max-fury-road', 5, 'APPROVED', N'Một bộ phim hành động gần như chỉ có một cuộc rượt đuổi dài vậy mà không hề nhàm chán. Kỹ xảo thực tế đỉnh cao.'),
('khoa.dang',   'mad-max-fury-road', 5, 'APPROVED', N'Charlize Theron trong vai Furiosa làm mình nổi da gà. Âm nhạc, thiết kế xe, mọi thứ đều độc đáo.'),
('hoang.vu',    'mad-max-fury-road', 4, 'APPROVED', N'Không có nhiều cốt truyện nhưng hình ảnh và âm thanh thì cực đã.'),
('son.hoang',   'mad-max-fury-road', 5, 'APPROVED', N'Phim hành động hay nhất mười năm qua, xem ở rạp màn hình lớn mới thấy hết độ choáng ngợp.'),

-- Gia Đình Siêu Nhân 2
('hoang.vu',    'incredibles-2', 4, 'APPROVED', N'Phim gia đình siêu anh hùng vui nhộn, cảnh bé Jack-Jack đánh nhau với con gấu trúc Mỹ rất đáng nhớ.'),
('trang.do',    'incredibles-2', 5, 'APPROVED', N'Cả nhà mình xem và đều cười suốt buổi. Elastigirl làm mình rất ngưỡng mộ.'),
('vy.phan',     'incredibles-2', 3, 'APPROVED', N'Phim hay nhưng phần phản diện hơi dễ đoán, không bằng phần một.'),

-- Bi Kịch Của Macbeth
('linh.bui',    'the-tragedy-of-macbeth', 4, 'APPROVED', N'Phiên bản đen trắng của Joel Coen đẹp như tranh. Denzel Washington và Frances McDormand diễn rất đỉnh.'),
('vy.phan',     'the-tragedy-of-macbeth', 4, 'APPROVED', N'Không dễ xem nếu chưa quen thoại Shakespeare, nhưng phần thị giác của phim thật sự ấn tượng.'),
('quan.ngo',    'the-tragedy-of-macbeth', 3, 'PENDING',  N'Phong cách rất độc đáo, tuy nhiên với người chưa đọc nguyên tác thì sẽ hơi khó theo dõi.');

-- Thời gian: duyệt xong nằm trong khoảng [ngày mới nhất giữa đăng ký/phim tạo .. 3 ngày trước];
-- đang chờ duyệt nằm trong 3 ngày gần nhất; thời điểm kiểm duyệt luôn sau thời điểm gửi.
INSERT INTO dbo.Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at,
                         created_at, updated_at, version, content_revision)
SELECT s.user_id, s.movie_id, s.rating, s.content, s.status,
       CASE WHEN s.status = 'PENDING' THEN NULL ELSE @admin END,
       CASE WHEN s.status = 'PENDING' THEN NULL
            ELSE DATEADD(MINUTE, 60 + ABS(CHECKSUM(s.user_id, s.movie_id, 7)) % 1380, s.created_at) END,
       s.created_at, s.created_at, 1, 1
FROM (
    SELECT u.id AS user_id, m.id AS movie_id, r.rating, r.content, r.status,
           CASE WHEN r.status = 'PENDING'
                THEN DATEADD(MINUTE, -(30 + ABS(CHECKSUM(u.id, m.id)) % 4200), SYSUTCDATETIME())
                ELSE DATEADD(MINUTE,
                             ABS(CHECKSUM(u.id, m.id)) % NULLIF(DATEDIFF(MINUTE,
                                 CASE WHEN u.created_at > m.created_at THEN u.created_at ELSE m.created_at END,
                                 DATEADD(DAY, -3, SYSUTCDATETIME())), 0),
                             CASE WHEN u.created_at > m.created_at THEN u.created_at ELSE m.created_at END)
           END AS created_at
    FROM @r r
    JOIN dbo.Users  u ON u.email = r.email_local + '@moviehub.vn'
    JOIN dbo.Movies m ON m.slug  = r.movie_slug AND m.status = 'PUBLISHED'
) s
WHERE NOT EXISTS (SELECT 1 FROM dbo.Reviews x WHERE x.user_id = s.user_id AND x.movie_id = s.movie_id);

PRINT N'[07] Đã nạp đánh giá.';
GO
