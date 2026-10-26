<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu mới | MovieHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <mh:header />

    <main class="mh-auth-container">
        <div class="mh-auth-card">
            <div class="mh-auth-header">
                <h1 class="mh-auth-title">Đặt mật khẩu mới</h1>
                <p class="mh-auth-subtitle">Thiết lập mật khẩu bảo mật mới cho tài khoản của bạn</p>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="mh-alert mh-alert-error" role="alert">
                    <c:out value="${errorMessage}" escapeXml="true" />
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/reset-password" method="POST">
                <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                <input type="hidden" name="flowVersion" value="<c:out value="${flowVersion}" escapeXml="true" />">

                <div class="mh-form-group">
                    <label class="mh-label">Tài khoản</label>
                    <input type="text" class="mh-input" value="<c:out value="${targetEmail}" escapeXml="true" />" readonly>
                </div>

                <div class="mh-form-group">
                    <label for="password" class="mh-label">Mật khẩu mới</label>
                    <input type="password" id="password" name="password" class="mh-input" 
                           placeholder="Tối thiểu 8 ký tự" required minlength="8" autocomplete="new-password">
                </div>

                <div class="mh-form-group">
                    <label for="confirmPassword" class="mh-label">Xác nhận mật khẩu mới</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="mh-input" 
                           placeholder="Nhập lại mật khẩu mới" required autocomplete="new-password">
                </div>

                <button type="submit" class="mh-btn mh-btn-primary mh-btn-block">Đặt Lại Mật Khẩu</button>
            </form>

            <div class="mh-auth-footer">
                <a href="${pageContext.request.contextPath}/forgot-password">Nhập lại địa chỉ email khác</a>
            </div>
        </div>
    </main>

    <mh:footer />
</body>
</html>
