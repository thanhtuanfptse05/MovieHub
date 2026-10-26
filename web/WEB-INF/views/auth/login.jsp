<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập | MovieHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <mh:header />

    <main class="mh-auth-container">
        <div class="mh-auth-glow-1" aria-hidden="true"></div>
        <div class="mh-auth-glow-2" aria-hidden="true"></div>

        <div class="mh-auth-layout">
            <div class="mh-auth-showcase">
                <div class="mh-auth-pill">
                    <svg viewBox="0 0 24 24" fill="currentColor" width="13" height="13" aria-hidden="true"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                    <span>Cổng Thành Viên MovieHub</span>
                </div>
                <h2 class="mh-auth-showcase-title">Điện Ảnh Đỉnh Cao <br><span class="mh-gradient-text">Chuẩn Rạp Chiếu</span></h2>
                <p class="mh-auth-showcase-desc">
                    Đăng nhập để tiếp tục khám phá kho phim bản quyền sắc nét, lưu trữ danh mục yêu thích và tham gia thảo luận cùng cộng đồng yêu điện ảnh.
                </p>
                <ul class="mh-auth-features">
                    <li class="mh-auth-feature-item">
                        <svg class="mh-auth-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>Chất lượng hình ảnh 1080p và phát trực tiếp mượt mà</span>
                    </li>
                    <li class="mh-auth-feature-item">
                        <svg class="mh-auth-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                        <span>Đồng bộ danh sách yêu thích và tiến trình xem</span>
                    </li>
                    <li class="mh-auth-feature-item">
                        <svg class="mh-auth-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                        <span>Viết đánh giá minh bạch và đặt câu hỏi thảo luận</span>
                    </li>
                </ul>
            </div>

            <div class="mh-auth-card">
                <div class="mh-auth-header">
                    <h1 class="mh-auth-title">Đăng nhập</h1>
                    <p class="mh-auth-subtitle">Chào mừng bạn trở lại với rạp chiếu MovieHub</p>
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
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            <input type="email" id="email" name="email" class="mh-input mh-input-with-icon" 
                                   value="<c:out value="${email}" escapeXml="true" />" 
                                   placeholder="name@example.com" required autocomplete="email">
                        </div>
                    </div>

                    <div class="mh-form-group">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <label for="password" class="mh-label" style="margin-bottom: 0;">Mật khẩu</label>
                            <a href="${pageContext.request.contextPath}/forgot-password" style="font-size: 0.85rem; color: var(--mh-accent-soft);">Quên mật khẩu?</a>
                        </div>
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            <input type="password" id="password" name="password" class="mh-input mh-input-with-icon" 
                                   placeholder="Nhập mật khẩu của bạn" required autocomplete="current-password">
                        </div>
                    </div>

                    <button type="submit" class="mh-btn mh-btn-primary mh-btn-block" style="border-radius: 9999px; display: inline-flex; align-items: center; justify-content: center; gap: 8px;">
                        <span>Đăng Nhập</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16" aria-hidden="true"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                    </button>
                </form>

                <div class="mh-auth-footer">
                    Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register" style="color: #fff; font-weight: 600;">Đăng ký ngay</a>
                </div>
            </div>
        </div>
    </main>

    <mh:footer />
</body>
</html>
