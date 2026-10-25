<%@ tag language="java" pageEncoding="UTF-8" description="Titled grid of movie cards; renders nothing when empty" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<%@ attribute name="sectionId" required="true" type="java.lang.String" %>
<%@ attribute name="title" required="true" type="java.lang.String" %>
<%@ attribute name="items" required="true" type="java.util.List" %>
<%@ attribute name="moreHref" required="false" type="java.lang.String" %>
<c:if test="${not empty items}">
    <section class="mh-section" aria-labelledby="${sectionId}">
        <div class="mh-section-head">
            <h2 class="mh-section-title" id="${sectionId}"><c:out value="${title}" /></h2>
            <c:if test="${not empty moreHref}">
                <a href="${moreHref}" class="mh-section-more">Xem tất cả →</a>
            </c:if>
        </div>
        <div class="mh-grid">
            <c:forEach var="m" items="${items}">
                <mh:movieCard card="${m}" />
            </c:forEach>
        </div>
    </section>
</c:if>
