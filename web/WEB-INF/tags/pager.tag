<%@ tag language="java" pageEncoding="UTF-8" description="Pagination keeping q/category/year/sort" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="query" required="true" type="com.moviehub.dto.CatalogQuery" %>
<%@ attribute name="result" required="true" type="com.moviehub.dto.PageResult" %>
<c:if test="${result.totalPages > 1}">
    <nav class="mh-pager" aria-label="Phân trang">
        <c:if test="${result.hasPrevious}">
            <c:url var="prevUrl" value="/movies">
                <c:if test="${not empty query.q}"><c:param name="q" value="${query.q}" /></c:if>
                <c:if test="${query.categoryId != null}"><c:param name="category" value="${query.categoryId}" /></c:if>
                <c:if test="${query.year != null}"><c:param name="year" value="${query.year}" /></c:if>
                <c:param name="sort" value="${query.sort}" />
                <c:param name="page" value="${result.page - 1}" />
            </c:url>
            <a href="${prevUrl}" class="mh-page-link" rel="prev">‹ Trước</a>
        </c:if>

        <c:forEach var="p" begin="1" end="${result.totalPages}">
            <c:if test="${p == 1 or p == result.totalPages or (p >= result.page - 2 and p <= result.page + 2)}">
                <c:url var="pageUrl" value="/movies">
                    <c:if test="${not empty query.q}"><c:param name="q" value="${query.q}" /></c:if>
                    <c:if test="${query.categoryId != null}"><c:param name="category" value="${query.categoryId}" /></c:if>
                    <c:if test="${query.year != null}"><c:param name="year" value="${query.year}" /></c:if>
                    <c:param name="sort" value="${query.sort}" />
                    <c:param name="page" value="${p}" />
                </c:url>
                <a href="${pageUrl}" class="mh-page-link${p == result.page ? ' is-current' : ''}"
                   <c:if test="${p == result.page}">aria-current="page"</c:if>>${p}</a>
            </c:if>
        </c:forEach>

        <c:if test="${result.hasNext}">
            <c:url var="nextUrl" value="/movies">
                <c:if test="${not empty query.q}"><c:param name="q" value="${query.q}" /></c:if>
                <c:if test="${query.categoryId != null}"><c:param name="category" value="${query.categoryId}" /></c:if>
                <c:if test="${query.year != null}"><c:param name="year" value="${query.year}" /></c:if>
                <c:param name="sort" value="${query.sort}" />
                <c:param name="page" value="${result.page + 1}" />
            </c:url>
            <a href="${nextUrl}" class="mh-page-link" rel="next">Sau ›</a>
        </c:if>
    </nav>
</c:if>
