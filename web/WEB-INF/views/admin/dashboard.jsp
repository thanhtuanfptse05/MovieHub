<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="adminSection" value="dashboard" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Bảng điều khiển quản trị và số liệu phân tích Studio hệ thống MovieHub">
    <title>Tổng quan &amp; Phân tích | MovieHub Studio</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <!-- Studio Header Banner -->
    <div class="mh-studio-header">
        <div class="mh-studio-header-content">
            <div class="mh-studio-badge">
                <span class="mh-pulse-dot"></span>
                <span>MOVIEHUB STUDIO ANALYTICS</span>
            </div>
            <h1 class="mh-studio-title">Phân tích hệ thống &amp; Hiệu suất rạp phim</h1>
            <p class="mh-studio-subtitle">
                Số liệu hiệu suất lượt xem toàn hệ thống, xu hướng nội dung và phân bố thể loại theo thời gian thực.
            </p>
        </div>
        <div class="mh-studio-header-meta">
            <div class="mh-studio-timeframe">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14" aria-hidden="true">
                    <circle cx="12" cy="12" r="10"></circle>
                    <polyline points="12 6 12 12 16 14"></polyline>
                </svg>
                <span>Toàn bộ thời gian (Tất cả phim)</span>
            </div>
        </div>
    </div>

    <%@ include file="notices.jspf" %>

    <!-- Executive KPI Metric Cards (YouTube Studio Metric Tabs) -->
    <section class="mh-studio-kpi-grid" aria-label="Các chỉ số hiệu suất chính">
        <!-- KPI 1: Tổng lượt xem -->
        <article class="mh-studio-kpi-card mh-kpi-primary">
            <div class="mh-kpi-head">
                <span class="mh-kpi-category">LƯỢT XEM TÍCH LŨY</span>
                <span class="mh-kpi-icon-wrap" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="18" height="18">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                        <circle cx="12" cy="12" r="3"></circle>
                    </svg>
                </span>
            </div>
            <div class="mh-kpi-main-val">
                <fmt:formatNumber value="${dashboard.totalViews}" />
            </div>
            <div class="mh-kpi-footer-note">
                <span>Cao nhất: <strong><c:out value="${dashboard.maxViewsText}" /></strong></span>
                <span class="mh-dot-sep">•</span>
                <span>Thấp nhất: <strong><c:out value="${dashboard.minViewsText}" /></strong></span>
            </div>
        </article>

        <!-- KPI 2: Kho phim hệ thống -->
        <article class="mh-studio-kpi-card">
            <div class="mh-kpi-head">
                <span class="mh-kpi-category">KHO PHIM HỆ THỐNG</span>
                <span class="mh-kpi-icon-wrap" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="18" height="18">
                        <rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18"></rect>
                        <line x1="7" y1="2" x2="7" y2="22"></line>
                        <line x1="17" y1="2" x2="17" y2="22"></line>
                        <line x1="2" y1="12" x2="22" y2="12"></line>
                    </svg>
                </span>
            </div>
            <div class="mh-kpi-main-val">
                <fmt:formatNumber value="${dashboard.totalMovies}" />
            </div>
            <div class="mh-kpi-footer-note">
                <span>Đang công khai: <strong><fmt:formatNumber value="${dashboard.publishedMovies}" /></strong></span>
                <span class="mh-dot-sep">•</span>
                <span style="color: var(--mh-text-muted);">Mọi trạng thái</span>
            </div>
        </article>

        <!-- KPI 3: Khán giả & Người dùng -->
        <article class="mh-studio-kpi-card">
            <div class="mh-kpi-head">
                <span class="mh-kpi-category">NGƯỜI DÙNG THÀNH VIÊN</span>
                <span class="mh-kpi-icon-wrap" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="18" height="18">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                    </svg>
                </span>
            </div>
            <div class="mh-kpi-main-val">
                <fmt:formatNumber value="${dashboard.totalUsers}" />
            </div>
            <div class="mh-kpi-footer-note">
                <span>Tài khoản thành viên (Role USER)</span>
            </div>
        </article>

        <!-- KPI 4: Đánh giá & Hài lòng -->
        <article class="mh-studio-kpi-card">
            <div class="mh-kpi-head">
                <span class="mh-kpi-category">ĐÁNH GIÁ TRUNG BÌNH</span>
                <span class="mh-kpi-icon-wrap" aria-hidden="true" style="color: #f59e0b;">
                    <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18">
                        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                    </svg>
                </span>
            </div>
            <div class="mh-kpi-main-val" style="color: #f59e0b;">
                <c:choose>
                    <c:when test="${not empty dashboard.averageRating}">
                        ★ <c:out value="${dashboard.averageRatingText}" />
                    </c:when>
                    <c:otherwise>N/A</c:otherwise>
                </c:choose>
            </div>
            <div class="mh-kpi-footer-note">
                <span>Dựa trên <fmt:formatNumber value="${dashboard.totalReviews}" /> đánh giá (mọi phim)</span>
            </div>
        </article>

        <!-- KPI 5: Hàng đợi duyệt -->
        <article class="mh-studio-kpi-card mh-kpi-moderation">
            <div class="mh-kpi-head">
                <span class="mh-kpi-category">HÀNG ĐỢI KIỂM DUYỆT</span>
                <span class="mh-kpi-icon-wrap" aria-hidden="true" style="color: #ef4444;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="18" height="18">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                        <polyline points="9 11 12 14 22 4"></polyline>
                    </svg>
                </span>
            </div>
            <div class="mh-kpi-main-val" style="color: #ef4444;">
                <fmt:formatNumber value="${dashboard.totalPending}" />
            </div>
            <div class="mh-kpi-chips">
                <span class="mh-mini-chip">Review: <c:out value="${dashboard.pendingReviews}" /></span>
                <span class="mh-mini-chip">Hỏi: <c:out value="${dashboard.pendingQuestions}" /></span>
                <span class="mh-mini-chip">Đáp: <c:out value="${dashboard.pendingAnswers}" /></span>
            </div>
        </article>
    </section>

    <!-- YouTube Studio Visual Line Chart (Biểu đồ đường xu hướng lượt xem Top phim) -->
    <section class="mh-studio-chart-card" aria-label="Biểu đồ xu hướng lượt xem">
        <div class="mh-chart-header">
            <div>
                <h2 class="mh-chart-title">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="20" height="20" style="color: #f59e0b; display: inline-block; vertical-align: -3px; margin-right: 6px;">
                        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline>
                    </svg>
                    Biểu đồ xu hướng lượt xem Top 5 phim
                </h2>
                <p class="mh-chart-subtitle">
                    Đường biểu diễn phân bố tương tác giữa các tác phẩm dẫn đầu hệ thống (xếp hạng theo tổng lượt xem toàn thời gian)
                </p>
            </div>
            <div class="mh-chart-legend">
                <span class="mh-legend-item">
                    <span class="mh-legend-color" style="background: #f59e0b;"></span>
                    <span>Lượt xem phim</span>
                </span>
            </div>
        </div>

        <c:choose>
            <c:when test="${not empty dashboard.topMovies}">
                <c:set var="totalTop" value="${fn:length(dashboard.topMovies)}" />
                <c:set var="maxV" value="${dashboard.maxViews > 0 ? dashboard.maxViews : 1}" />
                <div class="mh-studio-chart-wrapper" id="chart-container">
                    <svg viewBox="0 0 760 260" class="mh-studio-svg-chart" preserveAspectRatio="none" aria-label="Biểu đồ đường lượt xem">
                        <defs>
                            <linearGradient id="studioChartGrad" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="0%" stop-color="#f59e0b" stop-opacity="0.32"/>
                                <stop offset="100%" stop-color="#f59e0b" stop-opacity="0.0"/>
                            </linearGradient>
                        </defs>

                        <!-- Horizontal Grid Lines (Reference levels) -->
                        <line x1="60" y1="40" x2="720" y2="40" class="mh-chart-grid" />
                        <line x1="60" y1="80" x2="720" y2="80" class="mh-chart-grid" />
                        <line x1="60" y1="120" x2="720" y2="120" class="mh-chart-grid" />
                        <line x1="60" y1="160" x2="720" y2="160" class="mh-chart-grid" />
                        <line x1="60" y1="200" x2="720" y2="200" class="mh-chart-baseline" />

                        <!-- Y-Axis Value Labels -->
                        <text x="50" y="44" class="mh-chart-axis-label" text-anchor="end"><fmt:formatNumber value="${dashboard.maxViews}" /></text>
                        <text x="50" y="124" class="mh-chart-axis-label" text-anchor="end"><fmt:formatNumber value="${dashboard.maxViews / 2}" /></text>
                        <text x="50" y="204" class="mh-chart-axis-label" text-anchor="end">0</text>

                        <!-- Dynamic Area Fill Path -->
                        <path id="studio-chart-area" class="mh-chart-area" d="" fill="url(#studioChartGrad)" />

                        <!-- Dynamic Line Stroke Path -->
                        <path id="studio-chart-line" class="mh-chart-line" d="" fill="none" stroke="#f59e0b" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round" />

                        <!-- Hover Vertical Cursor Line -->
                        <line id="chart-hover-line" class="mh-chart-hover-line" x1="0" y1="35" x2="0" y2="205" style="display: none;" />

                        <!-- Data Points plotted from Top Movies -->
                        <c:forEach var="m" items="${dashboard.topMovies}" varStatus="loop">
                            <c:set var="stepX" value="${totalTop > 1 ? (600 / (totalTop - 1)) : 300}" />
                            <c:set var="ptX" value="${totalTop > 1 ? (90 + loop.index * stepX) : 390}" />
                            <c:set var="calcY" value="${200 - ((m.viewCount * 150) / maxV)}" />
                            
                            <!-- Interactive SVG circle point -->
                            <circle class="mh-chart-point" 
                                    cx="${ptX}" 
                                    cy="${calcY}" 
                                    r="6" 
                                    data-rank="${loop.count}" 
                                    data-title="<c:out value='${m.title}' escapeXml='true' />" 
                                    data-views="${m.viewCount}" 
                                    data-year="${m.releaseYear}">
                                <title>#<c:out value="${loop.count}" /> - <c:out value="${m.title}" />: <fmt:formatNumber value="${m.viewCount}" /> lượt xem</title>
                            </circle>

                            <!-- X-Axis Label for each movie -->
                            <text x="${ptX}" y="230" class="mh-chart-x-label" text-anchor="middle">
                                #<c:out value="${loop.count}" />: <c:out value="${fn:substring(m.title, 0, 14)}" /><c:if test="${fn:length(m.title) > 14}">…</c:if>
                            </text>
                        </c:forEach>
                    </svg>

                    <!-- Floating YouTube Studio Interactive Tooltip Card -->
                    <div class="mh-chart-tooltip" id="chart-tooltip" aria-hidden="true" style="display: none;"></div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="mh-chart-empty">
                    <p>Chưa có dữ liệu lượt xem phim để vẽ biểu đồ.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <!-- Two-Column Executive Analytics Drilldown -->
    <div class="mh-studio-grid-2col">
        <!-- Section 1: Top 5 Movies (YouTube Studio Content Performance) -->
        <section class="mh-studio-panel">
            <div class="mh-panel-header-row">
                <div>
                    <h2 class="mh-panel-heading">Top 5 phim xem nhiều nhất</h2>
                    <p class="mh-panel-subheading">Xếp hạng theo tổng lượt xem toàn thời gian (mọi trạng thái)</p>
                </div>
                <a href="<c:out value='${adminMoviesUrl}' />" class="mh-panel-viewall">Xem tất cả phim →</a>
            </div>

            <c:choose>
                <c:when test="${not empty dashboard.topMovies}">
                    <div class="mh-top-movies-list">
                        <c:forEach var="m" items="${dashboard.topMovies}" varStatus="loop">
                            <c:url var="editMovieUrl" value="/admin/movies/edit"><c:param name="id" value="${m.id}" /></c:url>
                            <article class="mh-top-movie-item">
                                <div class="mh-rank-badge ${loop.count == 1 ? 'rank-1' : (loop.count == 2 ? 'rank-2' : (loop.count == 3 ? 'rank-3' : ''))}">
                                    #<c:out value="${loop.count}" />
                                </div>
                                <div class="mh-movie-info-wrap">
                                    <div class="mh-movie-title-line">
                                        <a href="<c:out value='${editMovieUrl}' />" class="mh-movie-name">
                                            <c:out value="${m.title}" escapeXml="true" />
                                        </a>
                                        <c:choose>
                                            <c:when test="${m.status == 'PUBLISHED'}">
                                                <span class="mh-status-badge mh-status-published">Công khai</span>
                                            </c:when>
                                            <c:when test="${m.status == 'HIDDEN'}">
                                                <span class="mh-status-badge mh-status-hidden">Đã ẩn</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="mh-status-badge mh-status-draft">Bản nháp</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="mh-movie-meta-line">
                                        <span>Năm phát hành: <strong><c:out value="${m.releaseYear}" /></strong></span>
                                        <span class="mh-dot-sep">•</span>
                                        <span>Lượt xem: <strong style="color: #f59e0b;"><fmt:formatNumber value="${m.viewCount}" /></strong></span>
                                    </div>
                                    <!-- Mini Performance Bar -->
                                    <c:set var="maxV" value="${dashboard.maxViews > 0 ? dashboard.maxViews : 1}" />
                                    <div class="mh-mini-meter">
                                        <div class="mh-mini-meter-fill" style="width: ${m.viewCount * 100 / maxV}%;"></div>
                                    </div>
                                </div>
                                <div class="mh-movie-action">
                                    <a href="<c:out value='${editMovieUrl}' />" class="mh-quick-edit-btn" title="Chỉnh sửa phim">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16">
                                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                        </svg>
                                    </a>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <p class="mh-empty-text">Chưa có dữ liệu phim trên hệ thống.</p>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- Section 2: Category Distribution (P1 FR-26) -->
        <section class="mh-studio-panel">
            <div class="mh-panel-header-row">
                <div>
                    <h2 class="mh-panel-heading">Phân bố số phim theo thể loại</h2>
                    <p class="mh-panel-subheading">Tỷ lệ số phim công khai theo từng thể loại chưa bị xóa</p>
                </div>
                <a href="<c:out value='${adminCategoriesUrl}' />" class="mh-panel-viewall">Quản lý thể loại →</a>
            </div>

            <c:choose>
                <c:when test="${not empty dashboard.categoryStats}">
                    <div class="mh-category-meters-list">
                        <c:set var="pubTotal" value="${dashboard.publishedMovies > 0 ? dashboard.publishedMovies : 1}" />
                        <c:forEach var="cat" items="${dashboard.categoryStats}">
                            <div class="mh-category-meter-item">
                                <div class="mh-cat-label-row">
                                    <span class="mh-cat-name"><c:out value="${cat.name}" escapeXml="true" /></span>
                                    <span class="mh-cat-count">
                                        <strong><fmt:formatNumber value="${cat.movieCount}" /></strong> phim
                                    </span>
                                </div>
                                <div class="mh-cat-meter-track">
                                    <div class="mh-cat-meter-fill" style="width: ${cat.movieCount * 100 / pubTotal}%;"></div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <div class="mh-category-disclaimer">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14" style="flex: none; margin-top: 1px;">
                            <circle cx="12" cy="12" r="10"></circle>
                            <line x1="12" y1="16" x2="12" y2="12"></line>
                            <line x1="12" y1="8" x2="12.01" y2="8"></line>
                        </svg>
                        <span>
                            * Lưu ý: Một phim có thể thuộc nhiều thể loại, do đó tổng số lượng theo từng thể loại có thể lớn hơn tổng số phim công khai thực tế.
                        </span>
                    </div>
                </c:when>
                <c:otherwise>
                    <p class="mh-empty-text">Chưa có thể loại phim nào.</p>
                </c:otherwise>
            </c:choose>
        </section>
    </div>

    <!-- Quick Management Hub Cards -->
    <div class="mh-studio-actions-title">CÔNG CỤ QUẢN TRỊ NHANH</div>
    <nav class="mh-studio-quick-hub" aria-label="Lối tắt công việc quản trị">
        <a href="<c:out value='${adminMoviesUrl}' />" class="mh-hub-card">
            <div class="mh-hub-icon-box" style="background: rgba(245, 158, 11, 0.12); color: #f59e0b;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="22" height="22">
                    <rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18"></rect>
                    <line x1="7" y1="2" x2="7" y2="22"></line>
                    <line x1="17" y1="2" x2="17" y2="22"></line>
                    <line x1="2" y1="12" x2="22" y2="12"></line>
                </svg>
            </div>
            <div>
                <h3>Kho phim</h3>
                <p>Thêm phim mới, chỉnh sửa thông tin, tập phim và xuất bản trực tuyến.</p>
            </div>
        </a>

        <a href="<c:out value='${adminModerationUrl}' />" class="mh-hub-card">
            <div class="mh-hub-icon-box" style="background: rgba(239, 68, 68, 0.12); color: #ef4444;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="22" height="22">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                    <polyline points="9 11 12 14 22 4"></polyline>
                </svg>
            </div>
            <div>
                <h3>Duyệt nội dung</h3>
                <p>Kiểm duyệt đánh giá người dùng, câu hỏi cộng đồng và phản hồi.</p>
            </div>
        </a>

        <a href="<c:out value='${adminCategoriesUrl}' />" class="mh-hub-card">
            <div class="mh-hub-icon-box" style="background: rgba(99, 102, 241, 0.12); color: #6366f1;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="22" height="22">
                    <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path>
                    <line x1="7" y1="7" x2="7.01" y2="7"></line>
                </svg>
            </div>
            <div>
                <h3>Thể loại phim</h3>
                <p>Phân loại danh mục điện ảnh, cập nhật slug và tổ chức danh mục.</p>
            </div>
        </a>

        <a href="<c:out value='${adminUsersUrl}' />" class="mh-hub-card">
            <div class="mh-hub-icon-box" style="background: rgba(16, 185, 129, 0.12); color: #10b981;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="22" height="22">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                    <circle cx="9" cy="7" r="4"></circle>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                </svg>
            </div>
            <div>
                <h3>Người dùng</h3>
                <p>Quản lý tài khoản thành viên, quyền hạn và trạng thái kích hoạt.</p>
            </div>
        </a>
    </nav>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>
