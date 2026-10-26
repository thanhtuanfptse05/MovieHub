-- =========================================================================
-- MovieHub | 05_seed_movies.sql
-- 24 phim công khai + 2 phim nháp + 1 phim đang ẩn, kèm liên kết thể loại.
--
-- Cột video_url: danh sách nhiều video, mỗi mục dạng "Tiêu đề | URL", ngăn cách bằng '||'
-- (được đổi thành xuống dòng khi ghi vào bảng). Trang chi tiết hiển thị mỗi mục như một tập.
-- Toàn bộ video là trailer, clip và hậu trường chính thức trên YouTube; poster lấy từ TMDB/Wikipedia.
-- =========================================================================
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

USE MovieHub;
GO

DECLARE @movies TABLE (
    title nvarchar(200), slug varchar(250) COLLATE Latin1_General_100_BIN2, description nvarchar(max),
    release_year int, duration_minutes int, poster_url varchar(1000),
    video_url nvarchar(max), trailer_url nvarchar(max),
    status varchar(10) COLLATE Latin1_General_100_BIN2, featured bit, view_count bigint, days_ago int
);

INSERT INTO @movies VALUES
(N'Inception: Kẻ Đánh Cắp Giấc Mơ', 'inception',
 N'Một điệp viên chuyên xâm nhập vào tiềm thức của người khác để đánh cắp bí mật kinh doanh được trao nhiệm vụ bất khả thi: cấy ghép một ý tưởng vào tâm trí mục tiêu.',
 2010, 148, 'https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg',
 N'Trailer chính thức | https://www.youtube.com/watch?v=YoHD9XEInc0||Cảnh phim: Bạn đang ở trong giấc mơ | https://www.youtube.com/watch?v=i3-jlhJgU9U||Cảnh phim: Cú đá cuối cùng | https://www.youtube.com/watch?v=IA5YlOXJ_PQ',
 N'https://www.youtube.com/watch?v=zp_YGmAoht0', 'PUBLISHED', 0, 15420, 190),
(N'Interstellar: Hố Đen Tử Thần', 'interstellar',
 N'Khi Trái Đất dần cạn kiệt tài nguyên, một nhóm phi hành gia du hành qua một lỗ sâu bí ẩn gần sao Thổ nhằm tìm kiếm hành tinh mới để cứu lấy tương lai nhân loại.',
 2014, 169, 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
 N'Trailer chính thức | https://www.youtube.com/watch?v=2LqzF5WauAw||Cảnh phim: Sóng thần | https://www.youtube.com/watch?v=60h6lpnSgck||Cảnh phim: Murph cứu thế giới | https://www.youtube.com/watch?v=Rvns5DaW-ug',
 N'https://www.youtube.com/watch?v=zSWdZVtXT7E', 'PUBLISHED', 1, 23810, 185),
(N'The Dark Knight: Kỵ Sĩ Bóng Đêm', 'the-dark-knight',
 N'Khi kẻ hỗn loạn Joker xuất hiện tàn phá thành phố Gotham, Người Dơi phải chấp nhận đối mặt với ranh giới mong manh giữa công lý và sự hy sinh bản thân.',
 2008, 152, 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
 N'Trailer 2 | https://www.youtube.com/watch?v=TQfATDZY5Y4||Cảnh phim: Trò ảo thuật cây bút chì | https://www.youtube.com/watch?v=votcOf5cYCM||Cảnh phim: Batman thẩm vấn Joker | https://www.youtube.com/watch?v=jane6C4rIwc',
 N'https://www.youtube.com/watch?v=EXeTwQWrcwY', 'PUBLISHED', 1, 31200, 180),
(N'Dune: Hành Tinh Cát (Phần 1)', 'dune-part-1',
 N'Paul Atreides, một người thừa kế mang số phận vĩ đại, phải du hành đến hành tinh nguy hiểm nhất vũ trụ Arrakis để bảo vệ gia tộc và thần dân của mình.',
 2021, 155, 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
 N'Trailer chính | https://www.youtube.com/watch?v=8g18jFHCLXk||Cảnh phim: Bài thử Gom Jabbar | https://www.youtube.com/watch?v=7SCWy9gsw3E||Cảnh phim: Hương dược Spice | https://www.youtube.com/watch?v=26bgYpJOqcw',
 N'https://www.youtube.com/watch?v=n9xhJrPXop4', 'PUBLISHED', 0, 18940, 170),
(N'Dune: Hành Tinh Cát (Phần 2)', 'dune-part-2',
 N'Paul Atreides hợp lực cùng Chani và tộc người Fremen để trả thù những kẻ đã hủy diệt gia đình anh, đối mặt với ngã rẽ giữa tình yêu và định mệnh vũ trụ.',
 2024, 166, 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
 N'Trailer 2 | https://www.youtube.com/watch?v=_YUzQa_1RCE||Trailer 3 | https://www.youtube.com/watch?v=U2Qp5pL3ovA||Cảnh phim: Bài phát biểu của Paul | https://www.youtube.com/watch?v=ofRdPtkUmJ4',
 N'https://www.youtube.com/watch?v=Way9Dexny3w', 'PUBLISHED', 1, 27500, 120),
(N'Oppenheimer', 'oppenheimer',
 N'Câu chuyện cuộc đời của nhà vật lý lý thuyết J. Robert Oppenheimer, người lãnh đạo dự án Manhattan chế tạo ra quả bom nguyên tử đầu tiên trong Thế chiến thứ II.',
 2023, 180, 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
 N'Trailer mới | https://www.youtube.com/watch?v=uYPbbksJxIg||Cảnh phim: Vụ thử Trinity | https://www.youtube.com/watch?v=tK0IDmSYYGk||Cảnh phim: Downey Jr. và Cillian Murphy | https://www.youtube.com/watch?v=MkcVWcCIOr4',
 N'https://www.youtube.com/watch?v=bK6ldnjE3Y0', 'PUBLISHED', 1, 29400, 140),
(N'Avatar: Dòng Chảy Của Nước', 'avatar-the-way-of-water',
 N'Hơn một thập kỷ sau sự kiện phần một, Jake Sully và Neytiri phải rời bỏ quê hương rừng xanh để tìm nơi trú ẩn tại các rạn san hô kỳ vĩ của hành tinh Pandora.',
 2022, 192, 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
 N'Teaser chính thức | https://www.youtube.com/watch?v=a8Gx8wiNbs8||Trailer mới | https://www.youtube.com/watch?v=o5F8MOz_IDw||Cảnh phim: Học lặn | https://www.youtube.com/watch?v=iDkCBPckHmQ',
 N'https://www.youtube.com/watch?v=d9MyW72ELq0', 'PUBLISHED', 1, 19800, 160),
(N'Ký Sinh Trùng (Parasite)', 'parasite',
 N'Một gia đình nghèo từng bước thâm nhập vào cuộc sống hào nhoáng của một gia đình giàu có ở Seoul, mở ra bi kịch khốc liệt phản ánh sự phân hóa xã hội.',
 2019, 132, 'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
 N'Trailer 2 | https://www.youtube.com/watch?v=PhPROyE0OaM||Trailer quốc tế | https://www.youtube.com/watch?v=SEUXfv87Wpk||Tổng hợp: Những khoảnh khắc của Ki-jung | https://www.youtube.com/watch?v=iYWBGJzXvs0',
 N'https://www.youtube.com/watch?v=isOGD_7hNIY', 'PUBLISHED', 1, 21500, 175),
(N'Vùng Đất Linh Hồn (Spirited Away)', 'spirited-away',
 N'Cô bé Chihiro mười tuổi vô tình lạc vào thế giới của các linh hồn và thần linh, nơi cô phải nỗ lực làm việc để giải cứu cha mẹ đã bị biến thành heo.',
 2001, 125, 'https://image.tmdb.org/t/p/w500/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',
 N'Trailer tiếng Anh | https://www.youtube.com/watch?v=fDUFP7EeXLE||Cảnh phim: Đừng thở, Chihiro | https://www.youtube.com/watch?v=70NhEBzLKU8||Cảnh phim: Lin dẫn Chihiro qua nhà tắm | https://www.youtube.com/watch?v=W5szC4XgR1s',
 N'https://www.youtube.com/watch?v=ByXuk9QqQkk', 'PUBLISHED', 1, 16300, 165),
(N'Người Nhện: Du Hành Vũ Trụ Nhện', 'spider-man-across-the-spider-verse',
 N'Miles Morales du hành qua đa vũ trụ để bảo vệ sự tồn vong của thế giới, nhưng bất ngờ phải đối đầu với một liên minh Người Nhện vì quan điểm cứu rỗi.',
 2023, 140, 'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
 N'Trailer 2 | https://www.youtube.com/watch?v=shW9i6k8cB0||Cảnh phim: Gwen và Miles | https://www.youtube.com/watch?v=MokxwHbscQ8||Cảnh phim: Ngăn Người Nhện lại | https://www.youtube.com/watch?v=GPitD0-mkYA',
 N'https://www.youtube.com/watch?v=cqGjhVJWtEg', 'PUBLISHED', 0, 22100, 130),
(N'Lạc Vào Xứ Oz', 'oz-the-great-and-powerful',
 N'Một ảo thuật gia gánh xiếc tình cờ bay lạc đến xứ sở kỳ diệu Oz và phải trở thành vị phù thủy vĩ đại bảo vệ vương quốc khỏi mụ phù thủy hắc ám.',
 2013, 130, 'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
 N'Trailer đầy đủ | https://www.youtube.com/watch?v=yyywumlnhdw||Trailer quốc tế | https://www.youtube.com/watch?v=YhLaBpvS7os',
 N'https://www.youtube.com/watch?v=DylgNj4YQVc', 'PUBLISHED', 0, 7800, 150),
(N'Chuyến Tàu Sinh Tử (Train to Busan)', 'train-to-busan',
 N'Một đại dịch xác sống bất ngờ bùng phát khắp Hàn Quốc trong lúc đoàn tàu lửa chở hai cha con đang tăng tốc đến vùng an toàn cuối cùng ở Busan.',
 2016, 118, 'https://media.themoviedb.org/t/p/w500/vNVFt6dtcqnI7hqa6LFBUibuFiw.jpg',
 N'Trailer 2 | https://www.youtube.com/watch?v=E2nrE9JnaDg||Cảnh phim: Đóng cửa lại | https://www.youtube.com/watch?v=35alr5YNgf8||Clip độc quyền | https://www.youtube.com/watch?v=IA2hiufg3B0',
 N'https://www.youtube.com/watch?v=1ovgxN2VWNc', 'PUBLISHED', 0, 14200, 145),
(N'Ma Trận (The Matrix)', 'the-matrix',
 N'Một lập trình viên phát hiện ra rằng thực tại mà anh đang sống chỉ là một mô phỏng máy tính tinh vi do máy móc thống trị tạo ra để nô dịch con người.',
 1999, 136, 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
 N'Trailer 1 | https://www.youtube.com/watch?v=vKQi3bBA1y8||Cảnh phim: Ma Trận là gì | https://www.youtube.com/watch?v=O5b0ZxUWNf0||Cảnh phim: Neo là Người Được Chọn | https://www.youtube.com/watch?v=H-0RHqDWcJE',
 N'https://www.youtube.com/watch?v=tGgCqGm_6Hs', 'PUBLISHED', 0, 18400, 155),
(N'Ám Ảnh Kinh Hoàng (The Conjuring)', 'the-conjuring',
 N'Hai nhà điều tra hiện tượng siêu nhiên Ed và Lorraine Warren đến trợ giúp một gia đình bị khủng bố bởi linh hồn tà ác trong trang trại hẻo lánh.',
 2013, 112, 'https://image.tmdb.org/t/p/w500/wVYREutTvI2tmxr6ujrHT704wGF.jpg',
 N'Trailer 3 | https://www.youtube.com/watch?v=WFDXlIKPHFo||Trailer 1 | https://www.youtube.com/watch?v=ejMMn0t58Lc||Cảnh phim: Tôi biết bạn đang trốn ở đâu | https://www.youtube.com/watch?v=cZfeDbToqLk',
 N'https://www.youtube.com/watch?v=k10ETZ41q5o', 'PUBLISHED', 0, 9800, 135),
(N'Kẻ Trộm Mặt Trăng 4 (Despicable Me 4)', 'despicable-me-4',
 N'Gru và gia đình bước vào một chương mới khi đối mặt với kẻ thù nguy hiểm Maxime Le Mal, buộc họ phải chuyển nơi ẩn náu cùng các chú Minion quậy phá.',
 2024, 94, 'https://image.tmdb.org/t/p/w500/wWba3TaojhK7NdycRhoQpsG0FaH.jpg',
 N'Trailer 2 | https://www.youtube.com/watch?v=LtNYaH61dXY||Cảnh phim: Mega Minions xuất trận | https://www.youtube.com/watch?v=V39gEnSPyCo||Cảnh phim: Edith đấu võ sư Karate | https://www.youtube.com/watch?v=A7zXbLFP8LI',
 N'https://www.youtube.com/watch?v=qQlr9-rF32A', 'PUBLISHED', 0, 12600, 60),
(N'Nhà Bà Nữ', 'nha-ba-nu',
 N'Câu chuyện xoay quanh quán bánh canh cua của bà Nữ và những mâu thuẫn thế hệ, định kiến trong một gia đình lao động tại Sài Gòn.',
 2023, 102, 'https://upload.wikimedia.org/wikipedia/vi/6/6f/%C3%81p_ph%C3%ADch_phim_Nh%C3%A0_b%C3%A0_N%E1%BB%AF.jpg',
 N'Teaser trailer | https://www.youtube.com/watch?v=uZKa7Pcquec||Clip: Tình bà cháu cảm động | https://www.youtube.com/watch?v=PEr3HLN-nJE||Clip: Bà ngoại bá đạo, đáng yêu | https://www.youtube.com/watch?v=CIESITgWEP8',
 N'https://www.youtube.com/watch?v=IkaP0KJWTsQ', 'PUBLISHED', 0, 16700, 110),
(N'Mai', 'mai',
 N'Hành trình tình yêu đầy thăng trầm giữa Mai, một phụ nữ làm nghề mát-xa chịu nhiều định kiến, và Dương, chàng nhạc công lãng tử nhà giàu.',
 2024, 131, 'https://upload.wikimedia.org/wikipedia/en/3/36/Mai_2024_poster.jpg',
 N'Teaser trailer | https://www.youtube.com/watch?v=VweAKEjYw8c||MV Sau Lời Từ Khước (OST) | https://www.youtube.com/watch?v=h_1t3-6oWz4||Hậu trường: Making of Mai | https://www.youtube.com/watch?v=XtGVVPc7-5c',
 N'https://www.youtube.com/watch?v=EX6clvId19s', 'PUBLISHED', 1, 28100, 75),
(N'Bố Già (The Godfather)', 'the-godfather',
 N'Biên niên sử về gia tộc mafia Corleone hùng mạnh ở New York và sự chuyển giao quyền lực bi kịch giữa người cha Vito và con trai Michael.',
 1972, 175, 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
 N'Trailer gốc 1972 | https://www.youtube.com/watch?v=1x0GpEZnwa8||Cảnh phim: Mở đầu | https://www.youtube.com/watch?v=eZHsmb4ezEk||Cảnh phim: Moe Greene | https://www.youtube.com/watch?v=Rtbw8s1MJGo',
 N'https://www.youtube.com/watch?v=UaVTIH8mujA', 'PUBLISHED', 0, 35000, 195),
(N'Hố Sâu Đói Khát (The Platform)', 'the-platform',
 N'Một nhà tù thẳng đứng nơi thức ăn được thả từ tầng cao nhất xuống, buộc các tù nhân ở tầng dưới phải chiến đấu để sinh tồn trong hoàn cảnh khắc nghiệt.',
 2019, 94, 'https://media.themoviedb.org/t/p/w500/iXvQnzy6JCAx1PiQEKXuTY04ZHl.jpg',
 N'Trailer phần 2 | https://www.youtube.com/watch?v=UKFMYWNatQM||Cảnh phim: Mở đầu | https://www.youtube.com/watch?v=YXZlbluG9-o',
 N'https://www.youtube.com/watch?v=RlfooqeZcdY', 'PUBLISHED', 0, 8400, 100),
(N'Đất Rừng Phương Nam', 'dat-rung-phuong-nam',
 N'Hành trình tìm cha đầy thử thách của cậu bé An qua khắp các miền sông nước Nam Bộ trù phú trong bối cảnh kháng chiến chống Pháp đầu thế kỷ 20.',
 2023, 134, 'https://upload.wikimedia.org/wikipedia/vi/8/8c/%C4%90%E1%BA%A5t_r%E1%BB%ABng_ph%C6%B0%C6%A1ng_Nam_-_Official_poster.jpg',
 N'Teaser trailer | https://www.youtube.com/watch?v=P2Mgo0yE-fo||Trailer CGV | https://www.youtube.com/watch?v=d-ck5QxqgMg||MV Bài ca đất phương Nam | https://www.youtube.com/watch?v=uU-1VyT4TRE',
 N'https://www.youtube.com/watch?v=hktzirCnJmQ', 'PUBLISHED', 0, 11200, 105),
(N'Vùng Đất Câm Lặng (A Quiet Place)', 'a-quiet-place',
 N'Một gia đình phải sống trong im lặng tuyệt đối tại một vùng quê hoang vắng để tránh sự săn lùng tàn bạo của những sinh vật ngoài hành tinh nhạy bén với âm thanh.',
 2018, 90, 'https://image.tmdb.org/t/p/w500/nAU74GmpUk7t5iklEp3bufwDq4n.jpg',
 N'Trailer cuối | https://www.youtube.com/watch?v=i2SbAuwCzCc||Cảnh phim: Cái chết của Beau | https://www.youtube.com/watch?v=4CmmKmlXD9I||Cảnh phim: Ông lão trong rừng | https://www.youtube.com/watch?v=KD6FsEaD-3U',
 N'https://www.youtube.com/watch?v=WR7cc5t7tv8', 'PUBLISHED', 0, 13800, 125),
(N'Mad Max: Con Đường Tử Thần', 'mad-max-fury-road',
 N'Trong một tương lai hậu tận thế khô cằn, Max Điên hợp tác cùng Furiosa dũng cảm nhằm giải cứu một nhóm phụ nữ khỏi tay tên bạo chúa khát máu Immortan Joe.',
 2015, 120, 'https://image.tmdb.org/t/p/w500/hA2ple9q4qnwxp3hKVNhroipsir.jpg',
 N'Teaser trailer | https://www.youtube.com/watch?v=YWNWi-ZWL3c||Giới thiệu tại Comic-Con | https://www.youtube.com/watch?v=akX3Is3qBpw||Cảnh phim: Cuộc rượt đuổi bắt đầu | https://www.youtube.com/watch?v=UtjGTrVwRr4',
 N'https://www.youtube.com/watch?v=hEJnMQG9ev8', 'PUBLISHED', 0, 17200, 115),
(N'Gia Đình Siêu Nhân 2 (Incredibles 2)', 'incredibles-2',
 N'Trong khi Elastigirl đảm nhận sứ mệnh lấy lại niềm tin cho các siêu anh hùng, Bob Parr phải ở nhà trông nom ba đứa con với những siêu năng lực bùng nổ.',
 2018, 118, 'https://media.themoviedb.org/t/p/w500/9lFKBtaVIhP7E2Pk0IY1CwTKTMZ.jpg',
 N'Teaser trailer | https://www.youtube.com/watch?v=ZJDMWVZta3M||Xem trước: Thế vận hội | https://www.youtube.com/watch?v=YBpdL9hSac4||Cảnh phim: Lucius cứu bọn trẻ | https://www.youtube.com/watch?v=AXdZbZqiiLA',
 N'https://www.youtube.com/watch?v=i5qOzqD9Rms', 'PUBLISHED', 0, 15300, 95),
(N'Bi Kịch Của Macbeth', 'the-tragedy-of-macbeth',
 N'Một vị tướng tài ba nghe lời tiên tri của ba mụ phù thủy và sự giục giã của người vợ đầy tham vọng đã quyết định sát hại nhà vua để chiếm ngai vàng.',
 2021, 105, 'https://media.themoviedb.org/t/p/w500/tDNJEhcLbX3jIk3BMCur9pCdaVD.jpg',
 N'Trailer Apple TV | https://www.youtube.com/watch?v=ptqe7s6pO7g||Cảnh phim: Độc thoại con dao găm | https://www.youtube.com/watch?v=kv_QYZQVGXg||Cảnh phim: Ba mụ phù thủy | https://www.youtube.com/watch?v=13WWN6rhxM4',
 N'https://www.youtube.com/watch?v=HM3hsVrBMA4', 'PUBLISHED', 0, 4200, 90),
-- Phim chưa công khai (chỉ quản trị viên nhìn thấy trong trang quản lý)
(N'Wicked: Phù Thủy Xứ Oz', 'wicked-phu-thuy-xu-oz',
 N'Câu chuyện về tình bạn bất ngờ giữa Elphaba, cô gái da xanh bị hiểu lầm, và Glinda, cô gái nổi tiếng được yêu mến, trước khi cả hai trở thành Phù Thủy Xấu Xa xứ Tây và Phù Thủy Tốt Bụng xứ Bắc.',
 2024, 160, 'https://image.tmdb.org/t/p/w500/c5Tqxeo1UpBvnAc3csUm7j3hlQl.jpg',
 NULL, NULL, 'DRAFT', 0, 0, 12),
(N'Deadpool & Wolverine', 'deadpool-and-wolverine',
 N'Wade Wilson bị Cục Biến Đổi Thời Gian lôi kéo ra khỏi cuộc sống nghỉ hưu và buộc phải hợp tác cùng Wolverine bướng bỉnh để cứu thế giới của mình khỏi hiểm họa.',
 2024, 128, 'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
 NULL, NULL, 'DRAFT', 0, 0, 8),
(N'Joker', 'joker',
 N'Arthur Fleck, một diễn viên hài thất bại sống ở Gotham tồi tàn, dần bị xã hội ruồng bỏ đẩy tới bờ vực điên loạn và trở thành tên tội phạm khét tiếng Joker.',
 2019, 122, 'https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg',
 NULL, NULL, 'HIDDEN', 0, 3200, 80);

INSERT INTO dbo.Movies (title, slug, description, release_year, duration_minutes, poster_url,
                        video_url, trailer_url, status, featured, view_count, created_at, updated_at, version)
SELECT m.title, m.slug, m.description, m.release_year, m.duration_minutes, m.poster_url,
       REPLACE(m.video_url, N'||', NCHAR(10)), m.trailer_url, m.status, m.featured, m.view_count,
       DATEADD(DAY, -m.days_ago, SYSUTCDATETIME()),
       DATEADD(DAY, -m.days_ago / 2, SYSUTCDATETIME()),
       1
FROM @movies m
WHERE NOT EXISTS (SELECT 1 FROM dbo.Movies x WHERE x.slug = m.slug);

-- ---------------------------------------------------------------------
-- Liên kết phim - thể loại
-- ---------------------------------------------------------------------
DECLARE @links TABLE (
    movie_slug    varchar(250) COLLATE Latin1_General_100_BIN2,
    category_slug varchar(120) COLLATE Latin1_General_100_BIN2
);
INSERT INTO @links VALUES
('inception', 'hanh-dong'), ('inception', 'vien-tuong'), ('inception', 'giat-gan'),
('interstellar', 'vien-tuong'), ('interstellar', 'phieu-luu'), ('interstellar', 'tam-ly'),
('the-dark-knight', 'hanh-dong'), ('the-dark-knight', 'hinh-su'), ('the-dark-knight', 'giat-gan'),
('dune-part-1', 'vien-tuong'), ('dune-part-1', 'phieu-luu'),
('dune-part-2', 'vien-tuong'), ('dune-part-2', 'phieu-luu'), ('dune-part-2', 'hanh-dong'),
('oppenheimer', 'lich-su'), ('oppenheimer', 'tam-ly'),
('avatar-the-way-of-water', 'vien-tuong'), ('avatar-the-way-of-water', 'phieu-luu'), ('avatar-the-way-of-water', 'hanh-dong'),
('parasite', 'tam-ly'), ('parasite', 'giat-gan'), ('parasite', 'hai-huoc'),
('spirited-away', 'hoat-hinh'), ('spirited-away', 'gia-tuong'), ('spirited-away', 'phieu-luu'), ('spirited-away', 'gia-dinh'),
('spider-man-across-the-spider-verse', 'hoat-hinh'), ('spider-man-across-the-spider-verse', 'hanh-dong'), ('spider-man-across-the-spider-verse', 'phieu-luu'),
('oz-the-great-and-powerful', 'gia-tuong'), ('oz-the-great-and-powerful', 'phieu-luu'), ('oz-the-great-and-powerful', 'gia-dinh'),
('train-to-busan', 'hanh-dong'), ('train-to-busan', 'kinh-di'), ('train-to-busan', 'giat-gan'),
('the-matrix', 'hanh-dong'), ('the-matrix', 'vien-tuong'),
('the-conjuring', 'kinh-di'), ('the-conjuring', 'giat-gan'),
('despicable-me-4', 'hoat-hinh'), ('despicable-me-4', 'hai-huoc'), ('despicable-me-4', 'gia-dinh'),
('nha-ba-nu', 'tam-ly'), ('nha-ba-nu', 'hai-huoc'), ('nha-ba-nu', 'gia-dinh'),
('mai', 'tinh-cam'), ('mai', 'tam-ly'),
('the-godfather', 'hinh-su'), ('the-godfather', 'tam-ly'),
('the-platform', 'kinh-di'), ('the-platform', 'vien-tuong'), ('the-platform', 'giat-gan'),
('dat-rung-phuong-nam', 'phieu-luu'), ('dat-rung-phuong-nam', 'lich-su'), ('dat-rung-phuong-nam', 'gia-dinh'),
('a-quiet-place', 'kinh-di'), ('a-quiet-place', 'vien-tuong'), ('a-quiet-place', 'giat-gan'),
('mad-max-fury-road', 'hanh-dong'), ('mad-max-fury-road', 'vien-tuong'), ('mad-max-fury-road', 'phieu-luu'),
('incredibles-2', 'hoat-hinh'), ('incredibles-2', 'hanh-dong'), ('incredibles-2', 'hai-huoc'), ('incredibles-2', 'gia-dinh'),
('the-tragedy-of-macbeth', 'tam-ly'), ('the-tragedy-of-macbeth', 'lich-su'),
('wicked-phu-thuy-xu-oz', 'gia-tuong'), ('wicked-phu-thuy-xu-oz', 'tinh-cam'),
('deadpool-and-wolverine', 'hanh-dong'), ('deadpool-and-wolverine', 'hai-huoc'),
('joker', 'hinh-su'), ('joker', 'tam-ly'), ('joker', 'giat-gan');

INSERT INTO dbo.MovieCategories (movie_id, category_id)
SELECT m.id, c.id
FROM @links l
JOIN dbo.Movies m     ON m.slug = l.movie_slug
JOIN dbo.Categories c ON c.slug = l.category_slug
WHERE NOT EXISTS (SELECT 1 FROM dbo.MovieCategories x WHERE x.movie_id = m.id AND x.category_id = c.id);

PRINT N'[05] Đã nạp phim và liên kết thể loại.';
GO
