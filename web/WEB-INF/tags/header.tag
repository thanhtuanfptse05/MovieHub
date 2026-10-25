<%@ tag language="java" pageEncoding="UTF-8" description="Site header" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="active" required="false" type="java.lang.String" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<header class="mh-header">
    <a href="${ctx}/" class="mh-logo">Movie<span>Hub</span></a>
    <nav class="mh-nav" aria-label="Điều hướng chính">
        <a href="${ctx}/" class="mh-nav-link${active == 'home' ? ' is-active' : ''}">Trang chủ</a>
        <a href="${ctx}/movies" class="mh-nav-link${active == 'movies' ? ' is-active' : ''}">Phim</a>
        <c:choose>
            <c:when test="${not empty sessionScope.userId}">
                <a href="${ctx}/favorites" class="mh-nav-link${active == 'favorites' ? ' is-active' : ''}">Yêu thích</a>
                <a href="${ctx}/profile" class="mh-nav-link${active == 'profile' ? ' is-active' : ''}">
                    <c:out value="${sessionScope.userName}" escapeXml="true" />
                </a>
                <form action="${ctx}/logout" method="POST" class="mh-inline-form">
                    <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                    <button type="submit" class="mh-btn mh-btn-secondary mh-btn-sm">Đăng xuất</button>
                </form>
            </c:when>
            <c:otherwise>
                <a href="${ctx}/login" class="mh-nav-link">Đăng nhập</a>
                <a href="${ctx}/register" class="mh-btn mh-btn-primary mh-btn-sm">Đăng ký</a>
            </c:otherwise>
        </c:choose>
    </nav>
</header>
