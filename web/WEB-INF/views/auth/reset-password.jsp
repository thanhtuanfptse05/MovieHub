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
        <div class="mh-auth-glow-1" aria-hidden="true"></div>
        <div class="mh-auth-glow-2" aria-hidden="true"></div>

        <div class="mh-auth-layout is-single">
            <div class="mh-auth-card">
                <div class="mh-auth-header">
                    <h1 class="mh-auth-title">Đặt mật khẩu mới</h1>
                    <p class="mh-auth-subtitle">Thiết lập mật khẩu bảo mật mới cho tài khoản MovieHub của bạn</p>
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
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            <input type="text" class="mh-input mh-input-with-icon" value="<c:out value="${targetEmail}" escapeXml="true" />" readonly>
                        </div>
                    </div>

                    <div class="mh-form-group">
                        <label for="password" class="mh-label">Mật khẩu mới</label>
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            <input type="password" id="password" name="password" class="mh-input mh-input-with-icon" 
                                   placeholder="Tối thiểu 8 ký tự" required minlength="8" autocomplete="new-password">
                        </div>
                    </div>

                    <div class="mh-form-group">
                        <label for="confirmPassword" class="mh-label">Xác nhận mật khẩu mới</label>
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="mh-input mh-input-with-icon" 
                                   placeholder="Nhập lại mật khẩu mới" required autocomplete="new-password">
                        </div>
                    </div>

                    <button type="submit" class="mh-btn mh-btn-primary mh-btn-block" style="border-radius: 9999px; display: inline-flex; align-items: center; justify-content: center; gap: 8px;">
                        <span>Đặt Lại Mật Khẩu</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                    </button>
                </form>

                <div class="mh-auth-footer">
                    <a href="${pageContext.request.contextPath}/forgot-password" style="color: var(--mh-accent-soft);">Nhập lại địa chỉ email khác</a>
                </div>
            </div>
        </div>
    </main>

    <mh:footer />
</body>
</html>
