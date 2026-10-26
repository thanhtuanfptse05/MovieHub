<%@ tag language="java" pageEncoding="UTF-8" description="Movie card" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="card" required="true" type="com.moviehub.dto.MovieCard" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:url var="detailUrl" value="/movies/detail">
    <c:param name="id" value="${card.id}" />
</c:url>
<article class="mh-card">
    <a href="${detailUrl}" class="mh-card-link">
        <div class="mh-card-poster">
            <c:choose>
                <c:when test="${not empty card.posterUrl}">
                    <img src="<c:out value="${card.posterUrl}" escapeXml="true" />"
                         alt="Poster phim <c:out value="${card.title}" escapeXml="true" />"
                         loading="lazy" referrerpolicy="no-referrer"
                         data-fallback="${ctx}/assets/img/poster-placeholder.svg">
                </c:when>
                <c:otherwise>
                    <img src="${ctx}/assets/img/poster-placeholder.svg"
                         alt="Chưa có poster cho phim <c:out value="${card.title}" escapeXml="true" />" loading="lazy">
                </c:otherwise>
            </c:choose>
            <div class="mh-card-play-overlay" aria-hidden="true">
                <span class="mh-card-play-btn">
                    <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><polygon points="6 4 20 12 6 20 6 4"/></svg>
                </span>
            </div>
            <div class="mh-card-badge-top" aria-hidden="true">
                <span class="mh-card-quality-chip">1080p</span>
            </div>
            <span class="mh-card-rating${card.rated ? '' : ' is-empty'}">
                <c:choose>
                    <c:when test="${card.rated}">
                        <svg class="mh-card-star" viewBox="0 0 24 24" fill="currentColor" width="12" height="12" aria-hidden="true"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        <span><c:out value="${card.ratingText}" /></span>
                    </c:when>
                    <c:otherwise>Chưa đánh giá</c:otherwise>
                </c:choose>
            </span>
        </div>
        <div class="mh-card-body">
            <h3 class="mh-card-title"><c:out value="${card.title}" escapeXml="true" /></h3>
            <div class="mh-card-meta-row">
                <span class="mh-card-year"><c:out value="${card.releaseYear}" /></span>
                <span class="mh-card-cta-hint">Xem chi tiết &rarr;</span>
            </div>
        </div>
    </a>
</article>
