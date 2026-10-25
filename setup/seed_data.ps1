# PowerShell Database Seeder for MovieHub
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$connectionString = "Server=localhost,1433;Database=MovieHub;User Id=sa;Password=123;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$conn.Open()

function Execute-SQL($sql, $params = @{}) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    foreach ($k in $params.Keys) {
        $cmd.Parameters.AddWithValue($k, $params[$k]) | Out-Null
    }
    return $cmd.ExecuteNonQuery()
}

function Query-Scalar($sql, $params = @{}) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    foreach ($k in $params.Keys) {
        $cmd.Parameters.AddWithValue($k, $params[$k]) | Out-Null
    }
    return $cmd.ExecuteScalar()
}

Write-Host "Seeding MovieHub database..." -ForegroundColor Cyan

# 1. Seed Users
$pwHash = '$2a$12$2i17UMSIoVJXzq5zkQ3txeyiFGn3VzZ.dd3lKSL5ZTtnV42OEWL9q' # Password123!

$users = @(
    @{ name = "Admin MovieHub"; email = "admin@moviehub.vn"; role = "ADMIN"; status = "ACTIVE"; avatar = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80" },
    @{ name = "Nguyễn Thanh Tuấn"; email = "tuan.nguyen@moviehub.vn"; role = "USER"; status = "ACTIVE"; avatar = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80" },
    @{ name = "Lê Thị Tuyết Mai"; email = "mai.le@moviehub.vn"; role = "USER"; status = "ACTIVE"; avatar = "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80" },
    @{ name = "Trần Minh Đức"; email = "duc.tran@moviehub.vn"; role = "USER"; status = "ACTIVE"; avatar = "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=300&q=80" },
    @{ name = "Phạm Hương Lan"; email = "lan.pham@moviehub.vn"; role = "USER"; status = "ACTIVE"; avatar = "https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=300&q=80" },
    @{ name = "Vũ Hoàng Nam"; email = "hoang.vu@moviehub.vn"; role = "USER"; status = "ACTIVE"; avatar = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80" },
    @{ name = "Tài Khoản Bị Khóa"; email = "banned@moviehub.vn"; role = "USER"; status = "INACTIVE"; avatar = $null }
)

foreach ($u in $users) {
    $exists = Query-Scalar "SELECT COUNT(*) FROM Users WHERE email = @email" @{ "@email" = $u.email }
    if ($exists -eq 0) {
        Execute-SQL @"
INSERT INTO Users (full_name, email, password_hash, role, status, avatar_url, created_at, updated_at, version, credentials_version)
VALUES (@name, @email, @hash, @role, @status, @avatar, SYSUTCDATETIME(), SYSUTCDATETIME(), 1, 1)
"@ @{
            "@name" = $u.name
            "@email" = $u.email
            "@hash" = $pwHash
            "@role" = $u.role
            "@status" = $u.status
            "@avatar" = $(if ($u.avatar) { $u.avatar } else { [DBNull]::Value })
        }
        Write-Host " Inserted User: $($u.email)" -ForegroundColor Green
    }
}

# 2. Seed Categories
$categories = @(
    @{ name = "Hành Động"; slug = "hanh-dong"; key = "hành động" },
    @{ name = "Viễn Tưởng"; slug = "vien-tuong"; key = "viễn tưởng" },
    @{ name = "Phiêu Lưu"; slug = "phieu-luu"; key = "phiêu lưu" },
    @{ name = "Tâm Lý"; slug = "tam-ly"; key = "tâm lý" },
    @{ name = "Kinh Dị"; slug = "kinh-di"; key = "kinh dị" },
    @{ name = "Hoạt Hình"; slug = "hoat-hinh"; key = "hoạt hình" },
    @{ name = "Hài Hước"; slug = "hai-huoc"; key = "hài hước" },
    @{ name = "Tình Cảm"; slug = "tinh-cam"; key = "tình cảm" }
)

foreach ($c in $categories) {
    $exists = Query-Scalar "SELECT COUNT(*) FROM Categories WHERE slug = @slug" @{ "@slug" = $c.slug }
    if ($exists -eq 0) {
        Execute-SQL @"
INSERT INTO Categories (name, slug, name_key, created_at, version)
VALUES (@name, @slug, @key, SYSUTCDATETIME(), 1)
"@ @{
            "@name" = $c.name
            "@slug" = $c.slug
            "@key" = $c.key
        }
        Write-Host " Inserted Category: $($c.name)" -ForegroundColor Green
    }
}

# 3. Seed Movies
$movies = @(
    @{
        title = "Inception: Kẻ Đánh Cắp Giấc Mơ"; slug = "inception"; year = 2010; duration = 148;
        desc = "Một điệp viên chuyên xâm nhập vào tiềm thức của người khác để đánh cắp bí mật kinh doanh được trao nhiệm vụ bất khả thi: cấy ghép một ý tưởng vào tâm trí mục tiêu.";
        poster = "https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $true; views = 15420; cats = @("hanh-dong", "vien-tuong")
    },
    @{
        title = "Interstellar: Hố Đen Tử Thần"; slug = "interstellar"; year = 2014; duration = 169;
        desc = "Khi Trái Đất dần cạn kiệt tài nguyên, một nhóm phi hành gia du hành qua một lỗ sâu bí ẩn gần sao Thổ nhằm tìm kiếm hành tinh mới để cứu lấy tương lai nhân loại.";
        poster = "https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4";
        status = "PUBLISHED"; featured = $true; views = 23810; cats = @("vien-tuong", "phieu-luu")
    },
    @{
        title = "The Dark Knight: Kỵ Sĩ Bóng Đêm"; slug = "the-dark-knight"; year = 2008; duration = 152;
        desc = "Khi kẻ hỗn loạn Joker xuất hiện tàn phá thành phố Gotham, Người Dơi phải chấp nhận đối mặt với ranh giới mong manh giữa công lý và sự hy sinh bản thân.";
        poster = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $true; views = 31200; cats = @("hanh-dong", "tam-ly")
    },
    @{
        title = "Dune: Hành Tinh Cát (Phần 1)"; slug = "dune-part-1"; year = 2021; duration = 155;
        desc = "Paul Atreides, một người thừa kế mang số phận vĩ đại, phải du hành đến hành tinh nguy hiểm nhất vũ trụ Arrakis để bảo vệ gia tộc và thần dân của mình.";
        poster = "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4";
        status = "PUBLISHED"; featured = $true; views = 18940; cats = @("vien-tuong", "phieu-luu")
    },
    @{
        title = "Dune: Hành Tinh Cát (Phần 2)"; slug = "dune-part-2"; year = 2024; duration = 166;
        desc = "Paul Atreides hợp lực cùng Chani và tộc người Fremen để trả thù những kẻ đã hủy diệt gia đình anh, đối mặt với ngã rẽ giữa tình yêu và định mệnh vũ trụ.";
        poster = "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $true; views = 27500; cats = @("vien-tuong", "hanh-dong")
    },
    @{
        title = "Oppenheimer"; slug = "oppenheimer"; year = 2023; duration = 180;
        desc = "Câu chuyện cuộc đời của nhà vật lý lý thuyết J. Robert Oppenheimer, người lãnh đạo dự án Manhattan chế tạo ra quả bom nguyên tử đầu tiên trong Thế chiến thứ II.";
        poster = "https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4";
        status = "PUBLISHED"; featured = $true; views = 29400; cats = @("tam-ly")
    },
    @{
        title = "Avatar: Dòng Chảy Của Nước"; slug = "avatar-the-way-of-water"; year = 2022; duration = 192;
        desc = "Hơn một thập kỷ sau sự kiện phần một, Jake Sully và Neytiri phải rời bỏ quê hương rừng xanh để tìm nơi trú ẩn tại các rạn san hô kỳ vĩ của hành tinh Pandora.";
        poster = "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $false; views = 19800; cats = @("vien-tuong", "phieu-luu")
    },
    @{
        title = "Ký Sinh Trùng (Parasite)"; slug = "parasite"; year = 2019; duration = 132;
        desc = "Một gia đình nghèo từng bước thâm nhập vào cuộc sống hào nhoáng của một gia đình giàu có ở Seoul, mở ra bi kịch khốc liệt phản ánh sự phân hóa xã hội.";
        poster = "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4";
        status = "PUBLISHED"; featured = $true; views = 21500; cats = @("tam-ly")
    },
    @{
        title = "Vùng Đất Linh Hồn (Spirited Away)"; slug = "spirited-away"; year = 2001; duration = 125;
        desc = "Cô bé Chihiro mười tuổi vô tình lạc vào thế giới của các linh hồn và thần linh, nơi cô phải nỗ lực làm việc để giải cứu cha mẹ đã bị biến thành heo.";
        poster = "https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $true; views = 16300; cats = @("hoat-hinh", "phieu-luu")
    },
    @{
        title = "Người Nhện: Du Hành Vũ Trụ Nhện"; slug = "spider-man-across-the-spider-verse"; year = 2023; duration = 140;
        desc = "Miles Morales du hành qua đa vũ trụ để bảo vệ sự tồn vong của thế giới, nhưng bất ngờ phải đối đầu với một liên minh Người Nhện vì quan điểm cứu rỗi.";
        poster = "https://images.unsplash.com/photo-1635805737707-575885ab0820?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4";
        status = "PUBLISHED"; featured = $true; views = 22100; cats = @("hoat-hinh", "hanh-dong")
    },
    @{
        title = "Chuyến Tàu Sinh Tử (Train to Busan)"; slug = "train-to-busan"; year = 2016; duration = 118;
        desc = "Một đại dịch xác sống bất ngờ bùng phát khắp Hàn Quốc trong lúc đoàn tàu lửa chở hai cha con đang tăng tốc đến vùng an toàn cuối cùng ở Busan.";
        poster = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $false; views = 14200; cats = @("kinh-di", "hanh-dong")
    },
    @{
        title = "Ma Trận (The Matrix)"; slug = "the-matrix"; year = 1999; duration = 136;
        desc = "Một lập trình viên phát hiện ra rằng thực tại mà anh đang sống chỉ là một mô phỏng máy tính tinh vi do máy móc thống trị tạo ra để nô dịch con người.";
        poster = "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4";
        status = "PUBLISHED"; featured = $false; views = 18400; cats = @("vien-tuong", "hanh-dong")
    },
    @{
        title = "Ám Ảnh Kinh Hoàng (The Conjuring)"; slug = "the-conjuring"; year = 2013; duration = 112;
        desc = "Hai nhà điều tra hiện tượng siêu nhiên Ed và Lorraine Warren đến trợ giúp một gia đình bị khủng bố bởi linh hồn tà ác trong trang trại hẻo lánh.";
        poster = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $false; views = 9800; cats = @("kinh-di")
    },
    @{
        title = "Kẻ Trộm Mặt Trăng 4 (Despicable Me 4)"; slug = "despicable-me-4"; year = 2024; duration = 94;
        desc = "Gru và gia đình bước vào một chương mới khi đối mặt với kẻ thù nguy hiểm Maxime Le Mal, buộc họ phải chuyển nơi ẩn náu cùng các chú Minion quậy phá.";
        poster = "https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4";
        status = "PUBLISHED"; featured = $false; views = 12600; cats = @("hoat-hinh", "hai-huoc")
    },
    @{
        title = "Mai"; slug = "mai"; year = 2024; duration = 131;
        desc = "Hành trình tình yêu đầy thăng trầm giữa Mai, một phụ nữ làm nghề mát-xa chịu nhiều định kiến, và Dương, chàng nhạc công lãng tử nhà giàu.";
        poster = "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80";
        video = $null; trailer = $null; status = "PUBLISHED"; featured = $true; views = 28100; cats = @("tam-ly", "tinh-cam")
    },
    @{
        title = "Nhà Bà Nữ"; slug = "nha-ba-nu"; year = 2023; duration = 102;
        desc = "Câu chuyện xoay quanh quán bánh canh cua của bà Nữ và những mâu thuẫn thế hệ, định kiến trong một gia đình lao động tại Sài Gòn.";
        poster = "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=600&q=80";
        video = $null; trailer = $null; status = "PUBLISHED"; featured = $false; views = 16700; cats = @("tam-ly", "hai-huoc")
    },
    @{
        title = "Bố Già (The Godfather)"; slug = "the-godfather"; year = 1972; duration = 175;
        desc = "Biên niên sử về gia tộc mafia Corleone hùng mạnh ở New York và sự chuyển giao quyền lực bi kịch giữa người cha Vito và con trai Michael.";
        poster = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $false; views = 35000; cats = @("tam-ly")
    },
    @{
        title = "Hố Sâu Đói Khát (The Platform)"; slug = "the-platform"; year = 2019; duration = 94;
        desc = "Một nhà tù thẳng đứng nơi thức ăn được thả từ tầng cao nhất xuống, buộc các tù nhân ở tầng dưới phải chiến đấu để sinh tồn trong hoàn cảnh khắc nghiệt.";
        poster = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4";
        status = "PUBLISHED"; featured = $false; views = 8400; cats = @("kinh-di", "tam-ly")
    },
    @{
        title = "Đất Rừng Phương Nam"; slug = "dat-rung-phuong-nam"; year = 2023; duration = 134;
        desc = "Hành trình tìm cha đầy thử thách của cậu bé An qua khắp các miền sông nước Nam Bộ trù phú trong bối cảnh kháng chiến chống Pháp đầu thế kỷ 20.";
        poster = "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=600&q=80";
        video = $null; trailer = $null; status = "PUBLISHED"; featured = $false; views = 11200; cats = @("phieu-luu")
    },
    @{
        title = "Vùng Đất Câm Lặng (A Quiet Place)"; slug = "a-quiet-place"; year = 2018; duration = 90;
        desc = "Một gia đình phải sống trong im lặng tuyệt đối tại một vùng quê hoang vắng để tránh sự săn lùng tàn bạo của những sinh vật ngoài hành tinh nhạy bén với âm thanh.";
        poster = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $false; views = 13800; cats = @("kinh-di")
    },
    @{
        title = "Mad Max: Con Đường Tử Thần"; slug = "mad-max-fury-road"; year = 2015; duration = 120;
        desc = "Trong một tương lai hậu tận thế khô cằn, Max Điên hợp tác cùng Furiosa dũng cảm nhằm giải cứu một nhóm phụ nữ khỏi tay tên bạo chúa khát máu Immortan Joe.";
        poster = "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4";
        status = "PUBLISHED"; featured = $false; views = 17200; cats = @("hanh-dong", "phieu-luu")
    },
    @{
        title = "Gia Đình Siêu Nhân 2 (Incredibles 2)"; slug = "incredibles-2"; year = 2018; duration = 118;
        desc = "Trong khi Elastigirl đảm nhận sứ mệnh lấy lại niềm tin cho các siêu anh hùng, Bob Parr phải ở nhà trông nom ba đứa con với những siêu năng lực bùng nổ.";
        poster = "https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=600&q=80";
        video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        trailer = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
        status = "PUBLISHED"; featured = $false; views = 15300; cats = @("hoat-hinh", "hai-huoc")
    },
    @{
        title = "Bi Kịch Của Macbeth"; slug = "the-tragedy-of-macbeth"; year = 2021; duration = 105;
        desc = "Một vị tướng tài ba nghe lời tiên tri của ba mụ phù thủy và sự giục giã của người vợ đầy tham vọng đã quyết định sát hại nhà vua để chiếm ngai vàng.";
        poster = "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=600&q=80";
        video = $null; trailer = $null; status = "PUBLISHED"; featured = $false; views = 4200; cats = @("tam-ly")
    },
    @{
        title = "Dự Án Phim Mới: Thần Thoại (DRAFT)"; slug = "du-an-than-thoai-draft"; year = 2026; duration = 120;
        desc = "Dự án phim điện ảnh thần thoại đang trong quá trình tiền kỳ kịch bản và chuẩn bị quay, chưa công bố trailer chính thức.";
        poster = "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80";
        video = $null; trailer = $null; status = "DRAFT"; featured = $false; views = 0; cats = @("phieu-luu")
    },
    @{
        title = "Dự Án Hoạt Hình Bí Ẩn (DRAFT)"; slug = "hoat-hinh-bi-an-draft"; year = 2026; duration = 95;
        desc = "Dự án phim hoạt hình gia đình phong cách 3D đang được vẽ phác thảo nhân vật.";
        poster = $null; video = $null; trailer = $null; status = "DRAFT"; featured = $false; views = 0; cats = @("hoat-hinh")
    },
    @{
        title = "Bộ Phim Đã Ẩn (HIDDEN)"; slug = "phim-tam-thoi-an-hidden"; year = 2020; duration = 110;
        desc = "Bộ phim tạm thời bị ẩn khỏi danh mục công khai vì lý do bản quyền kiểm duyệt.";
        poster = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80";
        video = $null; trailer = $null; status = "HIDDEN"; featured = $false; views = 210; cats = @("tam-ly")
    }
)

foreach ($m in $movies) {
    $mId = Query-Scalar "SELECT id FROM Movies WHERE slug = @slug" @{ "@slug" = $m.slug }
    if (-not $mId) {
        Execute-SQL @"
INSERT INTO Movies (title, slug, description, release_year, duration_minutes, poster_url, video_url, trailer_url, status, featured, view_count, created_at, updated_at, version)
VALUES (@title, @slug, @desc, @year, @dur, @poster, @video, @trailer, @status, @feat, @views, SYSUTCDATETIME(), SYSUTCDATETIME(), 1)
"@ @{
            "@title" = $m.title
            "@slug" = $m.slug
            "@desc" = $m.desc
            "@year" = [int16]$m.year
            "@dur" = [int16]$m.duration
            "@poster" = $(if ($m.poster) { $m.poster } else { [DBNull]::Value })
            "@video" = $(if ($m.video) { $m.video } else { [DBNull]::Value })
            "@trailer" = $(if ($m.trailer) { $m.trailer } else { [DBNull]::Value })
            "@status" = $m.status
            "@feat" = [bool]$m.featured
            "@views" = [int64]$m.views
        }
        $mId = Query-Scalar "SELECT id FROM Movies WHERE slug = @slug" @{ "@slug" = $m.slug }
        Write-Host " Inserted Movie: $($m.title) (ID=$mId)" -ForegroundColor Green
    }

    # Map categories
    foreach ($cSlug in $m.cats) {
        $cId = Query-Scalar "SELECT id FROM Categories WHERE slug = @cslug" @{ "@cslug" = $cSlug }
        if ($cId) {
            $mcExists = Query-Scalar "SELECT COUNT(*) FROM MovieCategories WHERE movie_id = @mid AND category_id = @cid" @{ "@mid" = $mId; "@cid" = $cId }
            if ($mcExists -eq 0) {
                Execute-SQL "INSERT INTO MovieCategories (movie_id, category_id) VALUES (@mid, @cid)" @{ "@mid" = $mId; "@cid" = $cId }
            }
        }
    }
}

# 4. Seed Favorites
$uTuan = Query-Scalar "SELECT id FROM Users WHERE email = 'tuan.nguyen@moviehub.vn'"
$uMai = Query-Scalar "SELECT id FROM Users WHERE email = 'mai.le@moviehub.vn'"
$uDuc = Query-Scalar "SELECT id FROM Users WHERE email = 'duc.tran@moviehub.vn'"
$uLan = Query-Scalar "SELECT id FROM Users WHERE email = 'lan.pham@moviehub.vn'"
$uHoang = Query-Scalar "SELECT id FROM Users WHERE email = 'hoang.vu@moviehub.vn'"

function Add-Favorite($uId, $slug) {
    $mId = Query-Scalar "SELECT id FROM Movies WHERE slug = @slug" @{ "@slug" = $slug }
    if ($uId -and $mId) {
        $exists = Query-Scalar "SELECT COUNT(*) FROM Favorites WHERE user_id = @uid AND movie_id = @mid" @{ "@uid" = $uId; "@mid" = $mId }
        if ($exists -eq 0) {
            Execute-SQL "INSERT INTO Favorites (user_id, movie_id, created_at) VALUES (@uid, @mid, SYSUTCDATETIME())" @{ "@uid" = $uId; "@mid" = $mId }
        }
    }
}

@("interstellar", "inception", "dune-part-1", "the-dark-knight") | ForEach-Object { Add-Favorite $uTuan $_ }
@("spirited-away", "mai", "parasite", "spider-man-across-the-spider-verse") | ForEach-Object { Add-Favorite $uMai $_ }
@("oppenheimer", "the-godfather", "dune-part-2") | ForEach-Object { Add-Favorite $uDuc $_ }
@("the-conjuring", "a-quiet-place", "train-to-busan") | ForEach-Object { Add-Favorite $uLan $_ }
@("incredibles-2", "despicable-me-4", "the-matrix", "mad-max-fury-road") | ForEach-Object { Add-Favorite $uHoang $_ }
Write-Host " Seeded Favorites" -ForegroundColor Green

# 5. Seed Reviews
$uAdmin = Query-Scalar "SELECT id FROM Users WHERE email = 'admin@moviehub.vn'"

function Add-Review($uId, $slug, $rating, $content, $status) {
    $mId = Query-Scalar "SELECT id FROM Movies WHERE slug = @slug" @{ "@slug" = $slug }
    if ($uId -and $mId) {
        $exists = Query-Scalar "SELECT COUNT(*) FROM Reviews WHERE user_id = @uid AND movie_id = @mid" @{ "@uid" = $uId; "@mid" = $mId }
        if ($exists -eq 0) {
            Execute-SQL @"
INSERT INTO Reviews (user_id, movie_id, rating, content, status, moderated_by, moderated_at, created_at, updated_at, version, content_revision)
VALUES (@uid, @mid, @rating, @content, @status, @modby, @modat, SYSUTCDATETIME(), SYSUTCDATETIME(), 1, 1)
"@ @{
                "@uid" = $uId; "@mid" = $mId; "@rating" = [byte]$rating; "@content" = $content; "@status" = $status;
                "@modby" = $(if ($status -eq "APPROVED") { $uAdmin } else { [DBNull]::Value });
                "@modat" = $(if ($status -eq "APPROVED") { (Get-Date).ToUniversalTime() } else { [DBNull]::Value })
            }
        }
    }
}

Add-Review $uTuan "interstellar" 5 "Tác phẩm khoa học viễn tưởng vĩ đại nhất của Christopher Nolan! Nhạc phim của Hans Zimmer thật sự xuất sắc." "APPROVED"
Add-Review $uMai "interstellar" 5 "Tình cha con giữa Cooper và Murph đã lấy đi rất nhiều nước mắt của mình. Đoạn thông điệp qua kim đồng hồ thật xúc động." "APPROVED"
Add-Review $uDuc "inception" 5 "Kịch bản phân tầng giấc mơ quá xuất sắc. Cảnh quay hành lang xoay tròn vẫn là đỉnh cao của kỹ xảo thực tế." "APPROVED"
Add-Review $uLan "the-dark-knight" 5 "Diễn xuất của Heath Ledger trong vai Joker xứng đáng là huyền thoại điện ảnh thế giới." "APPROVED"
Add-Review $uHoang "dune-part-1" 4 "Hình ảnh hoành tráng, thiết kế âm thanh choáng ngợp. Nhịp phim nửa đầu hơi chậm nhưng càng về sau càng hấp dẫn." "APPROVED"
Add-Review $uTuan "dune-part-2" 5 "Phần 2 bùng nổ vượt bậc so với phần 1! Trận chiến trên sa mạc và màn cưỡi sâu cát mãn nhãn không thể tin nổi." "APPROVED"
Add-Review $uMai "parasite" 5 "Một tác phẩm châm biếm sâu sắc và tàn nhẫn về khoảng cách giàu nghèo. Cú plot twist ở căn hầm khiến người xem chết lặng." "APPROVED"
Add-Review $uDuc "oppenheimer" 5 "Phim tiểu sử nhưng nhịp độ căng thẳng nghẹt thở như một phim gián điệp trinh thám. Cillian Murphy diễn xuất đỉnh cao." "APPROVED"
Add-Review $uLan "spirited-away" 5 "Một thế giới cổ tích kỳ ảo chứa đựng những bài học trưởng thành tuyệt vời từ Studio Ghibli." "APPROVED"
Add-Review $uHoang "oppenheimer" 4 "Thời lượng 3 tiếng hơi dài đối với người không rành lịch sử Mỹ nhưng cảnh thử bom Trinity rất ấn tượng." "PENDING"
Write-Host " Seeded Reviews" -ForegroundColor Green

# 6. Seed Questions & Answers
function Add-Question-Answer($mSlug, $qUid, $qContent, $qStatus, $aUid, $aContent, $aStatus) {
    $mId = Query-Scalar "SELECT id FROM Movies WHERE slug = @slug" @{ "@slug" = $mSlug }
    if ($mId -and $qUid) {
        $qId = Query-Scalar "SELECT id FROM Questions WHERE movie_id = @mid AND user_id = @uid AND content = @c" @{ "@mid" = $mId; "@uid" = $qUid; "@c" = $qContent }
        if (-not $qId) {
            Execute-SQL @"
INSERT INTO Questions (movie_id, user_id, content, status, moderated_by, moderated_at, created_at, version)
VALUES (@mid, @uid, @content, @status, @modby, @modat, SYSUTCDATETIME(), 1)
"@ @{
                "@mid" = $mId; "@uid" = $qUid; "@content" = $qContent; "@status" = $qStatus;
                "@modby" = $(if ($qStatus -eq "APPROVED") { $uAdmin } else { [DBNull]::Value });
                "@modat" = $(if ($qStatus -eq "APPROVED") { (Get-Date).ToUniversalTime() } else { [DBNull]::Value })
            }
            $qId = Query-Scalar "SELECT id FROM Questions WHERE movie_id = @mid AND user_id = @uid AND content = @c" @{ "@mid" = $mId; "@uid" = $qUid; "@c" = $qContent }
        }

        if ($qId -and $aUid -and $aContent) {
            $aExists = Query-Scalar "SELECT COUNT(*) FROM Answers WHERE question_id = @qid AND user_id = @uid" @{ "@qid" = $qId; "@uid" = $aUid }
            if ($aExists -eq 0) {
                Execute-SQL @"
INSERT INTO Answers (question_id, user_id, content, status, moderated_by, moderated_at, created_at, version)
VALUES (@qid, @uid, @content, @status, @modby, @modat, SYSUTCDATETIME(), 1)
"@ @{
                    "@qid" = $qId; "@uid" = $aUid; "@content" = $aContent; "@status" = $aStatus;
                    "@modby" = $(if ($aStatus -eq "APPROVED") { $uAdmin } else { [DBNull]::Value });
                    "@modat" = $(if ($aStatus -eq "APPROVED") { (Get-Date).ToUniversalTime() } else { [DBNull]::Value })
                }
            }
        }
    }
}

Add-Question-Answer "interstellar" $uDuc "Vì sao 1 giờ ở hành tinh nước của Miller lại bằng 7 năm trên Trái Đất?" "APPROVED" `
    $uTuan "Do hành tinh Miller nằm rất gần siêu lỗ đen Gargantua, trường hấp dẫn khổng lồ đã bẻ cong không thời gian theo thuyết tương đối rộng của Einstein." "APPROVED"

Add-Question-Answer "inception" $uLan "Con quay ở cuối phim có dừng lại không mọi người ơi?" "APPROVED" `
    $uMai "Đạo diễn Christopher Nolan từng chia sẻ rằng điểm cốt lõi là Cobb đã không còn quan tâm con quay có ngã hay không, vì anh đã chấp nhận thực tại hạnh phúc bên các con." "APPROVED"

Add-Question-Answer "dune-part-1" $uHoang "Hương dược (Spice) trên hành tinh cát có tác dụng gì quan trọng nhất?" "PENDING" $null $null $null

Write-Host " Seeded Questions & Answers" -ForegroundColor Green

$conn.Close()
Write-Host "Database Seeding Completed Successfully!" -ForegroundColor Green
