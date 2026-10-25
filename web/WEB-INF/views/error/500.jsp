<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - Lỗi máy chủ | MovieHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <header class="mh-header">
        <a href="${pageContext.request.contextPath}/" class="mh-logo">
            Movie<span>Hub</span>
        </a>
    </header>

    <main class="mh-error-container">
        <div class="mh-error-code">500</div>
        <h1 class="mh-error-title">Đã xảy ra sự cố kỹ thuật</h1>
        <p class="mh-error-desc">
            Hệ thống đang gặp lỗi tạm thời trong quá trình xử lý yêu cầu của bạn. Đội ngũ kỹ thuật đã được thông báo để khắc phục.
        </p>
        <c:if test="${not empty correlationId}">
            <div class="mh-correlation-id">
                Mã theo dõi: <c:out value="${correlationId}" escapeXml="true" />
            </div>
            <div style="margin-bottom: 24px;"></div>
        </c:if>
        <div>
            <a href="${pageContext.request.contextPath}/" class="mh-btn mh-btn-primary">Về Trang Chủ</a>
        </div>
    </main>
</body>
</html>
