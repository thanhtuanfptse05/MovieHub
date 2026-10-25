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
    <meta name="description" content="Thông tin phim <c:out value="${movie.title}" escapeXml="true" />">
    <title><c:out value="${movie.title}" escapeXml="true" /> | MovieHub</title>
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <script src="${ctx}/assets/js/catalog.js" defer></script>
</head>
<body>
    <mh:header active="movies" />

    <main class="mh-page">
        <nav class="mh-breadcrumb" aria-label="Breadcrumb">
            <a href="${ctx}/">Trang chủ</a><span>/</span>
            <a href="${ctx}/movies">Phim</a><span>/</span>
            <span aria-current="page"><c:out value="${movie.title}" escapeXml="true" /></span>
        </nav>

        <section class="mh-detail">
            <div class="mh-detail-media">
                <c:choose>
                    <c:when test="${movie.hasMedia}">
                        <video id="mh-player" class="mh-player" controls preload="metadata" playsinline
                               poster="<c:out value="${movie.posterUrl}" escapeXml="true" />"
                               src="<c:out value="${movie.primaryMediaUrl}" escapeXml="true" />"
                               data-fallback="<c:out value="${movie.fallbackMediaUrl}" escapeXml="true" />">
                            Trình duyệt của bạn không hỗ trợ phát video.
                        </video>
                        <div class="mh-player-bar">
                            <p id="mh-player-notice" class="mh-player-notice" role="status" hidden></p>
                            <button type="button" id="mh-switch-trailer" class="mh-btn mh-btn-secondary mh-btn-sm" hidden>
                                Chuyển sang trailer
                            </button>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="mh-player mh-player-empty" role="status">
                            <c:choose>
                                <c:when test="${not empty movie.posterUrl}">
                                    <img src="<c:out value="${movie.posterUrl}" escapeXml="true" />" alt=""
                                         referrerpolicy="no-referrer" data-fallback="${ctx}/assets/img/poster-placeholder.svg">
                                </c:when>
                                <c:otherwise>
                                    <img src="${ctx}/assets/img/poster-placeholder.svg" alt="">
                                </c:otherwise>
                            </c:choose>
                            <p>Phim này chưa có video để phát.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="mh-detail-info">
                <h1 class="mh-detail-title"><c:out value="${movie.title}" escapeXml="true" /></h1>

                <ul class="mh-facts">
                    <li><c:out value="${movie.releaseYear}" /></li>
                    <li><c:out value="${movie.durationMinutes}" /> phút</li>
                    <li><fmt:formatNumber value="${movie.viewCount}" /> lượt xem</li>
                </ul>

                <div class="mh-rating-box">
                    <c:choose>
                        <c:when test="${movie.rated}">
                            <span class="mh-rating-score">★ <c:out value="${movie.ratingText}" /></span>
                            <span class="mh-rating-count"><c:out value="${movie.reviewCount}" /> đánh giá</span>
                        </c:when>
                        <c:otherwise>
                            <span class="mh-rating-count">Chưa đánh giá</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="mh-detail-actions">
                    <c:choose>
                        <c:when test="${not empty sessionScope.userId}">
                            <c:choose>
                                <c:when test="${isFavorited}">
                                    <form action="${ctx}/favorites/remove" method="POST" class="mh-inline-form">
                                        <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                                        <input type="hidden" name="movieId" value="${movie.id}">
                                        <input type="hidden" name="returnTo" value="/movies/detail?id=${movie.id}">
                                        <button type="submit" class="mh-btn mh-btn-secondary mh-btn-favorite is-active" title="Bỏ khỏi danh sách yêu thích">
                                            ♥ Đã yêu thích
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <form action="${ctx}/favorites/add" method="POST" class="mh-inline-form">
                                        <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                                        <input type="hidden" name="movieId" value="${movie.id}">
                                        <button type="submit" class="mh-btn mh-btn-primary mh-btn-favorite" title="Thêm vào danh sách yêu thích">
                                            ♡ Yêu thích
                                        </button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <c:url var="favLoginUrl" value="/login">
                                <c:param name="returnTo" value="/movies/detail?id=${movie.id}" />
                            </c:url>
                            <a href="${favLoginUrl}" class="mh-btn mh-btn-secondary mh-btn-favorite" title="Đăng nhập để thêm vào yêu thích">
                                ♡ Yêu thích
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>

                <c:if test="${not empty movie.categories}">
                    <ul class="mh-chips" aria-label="Thể loại">
                        <c:forEach var="cat" items="${movie.categories}">
                            <c:url var="catUrl" value="/movies">
                                <c:param name="category" value="${cat.id}" />
                            </c:url>
                            <li><a href="${catUrl}" class="mh-chip"><c:out value="${cat.name}" escapeXml="true" /></a></li>
                        </c:forEach>
                    </ul>
                </c:if>

                <h2 class="mh-subtitle">Nội dung</h2>
                <p class="mh-description"><c:out value="${movie.description}" escapeXml="true" /></p>
            </div>
        </section>

        <mh:movieRow sectionId="sec-similar" title="Phim tương tự" items="${similar}" />
    </main>

    <footer class="mh-footer">MovieHub</footer>
</body>
</html>
