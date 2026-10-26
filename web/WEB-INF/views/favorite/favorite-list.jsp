<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Danh sách phim yêu thích cá nhân trên MovieHub">
    <title>Phim yêu thích | MovieHub</title>
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <script src="${ctx}/assets/js/catalog.js" charset="UTF-8" defer></script>
</head>
<body>
    <mh:header active="favorites" />

    <main class="mh-page">
        <nav class="mh-breadcrumb" aria-label="Breadcrumb">
            <a href="${ctx}/">Trang chủ</a><span>/</span>
            <span aria-current="page">Phim yêu thích</span>
        </nav>

        <section class="mh-section">
            <div class="mh-section-head">
                <div>
                    <h1 class="mh-section-title">Phim yêu thích</h1>
                    <c:if test="${hasItems}">
                        <p class="mh-result-count">Bạn đang lưu <c:out value="${totalCount}" /> bộ phim</p>
                    </c:if>
                </div>
            </div>

            <c:choose>
                <c:when test="${hasItems}">
                    <div class="mh-grid">
                        <c:forEach var="item" items="${items}">
                            <c:url var="detailUrl" value="/movies/detail">
                                <c:param name="id" value="${item.id}" />
                            </c:url>
                            <article class="mh-card">
                                <a href="${detailUrl}" class="mh-card-link">
                                    <div class="mh-card-poster">
                                        <c:choose>
                                            <c:when test="${not empty item.posterUrl}">
                                                <img src="<c:out value="${item.posterUrl}" escapeXml="true" />"
                                                     alt="Poster phim <c:out value="${item.title}" escapeXml="true" />"
                                                     loading="lazy" referrerpolicy="no-referrer"
                                                     data-fallback="${ctx}/assets/img/poster-placeholder.svg">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${ctx}/assets/img/poster-placeholder.svg"
                                                     alt="Chưa có poster cho phim <c:out value="${item.title}" escapeXml="true" />" loading="lazy">
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="mh-card-rating${item.rated ? '' : ' is-empty'}">
                                            <c:choose>
                                                <c:when test="${item.rated}">★ <c:out value="${item.ratingText}" /></c:when>
                                                <c:otherwise>Chưa đánh giá</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="mh-card-body">
                                        <h3 class="mh-card-title"><c:out value="${item.title}" escapeXml="true" /></h3>
                                        <p class="mh-card-meta"><c:out value="${item.releaseYear}" /></p>
                                    </div>
                                </a>
                                <div class="mh-card-actions">
                                    <form action="${ctx}/favorites/remove" method="POST" class="mh-inline-form">
                                        <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                                        <input type="hidden" name="movieId" value="${item.id}">
                                        <input type="hidden" name="page" value="${page}">
                                        <button type="submit" class="mh-btn mh-btn-secondary mh-btn-sm" title="Bỏ yêu thích" style="border-radius: 9999px; display: inline-flex; align-items: center; gap: 6px;">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="13" height="13" aria-hidden="true"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                            <span>Bỏ yêu thích</span>
                                        </button>
                                    </form>
                                </div>
                            </article>
                        </c:forEach>
                    </div>

                    <c:if test="${totalPages > 1}">
                        <nav class="mh-pager" aria-label="Phân trang">
                            <c:if test="${page > 1}">
                                <c:url var="prevUrl" value="/favorites">
                                    <c:param name="page" value="${page - 1}" />
                                </c:url>
                                <a href="${prevUrl}" class="mh-page-link" rel="prev">‹ Trước</a>
                            </c:if>

                            <c:forEach var="p" begin="1" end="${totalPages}">
                                <c:if test="${p == 1 or p == totalPages or (p >= page - 2 and p <= page + 2)}">
                                    <c:url var="pUrl" value="/favorites">
                                        <c:param name="page" value="${p}" />
                                    </c:url>
                                    <a href="${pUrl}" class="mh-page-link${p == page ? ' is-current' : ''}"
                                       <c:if test="${p == page}">aria-current="page"</c:if>>${p}</a>
                                </c:if>
                            </c:forEach>

                            <c:if test="${page < totalPages}">
                                <c:url var="nextUrl" value="/favorites">
                                    <c:param name="page" value="${page + 1}" />
                                </c:url>
                                <a href="${nextUrl}" class="mh-page-link" rel="next">Sau ›</a>
                            </c:if>
                        </nav>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="mh-empty">
                        <h2 class="mh-empty-title">Bạn chưa có phim yêu thích</h2>
                        <p class="mh-empty-desc">Hãy khám phá danh mục phim và bấm biểu tượng yêu thích để lưu lại những bộ phim bạn quan tâm.</p>
                        <div style="margin-top: 18px;">
                            <a href="${ctx}/movies" class="mh-btn mh-btn-primary">Khám phá phim</a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </main>

    <mh:footer />
</body>
</html>
