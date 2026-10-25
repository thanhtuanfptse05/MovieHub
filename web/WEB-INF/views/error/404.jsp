<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Không tìm thấy trang | MovieHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <header class="mh-header">
        <a href="${pageContext.request.contextPath}/" class="mh-logo">
            Movie<span>Hub</span>
        </a>
    </header>

    <main class="mh-error-container">
        <div class="mh-error-code">404</div>
        <h1 class="mh-error-title">Không tìm thấy trang</h1>
        <p class="mh-error-desc">
            Trang bạn đang tìm kiếm không tồn tại hoặc đã được chuyển đến địa chỉ khác.
        </p>
        <div>
            <a href="${pageContext.request.contextPath}/" class="mh-btn mh-btn-primary">Về Trang Chủ</a>
        </div>
    </main>
</body>
</html>
