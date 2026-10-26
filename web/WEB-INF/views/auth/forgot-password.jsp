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
        <div class="mh-auth-glow-1" aria-hidden="true"></div>
        <div class="mh-auth-glow-2" aria-hidden="true"></div>

        <div class="mh-auth-layout is-single">
            <div class="mh-auth-card">
                <div class="mh-auth-header">
                    <h1 class="mh-auth-title">Khôi phục mật khẩu</h1>
                    <p class="mh-auth-subtitle">Nhập địa chỉ email tài khoản MovieHub của bạn để tiếp tục đặt lại mật khẩu an toàn</p>
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
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            <input type="email" id="email" name="email" class="mh-input mh-input-with-icon" 
                                   value="<c:out value="${email}" escapeXml="true" />" 
                                   placeholder="name@example.com" required autocomplete="email">
                        </div>
                    </div>

                    <button type="submit" class="mh-btn mh-btn-primary mh-btn-block" style="border-radius: 9999px; display: inline-flex; align-items: center; justify-content: center; gap: 8px;">
                        <span>Tiếp Tục</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16" aria-hidden="true"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                    </button>
                </form>

                <div class="mh-auth-footer">
                    Nhớ mật khẩu? <a href="${pageContext.request.contextPath}/login" style="color: #fff; font-weight: 600;">Quay lại đăng nhập</a>
                </div>
            </div>
        </div>
    </main>

    <mh:footer />
</body>
</html>
