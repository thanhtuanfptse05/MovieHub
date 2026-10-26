<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khôi phục mật khẩu | MovieHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <mh:header />

    <main class="mh-auth-container">
        <div class="mh-auth-card">
            <div class="mh-auth-header">
                <h1 class="mh-auth-title">Khôi phục mật khẩu</h1>
                <p class="mh-auth-subtitle">Nhập địa chỉ email đã đăng ký tài khoản để tiếp tục đặt lại mật khẩu</p>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="mh-alert mh-alert-error" role="alert">
                    <c:out value="${errorMessage}" escapeXml="true" />
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
                <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">

                <div class="mh-form-group">
                    <label for="email" class="mh-label">Địa chỉ email đã đăng ký</label>
                    <input type="email" id="email" name="email" class="mh-input" 
                           value="<c:out value="${email}" escapeXml="true" />" 
                           placeholder="name@example.com" required autocomplete="email">
                </div>

                <button type="submit" class="mh-btn mh-btn-primary mh-btn-block">Tiếp Tục</button>
            </form>

            <div class="mh-auth-footer">
                Nhớ mật khẩu? <a href="${pageContext.request.contextPath}/login">Quay lại đăng nhập</a>
            </div>
        </div>
    </main>

    <mh:footer />
</body>
</html>
