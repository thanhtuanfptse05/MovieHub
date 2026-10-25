<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="MovieHub - khám phá phim mới cập nhật, xem nhiều và được đánh giá cao.">
    <title>MovieHub - Khám phá phim</title>
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <script src="${ctx}/assets/js/catalog.js" charset="UTF-8" defer></script>
</head>
<body>
    <mh:header active="home" />

    <main class="mh-page">
        <c:if test="${not empty home.featured}">
            <c:url var="featuredUrl" value="/movies/detail">
                <c:param name="id" value="${home.featured.id}" />
            </c:url>
            <section class="mh-hero" aria-label="Phim nổi bật">
                <c:if test="${not empty home.featured.posterUrl}">
                    <img class="mh-hero-bg" src="<c:out value="${home.featured.posterUrl}" escapeXml="true" />"
                         alt="" referrerpolicy="no-referrer" data-fallback="${ctx}/assets/img/poster-placeholder.svg">
                </c:if>
                <div class="mh-hero-shade"></div>
                <div class="mh-hero-content">
                    <span class="mh-badge mh-badge-primary">Nổi bật</span>
                    <h1 class="mh-hero-title"><c:out value="${home.featured.title}" escapeXml="true" /></h1>
                    <p class="mh-hero-meta">
                        <c:out value="${home.featured.releaseYear}" />
                        <span class="mh-dot"></span>
                        <c:choose>
                            <c:when test="${home.featured.rated}">★ <c:out value="${home.featured.ratingText}" /></c:when>
                            <c:otherwise>Chưa đánh giá</c:otherwise>
                        </c:choose>
                    </p>
                    <a href="${featuredUrl}" class="mh-btn mh-btn-primary">Xem chi tiết</a>
                </div>
            </section>
        </c:if>

        <c:if test="${empty home.featured}">
            <h1 class="mh-page-title">Khám phá phim</h1>
        </c:if>

        <c:if test="${home.noMovies}">
            <div class="mh-empty">
                <p class="mh-empty-title">Chưa có phim</p>
                <p class="mh-empty-desc">Hiện chưa có phim nào được công bố. Vui lòng quay lại sau.</p>
            </div>
        </c:if>

        <mh:movieRow sectionId="sec-newest" title="Mới cập nhật" items="${home.newest}"
                     moreHref="${ctx}/movies?sort=newest" />
        <mh:movieRow sectionId="sec-views" title="Xem nhiều" items="${home.mostViewed}"
                     moreHref="${ctx}/movies?sort=views" />
        <mh:movieRow sectionId="sec-rating" title="Đánh giá cao" items="${home.topRated}"
                     moreHref="${ctx}/movies?sort=rating" />
    </main>

    <footer class="mh-footer">MovieHub</footer>
</body>
</html>
