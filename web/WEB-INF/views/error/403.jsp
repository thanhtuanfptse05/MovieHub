<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="403 - Giới hạn quyền truy cập tài nguyên trên MovieHub">
    <title>403 - Giới hạn quyền truy cập | MovieHub</title>
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
</head>
<body>
    <mh:header />

    <main class="mh-error-page mh-error-page-403">
        <article class="mh-error-card">
            <div class="mh-error-visual mh-error-visual-403" aria-hidden="true">
                <!-- Padlock Security Icon -->
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                </svg>
            </div>

            <div class="mh-error-code mh-error-code-403">403</div>
            <h1 class="mh-error-title">Khu vực hạn chế quyền</h1>
            <p class="mh-error-desc">
                <c:choose>
                    <c:when test="${not empty errorMessage}">
                        <c:out value="${errorMessage}" escapeXml="true" />
                    </c:when>
                    <c:otherwise>
                        Bạn không có đủ đặc quyền để truy cập vào khu vực này. Nếu bạn là quản trị viên, vui lòng đăng nhập bằng tài khoản có thẩm quyền.
                    </c:otherwise>
                </c:choose>
            </p>

            <div class="mh-error-actions">
                <c:choose>
                    <c:when test="${empty sessionScope.userId}">
                        <a href="${ctx}/login" class="mh-btn mh-btn-primary">
                            Đăng nhập tài khoản
                        </a>
                        <a href="${ctx}/" class="mh-btn mh-btn-secondary">
                            Về Trang Chủ
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${ctx}/" class="mh-btn mh-btn-primary">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 8px;">
                                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                                <polyline points="9 22 9 12 15 12 15 22"></polyline>
                            </svg>
                            Về Trang Chủ
                        </a>
                        <button type="button" class="mh-btn mh-btn-secondary" onclick="window.history.back()">
                            Quay lại trang trước
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>

            <nav class="mh-error-quicknav" aria-label="Hỗ trợ điều hướng">
                <a href="${ctx}/movies">Xem phim đang chiếu</a>
                <span>•</span>
                <a href="${ctx}/register">Tạo tài khoản mới</a>
                <span>•</span>
                <a href="${ctx}/forgot-password">Quên mật khẩu?</a>
            </nav>
        </article>
    </main>

    <mh:footer />
</body>
</html>
