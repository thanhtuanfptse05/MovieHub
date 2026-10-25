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
            <span class="mh-card-rating${card.rated ? '' : ' is-empty'}">
                <c:choose>
                    <c:when test="${card.rated}">★ <c:out value="${card.ratingText}" /></c:when>
                    <c:otherwise>Chưa đánh giá</c:otherwise>
                </c:choose>
            </span>
        </div>
        <div class="mh-card-body">
            <h3 class="mh-card-title"><c:out value="${card.title}" escapeXml="true" /></h3>
            <p class="mh-card-meta"><c:out value="${card.releaseYear}" /></p>
        </div>
    </a>
</article>
