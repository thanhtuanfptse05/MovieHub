<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="404 - Không tìm thấy trang hoặc bộ phim trên MovieHub">
    <title>404 - Không tìm thấy nội dung | MovieHub</title>
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
</head>
<body>
    <mh:header />

    <main class="mh-error-page mh-error-page-404">
        <article class="mh-error-card">
            <div class="mh-error-visual mh-error-visual-404" aria-hidden="true">
                <!-- Film Clapperboard / Compass Icon -->
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18"></rect>
                    <line x1="7" y1="2" x2="7" y2="22"></line>
                    <line x1="17" y1="2" x2="17" y2="22"></line>
                    <line x1="2" y1="12" x2="22" y2="12"></line>
                    <line x1="2" y1="7" x2="7" y2="7"></line>
                    <line x1="2" y1="17" x2="7" y2="17"></line>
                    <line x1="17" y1="17" x2="22" y2="17"></line>
                    <line x1="17" y1="7" x2="22" y2="7"></line>
                </svg>
            </div>

            <div class="mh-error-code mh-error-code-404">404</div>
            <h1 class="mh-error-title">Không tìm thấy phân cảnh này</h1>
            <p class="mh-error-desc">
                Liên kết bạn vừa truy cập có thể đã bị đổi tên, tạm thời gỡ khỏi rạp chiếu, hoặc chưa từng tồn tại trên MovieHub.
            </p>

            <div class="mh-error-actions">
                <a href="${ctx}/" class="mh-btn mh-btn-primary">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 8px;">
                        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                        <polyline points="9 22 9 12 15 12 15 22"></polyline>
                    </svg>
                    Về Trang Chủ
                </a>
                <a href="${ctx}/movies" class="mh-btn mh-btn-secondary">
                    Khám phá kho phim
                </a>
            </div>

            <nav class="mh-error-quicknav" aria-label="Gợi ý khám phá">
                <a href="${ctx}/movies?sort=views">Phim xem nhiều nhất</a>
                <span>•</span>
                <a href="${ctx}/movies?sort=rating">Phim đánh giá cao</a>
                <span>•</span>
                <a href="${ctx}/movies?sort=newest">Mới phát hành</a>
            </nav>
        </article>
    </main>

    <mh:footer />
</body>
</html>
