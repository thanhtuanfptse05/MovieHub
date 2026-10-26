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
                <c:if test="${sessionScope.userRole == 'ADMIN'}">
                    <a href="${ctx}/admin/dashboard" class="mh-btn mh-btn-secondary mh-btn-sm mh-header-admin-btn" title="Bảng điều khiển quản trị" style="color: #ffd795; border-color: rgba(251, 180, 0, 0.4);">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width: 13px; height: 13px; vertical-align: -2px; margin-right: 4px; display: inline-block;"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>Quản trị
                    </a>
                </c:if>
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
