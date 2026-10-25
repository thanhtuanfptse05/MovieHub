<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 - Không có quyền truy cập | MovieHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <header class="mh-header">
        <a href="${pageContext.request.contextPath}/" class="mh-logo">
            Movie<span>Hub</span>
        </a>
    </header>

    <main class="mh-error-container">
        <div class="mh-error-code">403</div>
        <h1 class="mh-error-title">Truy cập bị từ chối</h1>
        <p class="mh-error-desc">
            <c:choose>
                <c:when test="${not empty errorMessage}">
                    <c:out value="${errorMessage}" escapeXml="true" />
                </c:when>
                <c:otherwise>
                    Bạn không có quyền truy cập vào tài nguyên này hoặc phiên làm việc đã hết hạn.
                </c:otherwise>
            </c:choose>
        </p>
        <div>
            <a href="${pageContext.request.contextPath}/" class="mh-btn mh-btn-primary">Về Trang Chủ</a>
        </div>
    </main>
</body>
</html>
