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
    <meta name="description" content="Bảng điều khiển quản trị và thống kê hệ thống MovieHub">
    <title>Tổng quan quản trị | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <div class="mh-admin-title-row">
        <div>
            <h1>Bảng điều khiển quản trị</h1>
            <p class="mh-admin-subtitle">Thống kê số liệu vận hành và điều hướng quản trị hệ thống</p>
        </div>
    </div>
    <%@ include file="notices.jspf" %>

    <!-- Quick Navigation Hub (Feature 007 Admin CRUD) -->
    <nav class="mh-admin-hub" aria-label="Công việc quản trị" style="margin-bottom: 32px;">
        <a href="<c:out value='${adminMoviesUrl}' />"><h2>Phim</h2><p>Thêm phim, chỉnh sửa nội dung và xuất bản.</p></a>
        <a href="<c:out value='${adminModerationUrl}' />"><h2>Duyệt nội dung</h2><p>Xem đánh giá, câu hỏi và câu trả lời.</p></a>
        <a href="<c:out value='${adminCategoriesUrl}' />"><h2>Thể loại</h2><p>Thêm và chỉnh sửa thể loại phim.</p></a>
        <a href="<c:out value='${adminUsersUrl}' />"><h2>Người dùng</h2><p>Quản lý quyền và trạng thái tài khoản.</p></a>
    </nav>

    <!-- KPI Statistic Cards Grid (Feature 008 Analytics: KPI-01 -> KPI-08) -->
    <section class="mh-analytics-grid" aria-label="Các chỉ số chính" style="margin-bottom: 32px;">
        <!-- KPI-01 & KPI-02: Phim -->
        <article class="mh-kpi-card">
            <div>
                <h2 class="mh-kpi-label">Tổng số phim</h2>
                <div class="mh-kpi-value"><fmt:formatNumber value="${dashboard.totalMovies}" /></div>
            </div>
            <div class="mh-kpi-subtext">
                Đang công khai: <strong><fmt:formatNumber value="${dashboard.publishedMovies}" /></strong>
            </div>
        </article>

        <!-- KPI-03: Người dùng role USER -->
        <article class="mh-kpi-card">
            <div>
                <h2 class="mh-kpi-label">Người dùng hệ thống</h2>
                <div class="mh-kpi-value"><fmt:formatNumber value="${dashboard.totalUsers}" /></div>
            </div>
            <div class="mh-kpi-subtext">
                Tài khoản thành viên (Role USER)
            </div>
        </article>

        <!-- KPI-05 & KPI-06: Lượt xem -->
        <article class="mh-kpi-card">
            <div>
                <h2 class="mh-kpi-label">Tổng lượt xem phim</h2>
                <div class="mh-kpi-value"><fmt:formatNumber value="${dashboard.totalViews}" /></div>
            </div>
            <div class="mh-kpi-subtext">
                Cao nhất: <strong><c:out value="${dashboard.maxViewsText}" /></strong> • Thấp nhất: <strong><c:out value="${dashboard.minViewsText}" /></strong>
            </div>
        </article>

        <!-- KPI-04 & KPI-07: Đánh giá -->
        <article class="mh-kpi-card">
            <div>
                <h2 class="mh-kpi-label">Điểm đánh giá TB</h2>
                <div class="mh-kpi-value" style="color: var(--mh-rating-text);">
                    <c:choose>
                        <c:when test="${not empty dashboard.averageRating}">
                            ★ <c:out value="${dashboard.averageRatingText}" />
                        </c:when>
                        <c:otherwise>
                            N/A
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="mh-kpi-subtext">
                Trên <fmt:formatNumber value="${dashboard.totalReviews}" /> đánh giá (tính cả phim ẩn)
            </div>
        </article>

        <!-- KPI-08: Nội dung chờ duyệt -->
        <article class="mh-kpi-card">
            <div>
                <h2 class="mh-kpi-label">Nội dung chờ duyệt</h2>
                <div class="mh-kpi-value" style="color: var(--mh-accent);">
                    <fmt:formatNumber value="${dashboard.totalPending}" />
                </div>
            </div>
            <div>
                <div class="mh-kpi-chips">
                    <span class="mh-kpi-chip">Đánh giá: <c:out value="${dashboard.pendingReviews}" /></span>
                    <span class="mh-kpi-chip">Câu hỏi: <c:out value="${dashboard.pendingQuestions}" /></span>
                    <span class="mh-kpi-chip">Trả lời: <c:out value="${dashboard.pendingAnswers}" /></span>
                </div>
            </div>
        </article>
    </section>

    <!-- Detailed Sections: Top 5 Movies & Category Distribution -->
    <div class="mh-dashboard-sections">
        <!-- KPI-09: Top 5 Movies by Views -->
        <section class="mh-panel">
            <h2 class="mh-panel-title">Top 5 phim xem nhiều nhất</h2>
            <p class="mh-panel-desc">Xếp hạng theo tổng lượt xem toàn thời gian (mọi trạng thái)</p>

            <c:choose>
                <c:when test="${not empty dashboard.topMovies}">
                    <div style="overflow-x: auto;">
                        <table class="mh-table">
                            <thead>
                                <tr>
                                    <th style="width: 50px;">#</th>
                                    <th>Tên phim</th>
                                    <th>Năm</th>
                                    <th>Trạng thái</th>
                                    <th style="text-align: right;">Lượt xem</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="m" items="${dashboard.topMovies}" varStatus="loop">
                                    <tr>
                                        <td><strong><c:out value="${loop.count}" /></strong></td>
                                        <td>
                                            <strong><c:out value="${m.title}" escapeXml="true" /></strong>
                                        </td>
                                        <td><c:out value="${m.releaseYear}" /></td>
                                        <td>
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
                                        </td>
                                        <td style="text-align: right; font-weight: 600;">
                                            <fmt:formatNumber value="${m.viewCount}" />
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <p style="color: #71717a; padding: 24px 0; text-align: center;">Chưa có dữ liệu phim.</p>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- P1 FR-26: Phân bố số phim theo thể loại -->
        <section class="mh-panel">
            <h2 class="mh-panel-title">Phân bố theo thể loại</h2>
            <p class="mh-panel-desc">Số phim đang công khai theo từng thể loại chưa bị xóa</p>

            <c:choose>
                <c:when test="${not empty dashboard.categoryStats}">
                    <div style="overflow-x: auto; margin-bottom: 16px;">
                        <table class="mh-table">
                            <thead>
                                <tr>
                                    <th>Thể loại</th>
                                    <th style="text-align: right;">Số phim</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="cat" items="${dashboard.categoryStats}">
                                    <tr>
                                        <td>
                                            <c:out value="${cat.name}" escapeXml="true" />
                                        </td>
                                        <td style="text-align: right; font-weight: 600;">
                                            <fmt:formatNumber value="${cat.movieCount}" />
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <p style="font-size: 0.8rem; color: #71717a; line-height: 1.4;">
                        * Lưu ý: Một phim có thể thuộc nhiều thể loại, do đó tổng số lượng theo từng thể loại có thể lớn hơn tổng số phim công khai thực tế.
                    </p>
                </c:when>
                <c:otherwise>
                    <p style="color: #71717a; padding: 24px 0; text-align: center;">Chưa có thể loại nào.</p>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>
