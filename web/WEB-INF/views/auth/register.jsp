<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký tài khoản | MovieHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <header class="mh-header">
        <a href="${pageContext.request.contextPath}/" class="mh-logo">
            Movie<span>Hub</span>
        </a>
        <nav class="mh-nav">
            <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
        </nav>
    </header>

    <main class="mh-auth-container">
        <div class="mh-auth-card">
            <div class="mh-auth-header">
                <h1 class="mh-auth-title">Tạo tài khoản</h1>
                <p class="mh-auth-subtitle">Trở thành thành viên của cộng đồng điện ảnh MovieHub</p>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="mh-alert mh-alert-error" role="alert">
                    <c:out value="${errorMessage}" escapeXml="true" />
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register" method="POST">
                <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">

                <div class="mh-form-group">
                    <label for="fullName" class="mh-label">Họ và tên</label>
                    <input type="text" id="fullName" name="fullName" class="mh-input" 
                           value="<c:out value="${fullName}" escapeXml="true" />" 
                           placeholder="Nguyễn Văn A" required maxlength="100" autocomplete="name">
                </div>

                <div class="mh-form-group">
                    <label for="email" class="mh-label">Địa chỉ email</label>
                    <input type="email" id="email" name="email" class="mh-input" 
                           value="<c:out value="${email}" escapeXml="true" />" 
                           placeholder="name@example.com" required maxlength="255" autocomplete="email">
                </div>

                <div class="mh-form-group">
                    <label for="password" class="mh-label">Mật khẩu</label>
                    <input type="password" id="password" name="password" class="mh-input" 
                           placeholder="Tối thiểu 8 ký tự" required minlength="8" autocomplete="new-password">
                </div>

                <div class="mh-form-group">
                    <label for="confirmPassword" class="mh-label">Xác nhận mật khẩu</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="mh-input" 
                           placeholder="Nhập lại mật khẩu" required autocomplete="new-password">
                </div>

                <button type="submit" class="mh-btn mh-btn-primary mh-btn-block">Đăng Ký Tài Khoản</button>
            </form>

            <div class="mh-auth-footer">
                Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập ngay</a>
            </div>
        </div>
    </main>
</body>
</html>
