<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="500 - Sự cố kỹ thuật tạm thời trên hệ thống MovieHub">
    <title>500 - Sự cố kỹ thuật | MovieHub</title>
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
</head>
<body>
    <header class="mh-header">
        <a href="${ctx}/" class="mh-logo">
            Movie<span>Hub</span>
        </a>
        <nav class="mh-nav" aria-label="Điều hướng chính">
            <a href="${ctx}/" class="mh-nav-link">Trang chủ</a>
            <a href="${ctx}/movies" class="mh-nav-link">Phim</a>
            <c:choose>
                <c:when test="${not empty sessionScope.userId}">
                    <a href="${ctx}/favorites" class="mh-nav-link">Yêu thích</a>
                    <a href="${ctx}/profile" class="mh-nav-link">Tài khoản</a>
                </c:when>
                <c:otherwise>
                    <a href="${ctx}/login" class="mh-btn mh-btn-secondary mh-btn-sm" style="height: 38px; padding: 0 16px;">Đăng nhập</a>
                </c:otherwise>
            </c:choose>
        </nav>
    </header>

    <main class="mh-error-page mh-error-page-500">
        <article class="mh-error-card">
            <div class="mh-error-visual mh-error-visual-500" aria-hidden="true">
                <!-- Film Reel Server Maintenance Icon -->
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"></circle>
                    <line x1="12" y1="8" x2="12" y2="12"></line>
                    <line x1="12" y1="16" x2="12.01" y2="16"></line>
                </svg>
            </div>

            <div class="mh-error-code mh-error-code-500">500</div>
            <h1 class="mh-error-title">Sự cố máy chủ tạm thời</h1>
            <p class="mh-error-desc">
                Hệ thống đang gặp sự cố gián đoạn trong khi xử lý dữ liệu chiếu phim. Sự cố đã được tự động ghi nhận để đội ngũ kỹ thuật khắc phục ngay lập tức.
            </p>

            <c:if test="${not empty correlationId}">
                <div class="mh-correlation-pill">
                    <span>Mã đối soát:</span>
                    <code id="mh-err-code"><c:out value="${correlationId}" escapeXml="true" /></code>
                    <button type="button" class="mh-copy-btn" id="mh-copy-btn" onclick="navigator.clipboard.writeText('<c:out value="${correlationId}" escapeXml="true" />').then(()=>{const b=document.getElementById('mh-copy-btn');b.innerText='Đã chép!';setTimeout(()=>b.innerText='Sao chép',2000);})">
                        Sao chép
                    </button>
                </div>
            </c:if>

            <div class="mh-error-actions">
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
            </div>

            <nav class="mh-error-quicknav" aria-label="Liên kết hữu ích">
                <a href="${ctx}/movies">Danh mục phim</a>
                <span>•</span>
                <a href="${ctx}/movies?sort=views">Phim xem nhiều</a>
                <span>•</span>
                <a href="${ctx}/movies?sort=newest">Phim mới cập nhật</a>
            </nav>
        </article>
    </main>
</body>
</html>
