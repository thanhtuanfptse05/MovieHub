<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập | MovieHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <header class="mh-header">
        <a href="${pageContext.request.contextPath}/" class="mh-logo">
            Movie<span>Hub</span>
        </a>
        <nav class="mh-nav">
            <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
        </nav>
    </header>

    <main class="mh-auth-container">
        <div class="mh-auth-card">
            <div class="mh-auth-header">
                <h1 class="mh-auth-title">Đăng nhập</h1>
                <p class="mh-auth-subtitle">Chào mừng bạn trở lại với MovieHub</p>
            </div>

            <c:if test="${not empty flashSuccess}">
                <div class="mh-alert mh-alert-success" role="alert">
                    <c:out value="${flashSuccess}" escapeXml="true" />
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="mh-alert mh-alert-error" role="alert">
                    <c:out value="${errorMessage}" escapeXml="true" />
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="POST">
                <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                <c:if test="${not empty returnTo}">
                    <input type="hidden" name="returnTo" value="<c:out value="${returnTo}" escapeXml="true" />">
                </c:if>

                <div class="mh-form-group">
                    <label for="email" class="mh-label">Địa chỉ email</label>
                    <input type="email" id="email" name="email" class="mh-input" 
                           value="<c:out value="${email}" escapeXml="true" />" 
                           placeholder="name@example.com" required autocomplete="email">
                </div>

                <div class="mh-form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                        <label for="password" class="mh-label" style="margin-bottom: 0;">Mật khẩu</label>
                        <a href="${pageContext.request.contextPath}/forgot-password" style="font-size: 0.85rem;">Quên mật khẩu?</a>
                    </div>
                    <input type="password" id="password" name="password" class="mh-input" 
                           placeholder="Nhập mật khẩu" required autocomplete="current-password">
                </div>

                <button type="submit" class="mh-btn mh-btn-primary mh-btn-block">Đăng Nhập</button>
            </form>

            <div class="mh-auth-footer">
                Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a>
            </div>
        </div>
    </main>
</body>
</html>
