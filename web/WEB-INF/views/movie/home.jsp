<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="MovieHub - Trải nghiệm điện ảnh đỉnh cao không giới hạn. Khám phá kho tàng phim bom tấn, xem phim trực tiếp, đánh giá minh bạch và tham gia cộng đồng yêu phim.">
    <title>MovieHub - Trải Nghiệm Điện Ảnh Đỉnh Cao Không Giới Hạn</title>
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <script src="${ctx}/assets/js/catalog.js" charset="UTF-8" defer></script>
</head>
<body>
    <mh:header active="home" />

    <main class="mh-landing-main">
        <!-- Ambient Cinema Glow Spotlights -->
        <div class="mh-landing-hero-wrap">
            <div class="mh-glow-spot-1" aria-hidden="true"></div>
            <div class="mh-glow-spot-2" aria-hidden="true"></div>

            <!-- 1. HERO SECTION -->
            <section class="mh-landing-hero" aria-label="Giới thiệu MovieHub">
                <div class="mh-landing-pill">
                    <span class="mh-pill-dot" aria-hidden="true"></span>
                    <span>Cổng Trải Nghiệm Chuẩn Rạp</span>
                    <span style="opacity: 0.5;">•</span>
                    <span>Phiên Bản 2026</span>
                </div>

                <h1 class="mh-landing-title">
                    Trải Nghiệm Điện Ảnh Đỉnh Cao <br>
                    <span class="mh-gradient-text">Không Giới Hạn</span>
                </h1>

                <p class="mh-landing-desc">
                    Khám phá kho tàng tác phẩm điện ảnh kinh điển và bom tấn chiếu rạp với hình ảnh sắc nét, âm thanh sống động, cộng đồng đánh giá minh bạch và hệ thống hỏi đáp thảo luận tương tác.
                </p>

                <div class="mh-landing-ctas">
                    <c:choose>
                        <c:when test="${not empty sessionScope.userId}">
                            <a href="${ctx}/movies" class="mh-btn-hero-primary">
                                <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden="true"><polygon points="6 4 20 12 6 20 6 4"/></svg>
                                <span>Khám phá kho phim ngay</span>
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${ctx}/register" class="mh-btn-hero-primary">
                                <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20" aria-hidden="true"><polygon points="6 4 20 12 6 20 6 4"/></svg>
                                <span>Bắt đầu trải nghiệm miễn phí</span>
                            </a>
                        </c:otherwise>
                    </c:choose>
                    <a href="#kham-pha-bo-suu-tap" class="mh-btn-hero-secondary">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="18" height="18" aria-hidden="true"><rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18"/><line x1="7" y1="2" x2="7" y2="22"/><line x1="17" y1="2" x2="17" y2="22"/><line x1="2" y1="12" x2="22" y2="12"/><line x1="2" y1="7" x2="7" y2="7"/><line x1="2" y1="17" x2="7" y2="17"/><line x1="17" y1="17" x2="22" y2="17"/><line x1="17" y1="7" x2="22" y2="7"/></svg>
                        <span>Khám phá danh mục phim</span>
                    </a>
                </div>

                <!-- Cinema Trust Indicators Bar -->
                <div class="mh-trust-bar">
                    <div class="mh-trust-item">
                        <svg class="mh-trust-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                        <span class="mh-trust-title">Đa Dạng Thể Loại</span>
                        <span class="mh-trust-sub">Từ bom tấn hành động đến nghệ thuật</span>
                    </div>
                    <div class="mh-trust-item">
                        <svg class="mh-trust-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--mh-rating);" aria-hidden="true"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        <span class="mh-trust-title">Độ Nét Cao 1080p</span>
                        <span class="mh-trust-sub">Âm thanh sống động & phát trực tiếp</span>
                    </div>
                    <div class="mh-trust-item">
                        <svg class="mh-trust-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        <span class="mh-trust-title">100% Sạch Sẽ</span>
                        <span class="mh-trust-sub">Không chèn quảng cáo rác phiền toái</span>
                    </div>
                    <div class="mh-trust-item">
                        <svg class="mh-trust-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        <span class="mh-trust-title">Cộng Đồng Cinephile</span>
                        <span class="mh-trust-sub">Đánh giá đa chiều & hỏi đáp tương tác</span>
                    </div>
                </div>
            </section>
        </div>

        <div class="mh-landing-container">
            <!-- FEATURED SPOTLIGHT BILLBOARD (IF AVAILABLE IN DB) -->
            <c:if test="${not empty home.featured}">
                <c:url var="featuredUrl" value="/movies/detail">
                    <c:param name="id" value="${home.featured.id}" />
                </c:url>
                <section class="mh-hero" aria-label="Phim tiêu điểm nổi bật" style="margin-top: 16px;">
                    <c:if test="${not empty home.featured.posterUrl}">
                        <img class="mh-hero-bg" src="<c:out value="${home.featured.posterUrl}" escapeXml="true" />"
                             alt="" referrerpolicy="no-referrer" data-fallback="${ctx}/assets/img/poster-placeholder.svg">
                    </c:if>
                    <div class="mh-hero-shade"></div>
                    <div class="mh-hero-content">
                        <span class="mh-badge mh-badge-primary">Tiêu Điểm Điện Ảnh</span>
                        <h2 class="mh-hero-title"><c:out value="${home.featured.title}" escapeXml="true" /></h2>
                        <p class="mh-hero-meta">
                            <c:out value="${home.featured.releaseYear}" />
                            <span class="mh-dot"></span>
                            <c:choose>
                                <c:when test="${home.featured.rated}">★ <c:out value="${home.featured.ratingText}" /></c:when>
                                <c:otherwise>Chưa có đánh giá</c:otherwise>
                            </c:choose>
                        </p>
                        <a href="${featuredUrl}" class="mh-btn mh-btn-primary" style="height: 48px; border-radius: 9999px; padding: 0 28px;">
                            <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18" style="margin-right: 8px;"><polygon points="6 4 20 12 6 20 6 4"/></svg>
                            Xem chi tiết & Thưởng thức
                        </a>
                    </div>
                </section>
            </c:if>

            <!-- 2. REAL MOVIE CATALOG SHOWCASE -->
            <section class="mh-section" id="kham-pha-bo-suu-tap" aria-label="Bộ sưu tập phim thực tế" style="padding-top: 24px;">
                <div class="mh-landing-sec-head">
                    <span class="mh-sec-tag">
                        <svg viewBox="0 0 24 24" fill="currentColor" width="14" height="14" aria-hidden="true"><path d="M12 23c6.075 0 11-4.925 11-11S18.075 1 12 1 1 5.925 1 12s4.925 11 11 11zm1-18v3.5a1.5 1.5 0 0 0 3 0V5.26c3.27.91 5.73 3.65 6.47 7.03-.7-.41-1.52-.64-2.47-.64-2.76 0-5 2.24-5 5 0 .95.23 1.77.64 2.47-3.38-.74-6.12-3.2-7.03-6.47H8.5a1.5 1.5 0 0 0 0-3H5.26C6.17 6.27 8.91 3.53 12.29 2.62A4.47 4.47 0 0 1 13 5z"/></svg>
                        Tuyển Chọn Đang Thịnh Hành
                    </span>
                    <h2 class="mh-landing-sec-title">Tuyệt Tác Điện Ảnh Khuyên Xem</h2>
                    <p class="mh-landing-sec-desc">
                        Khung hình tỉ lệ vàng 2:3 với siêu dữ liệu kiểm duyệt kỹ lưỡng, hỗ trợ phát trực tiếp và nhúng video chất lượng cao sẵn sàng stream ngay tại MovieHub.
                    </p>
                </div>

                <c:if test="${home.noMovies}">
                    <div class="mh-empty">
                        <p class="mh-empty-title">Chưa có phim</p>
                        <p class="mh-empty-desc">Hiện chưa có phim nào được công bố. Vui lòng quay lại sau.</p>
                    </div>
                </c:if>

                <mh:movieRow sectionId="sec-views" title="Xem nhiều nhất" items="${home.mostViewed}"
                             moreHref="${ctx}/movies?sort=views" />
                <mh:movieRow sectionId="sec-newest" title="Mới cập nhật" items="${home.newest}"
                             moreHref="${ctx}/movies?sort=newest" />
                <mh:movieRow sectionId="sec-rating" title="Đánh giá cao nhất" items="${home.topRated}"
                             moreHref="${ctx}/movies?sort=rating" />
            </section>
        </div>

        <!-- 3. VALUE PROPOSITION / FEATURE PILLARS -->
        <section class="mh-pillars-section" aria-label="Đặc quyền khác biệt">
            <div class="mh-landing-container">
                <div class="mh-landing-sec-head">
                    <span class="mh-sec-tag">Đặc Quyền Khác Biệt</span>
                    <h2 class="mh-landing-sec-title">Công Nghệ Điện Ảnh Định Danh MovieHub</h2>
                    <p class="mh-landing-sec-desc">
                        Được xây dựng trên nền tảng kiến trúc hiện đại, tối ưu hóa tốc độ tải và nâng niu từng khung hình nguyên bản của tác phẩm.
                    </p>
                </div>

                <div class="mh-pillars-grid">
                    <!-- Pillar 1 -->
                    <div class="mh-pillar-card">
                        <div class="mh-pillar-icon-box">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="28" height="28" aria-hidden="true"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                        </div>
                        <h3 class="mh-pillar-title">Chuẩn Rạp Tại Gia</h3>
                        <p class="mh-pillar-desc">
                            Băng thông truyền tải cao, tương thích phát trực tiếp và nhúng YouTube mượt mà, giữ trọn vẹn dải sáng tương phản và độ nét chân thực.
                        </p>
                    </div>

                    <!-- Pillar 2 -->
                    <div class="mh-pillar-card">
                        <div class="mh-pillar-icon-box" style="background: rgba(251, 180, 0, 0.12); color: var(--mh-rating-text);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="28" height="28" aria-hidden="true"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        </div>
                        <h3 class="mh-pillar-title">Đánh Giá Thực Chất</h3>
                        <p class="mh-pillar-desc">
                            Cơ chế chấm sao 1-5 điểm minh bạch, bình luận đa chiều và thuật toán chống thao túng điểm số giúp phản ánh chính xác cảm nhận người xem.
                        </p>
                    </div>

                    <!-- Pillar 3 -->
                    <div class="mh-pillar-card">
                        <div class="mh-pillar-icon-box" style="background: rgba(190, 198, 222, 0.12); color: #bec6de;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="28" height="28" aria-hidden="true"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                        </div>
                        <h3 class="mh-pillar-title">Góc Q&A Tương Tác</h3>
                        <p class="mh-pillar-desc">
                            Cộng đồng Cinephile sôi nổi cùng mổ xẻ Easter Egg, giải mã cú twist bất ngờ và trao đổi giải đáp câu hỏi trực tiếp cùng người cùng đam mê.
                        </p>
                    </div>

                    <!-- Pillar 4 -->
                    <div class="mh-pillar-card">
                        <div class="mh-pillar-icon-box">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="28" height="28" aria-hidden="true"><rect x="4" y="2" width="16" height="20" rx="2" ry="2"/><line x1="12" y1="18" x2="12.01" y2="18"/></svg>
                        </div>
                        <h3 class="mh-pillar-title">Đồng Bộ Mọi Thiết Bị</h3>
                        <p class="mh-pillar-desc">
                            Lưu danh sách phim yêu thích cá nhân tức thì trên trình duyệt máy tính, iPad lẫn điện thoại thông minh chỉ với một tài khoản duy nhất.
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <!-- 4. HOW IT WORKS (3 SIMPLE STEPS) -->
        <section class="mh-steps-section" aria-label="Quy trình trải nghiệm">
            <div class="mh-landing-container">
                <div class="mh-landing-sec-head">
                    <span class="mh-sec-tag">Quy Trình Đơn Giản</span>
                    <h2 class="mh-landing-sec-title">Chỉ 3 Bước Đặt Chân Vào Thế Giới Điện Ảnh</h2>
                    <p class="mh-landing-sec-desc">Không cần thẻ tín dụng, trải nghiệm mượt mà ngay trong vài cú nhấp chuột.</p>
                </div>

                <div class="mh-steps-grid">
                    <!-- Step 1 -->
                    <div class="mh-step-card">
                        <div class="mh-step-num">01</div>
                        <h3 class="mh-step-title">Khởi Tạo Tài Khoản</h3>
                        <p class="mh-step-desc">
                            Đăng ký định danh thành viên chỉ mất 30 giây với địa chỉ email hoặc tên người dùng yêu thích của bạn.
                        </p>
                    </div>

                    <!-- Step 2 -->
                    <div class="mh-step-card">
                        <div class="mh-step-num" style="color: var(--mh-rating-text); border-color: rgba(251, 180, 0, 0.4);">02</div>
                        <h3 class="mh-step-title">Cá Nhân Hóa Thư Viện</h3>
                        <p class="mh-step-desc">
                            Lựa chọn thể loại ưa chuộng, tìm kiếm tựa phim yêu thích và lưu vào danh sách bộ sưu tập cá nhân.
                        </p>
                    </div>

                    <!-- Step 3 -->
                    <div class="mh-step-card">
                        <div class="mh-step-num">03</div>
                        <h3 class="mh-step-title">Thưởng Thức & Giao Lưu</h3>
                        <p class="mh-step-desc">
                            Thưởng thức phim độ nét cao, đọc các bài phân tích sâu sắc và tham gia trao đổi giải đáp câu hỏi cùng cộng đồng.
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <!-- 5. MEMBERSHIP TIERS -->
        <section class="mh-tiers-section" aria-label="Gói trải nghiệm">
            <div class="mh-landing-container">
                <div class="mh-landing-sec-head">
                    <span class="mh-sec-tag">Đăng Ký Linh Hoạt</span>
                    <h2 class="mh-landing-sec-title">Lựa Chọn Trải Nghiệm Của Bạn</h2>
                    <p class="mh-landing-sec-desc">Các gói thành viên được thiết kế minh bạch phục vụ trải nghiệm học tập và giải trí.</p>
                </div>

                <div class="mh-tiers-grid">
                    <!-- Tier 1: Free Guest -->
                    <div class="mh-tier-card">
                        <div>
                            <div class="mh-tier-head">
                                <span class="mh-tier-name">Khách Vãng Lai & Người Dùng Mới</span>
                                <span class="mh-tier-tag">CƠ BẢN</span>
                            </div>
                            <div class="mh-tier-price">
                                <span class="mh-price-val">0đ</span>
                                <span class="mh-price-unit">/ vĩnh viễn</span>
                            </div>
                            <p class="mh-tier-desc">
                                Dành cho người xem muốn tra cứu thông tin phim ảnh, đạo diễn, và xem các trailer demo độ nét tiêu chuẩn.
                            </p>
                            <ul class="mh-tier-list">
                                <li class="mh-tier-item">
                                    <svg class="mh-tier-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Xem trailer độ phân giải Full HD 1080p</span>
                                </li>
                                <li class="mh-tier-item">
                                    <svg class="mh-tier-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Tra cứu thông số kho phim phong phú</span>
                                </li>
                                <li class="mh-tier-item">
                                    <svg class="mh-tier-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Đọc review & mục hỏi đáp cộng đồng</span>
                                </li>
                                <li class="mh-tier-item is-disabled">
                                    <svg class="mh-tier-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                    <span>Không hỗ trợ lưu danh sách yêu thích cá nhân</span>
                                </li>
                            </ul>
                        </div>
                        <a href="${ctx}/movies" class="mh-btn mh-btn-secondary" style="border-radius: 12px; width: 100%;">
                            Khám phá phim ngay
                        </a>
                    </div>

                    <!-- Tier 2: Cinephile Member -->
                    <div class="mh-tier-card is-popular">
                        <span class="mh-tier-badge-top">ĐƯỢC YÊU THÍCH NHẤT</span>
                        <div>
                            <div class="mh-tier-head">
                                <span class="mh-tier-name">Thành Viên Cinephile VIP</span>
                                <span class="mh-tier-tag">FULL ACCESS</span>
                            </div>
                            <div class="mh-tier-price">
                                <span class="mh-price-val">Miễn phí</span>
                                <span class="mh-price-unit">/ Trải nghiệm</span>
                            </div>
                            <p class="mh-tier-desc">
                                Trọn vẹn quyền hạn thành viên: Đánh giá sao, tương tác Q&A trực tiếp, và tạo danh sách phim tâm đắc.
                            </p>
                            <ul class="mh-tier-list">
                                <li class="mh-tier-item">
                                    <svg class="mh-tier-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Trải nghiệm xem phim sắc nét, mượt mà</span>
                                </li>
                                <li class="mh-tier-item">
                                    <svg class="mh-tier-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Lưu danh sách yêu thích cá nhân không giới hạn</span>
                                </li>
                                <li class="mh-tier-item">
                                    <svg class="mh-tier-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Chấm sao 1-5★ & viết bài phê bình phim</span>
                                </li>
                                <li class="mh-tier-item">
                                    <svg class="mh-tier-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Đặt câu hỏi tại góc Q&A & nhận phản hồi từ cộng đồng</span>
                                </li>
                            </ul>
                        </div>
                        <c:choose>
                            <c:when test="${not empty sessionScope.userId}">
                                <a href="${ctx}/profile" class="mh-btn mh-btn-primary" style="border-radius: 12px; width: 100%;">
                                    Tài khoản đang hoạt động
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${ctx}/register" class="mh-btn mh-btn-primary" style="border-radius: 12px; width: 100%;">
                                    Gia nhập Cinephile ngay
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </section>

        <!-- 6. FAQ ACCORDION -->
        <section class="mh-faq-section" aria-label="Câu hỏi thường gặp">
            <div class="mh-landing-container">
                <div class="mh-landing-sec-head">
                    <span class="mh-sec-tag">Giải Đáp Thắc Mắc</span>
                    <h2 class="mh-landing-sec-title">Câu Hỏi Thường Gặp</h2>
                    <p class="mh-landing-sec-desc">Tất cả những thông tin bạn cần biết về nền tảng MovieHub.</p>
                </div>

                <div class="mh-faq-list">
                    <!-- FAQ 1 -->
                    <div class="mh-faq-item is-open">
                        <button type="button" class="mh-faq-btn">
                            <span>MovieHub có thu phí dịch vụ của người dùng không?</span>
                            <svg class="mh-faq-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="6 9 12 15 18 9"/></svg>
                        </button>
                        <div class="mh-faq-body">
                            Hoàn toàn không. MovieHub được phát triển phục vụ trải nghiệm xem phim và thảo luận trực tuyến. Toàn bộ tính năng từ xem phim, lưu danh sách yêu thích, viết đánh giá và hỏi đáp Q&A đều mở miễn phí 100% cho người dùng trải nghiệm.
                        </div>
                    </div>

                    <!-- FAQ 2 -->
                    <div class="mh-faq-item">
                        <button type="button" class="mh-faq-btn">
                            <span>Nền tảng hỗ trợ những thiết bị và trình duyệt nào?</span>
                            <svg class="mh-faq-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="6 9 12 15 18 9"/></svg>
                        </button>
                        <div class="mh-faq-body">
                            MovieHub được tối ưu hóa giao diện thích ứng (responsive) theo tiêu chuẩn hiện đại, hoạt động mượt mà trên Google Chrome, Mozilla Firefox, Microsoft Edge và Safari trên cả máy tính để bàn (Windows, macOS), máy tính bảng và điện thoại di động (iOS, Android).
                        </div>
                    </div>

                    <!-- FAQ 3 -->
                    <div class="mh-faq-item">
                        <button type="button" class="mh-faq-btn">
                            <span>Video phim và trailer được phát từ đâu?</span>
                            <svg class="mh-faq-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="6 9 12 15 18 9"/></svg>
                        </button>
                        <div class="mh-faq-body">
                            Hệ thống hỗ trợ phát trực tiếp video và nhúng các nguồn media chất lượng cao từ YouTube với tỷ lệ khung hình 16:9 chuẩn rạp, đảm bảo tốc độ tải nhanh chóng với chất lượng hình ảnh sắc nét nhất.
                        </div>
                    </div>

                    <!-- FAQ 4 -->
                    <div class="mh-faq-item">
                        <button type="button" class="mh-faq-btn">
                            <span>Làm cách nào để đóng góp đánh giá và tham gia hỏi đáp?</span>
                            <svg class="mh-faq-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="6 9 12 15 18 9"/></svg>
                        </button>
                        <div class="mh-faq-body">
                            Bạn chỉ cần đăng ký một tài khoản miễn phí. Sau khi đăng nhập, bạn có thể chấm điểm từ 1 đến 5 sao, viết cảm nhận chi tiết ở từng bộ phim hoặc đặt câu hỏi tại mục Q&A để cùng cộng đồng Cinephile thảo luận.
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 7. BOTTOM HEROIC CTA BANNER -->
        <div class="mh-landing-container">
            <section class="mh-bottom-cta" aria-label="Kêu gọi tham gia">
                <div class="mh-bottom-cta-glow-1" aria-hidden="true"></div>
                <div class="mh-bottom-cta-glow-2" aria-hidden="true"></div>

                <div class="mh-bottom-cta-icon">
                    <svg viewBox="0 0 24 24" fill="currentColor" width="30" height="30" aria-hidden="true"><path d="M18 4l2 4h-3l-2-4h-2l2 4h-3l-2-4H8l2 4H7L5 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4h-4z"/></svg>
                </div>

                <h2 class="mh-bottom-cta-title">
                    Sẵn Sàng Đắm Chìm Vào Thế Giới Điện Ảnh?
                </h2>

                <p class="mh-bottom-cta-desc">
                    Khám phá ngay hàng trăm bộ phim đặc sắc và kết nối cùng cộng đồng người hâm mộ điện ảnh sôi động tại MovieHub.
                </p>

                <div class="mh-bottom-cta-actions">
                    <c:choose>
                        <c:when test="${not empty sessionScope.userId}">
                            <a href="${ctx}/movies" class="mh-btn-hero-primary">
                                <span>Khám phá kho phim ngay</span>
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" width="18" height="18" aria-hidden="true"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${ctx}/register" class="mh-btn-hero-primary">
                                <span>Đăng ký thành viên ngay</span>
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" width="18" height="18" aria-hidden="true"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                            </a>
                            <a href="${ctx}/movies" class="mh-btn-hero-secondary">
                                <span>Xem danh mục phim</span>
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>

                <p class="mh-bottom-cta-trust">
                    Miễn phí trải nghiệm • Không quảng cáo phiền toái • Bảo mật tuyệt đối
                </p>
            </section>
        </div>
    </main>

    <mh:footer />
</body>
</html>
