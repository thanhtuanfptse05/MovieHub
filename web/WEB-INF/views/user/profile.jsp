<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ cá nhân | MovieHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <header class="mh-header">
        <a href="${pageContext.request.contextPath}/" class="mh-logo">
            Movie<span>Hub</span>
        </a>
        <nav class="mh-nav">
            <a href="${pageContext.request.contextPath}/" style="font-size: 0.95rem;">Trang chủ</a>
            <form action="${pageContext.request.contextPath}/logout" method="POST" style="display: inline; margin: 0;">
                <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                <button type="submit" class="mh-btn mh-btn-secondary" style="height: 38px; padding: 0 16px; font-size: 0.85rem; cursor: pointer;">
                    Đăng xuất
                </button>
            </form>
        </nav>
    </header>

    <main class="mh-auth-container">
        <div class="mh-profile-card">
            <div class="mh-profile-hero">
                <div class="mh-profile-avatar-wrap">
                    <c:choose>
                        <c:when test="${not empty user.avatarUrl}">
                            <img id="avatar-img" 
                                 src="<c:out value="${user.avatarUrl}" escapeXml="true" />" 
                                 alt="Avatar" 
                                 class="mh-profile-avatar"
                                 onerror="this.style.display='none'; document.getElementById('avatar-fallback').style.display='flex';" />
                            <div id="avatar-fallback" class="mh-profile-avatar-fallback" style="display: none;">
                                <c:out value="${user.avatarInitial}" escapeXml="true" />
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div id="avatar-fallback" class="mh-profile-avatar-fallback">
                                <c:out value="${user.avatarInitial}" escapeXml="true" />
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="mh-profile-info">
                    <h1 class="mh-profile-name">
                        <c:out value="${user.fullName}" escapeXml="true" />
                    </h1>
                    <div class="mh-profile-meta">
                        <span class="mh-badge mh-badge-primary">
                            <c:choose>
                                <c:when test="${user.admin}">Quản trị viên</c:when>
                                <c:otherwise>Thành viên</c:otherwise>
                            </c:choose>
                        </span>
                        <span class="mh-badge mh-badge-success">Đang hoạt động</span>
                    </div>
                </div>
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

            <form action="${pageContext.request.contextPath}/profile" method="POST">
                <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                <input type="hidden" name="version" value="<c:out value="${user.version}" escapeXml="true" />">

                <div class="mh-form-grid">
                    <div class="mh-form-group">
                        <label for="fullName" class="mh-label">Họ và tên *</label>
                        <input type="text" id="fullName" name="fullName" class="mh-input" 
                               value="<c:out value="${user.fullName}" escapeXml="true" />" 
                               required maxlength="100" autocomplete="name"
                               placeholder="Nhập họ và tên">
                    </div>

                    <div class="mh-form-group">
                        <label for="email" class="mh-label">Địa chỉ email (chỉ đọc)</label>
                        <input type="email" id="email" class="mh-input" 
                               value="<c:out value="${user.email}" escapeXml="true" />" 
                               readonly disabled>
                    </div>
                </div>

                <div class="mh-form-group">
                    <label for="avatarUrl" class="mh-label">Đường dẫn ảnh đại diện (HTTPS, tùy chọn)</label>
                    <input type="url" id="avatarUrl" name="avatarUrl" class="mh-input" 
                           value="<c:out value="${user.avatarUrl}" escapeXml="true" />" 
                           placeholder="https://example.com/images/avatar.jpg" maxlength="500">
                </div>

                <div class="mh-form-grid">
                    <div class="mh-form-group">
                        <label for="createdAt" class="mh-label">Ngày tham gia</label>
                        <input type="text" id="createdAt" class="mh-input" 
                               value="<c:out value="${user.formattedCreatedAt}" escapeXml="true" />" 
                               readonly disabled>
                    </div>

                    <div class="mh-form-group">
                        <label for="accountRole" class="mh-label">Vai trò tài khoản</label>
                        <input type="text" id="accountRole" class="mh-input" 
                               value="<c:out value="${user.admin ? 'Quản trị viên (ADMIN)' : 'Thành viên (USER)'}" escapeXml="true" />" 
                               readonly disabled>
                    </div>
                </div>

                <div class="mh-form-actions">
                    <a href="${pageContext.request.contextPath}/" class="mh-btn mh-btn-secondary">
                        Về trang chủ
                    </a>
                    <button type="submit" class="mh-btn mh-btn-primary">
                        Lưu thay đổi
                    </button>
                </div>
            </form>
        </div>
    </main>

    <mh:footer />
</body>
</html>
