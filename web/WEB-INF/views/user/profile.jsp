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
    <mh:header active="profile" />

    <main class="mh-auth-container">
        <div class="mh-auth-glow-1" aria-hidden="true"></div>
        <div class="mh-auth-glow-2" aria-hidden="true"></div>

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
                    <span class="mh-avatar-status-dot" title="Tài khoản đang hoạt động" aria-label="Đang hoạt động"></span>
                </div>

                <div class="mh-profile-info">
                    <h1 class="mh-profile-name">
                        <c:out value="${user.fullName}" escapeXml="true" />
                    </h1>
                    <div class="mh-profile-meta">
                        <span class="mh-badge mh-badge-primary">
                            <c:choose>
                                <c:when test="${user.admin}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="12" height="12" style="margin-right: 4px;"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                    <span>Quản trị viên (ADMIN)</span>
                                </c:when>
                                <c:otherwise>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="12" height="12" style="margin-right: 4px;"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                    <span>Thành viên (USER)</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                        <span class="mh-badge mh-badge-success">
                            <span style="display: inline-block; width: 6px; height: 6px; border-radius: 50%; background: #22c55e; margin-right: 6px;"></span>
                            Đang hoạt động
                        </span>
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

                <div class="mh-profile-group-title">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16" aria-hidden="true"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    <span>Thông tin cá nhân &amp; Hiển thị</span>
                </div>

                <div class="mh-form-grid">
                    <div class="mh-form-group">
                        <label for="fullName" class="mh-label">Họ và tên *</label>
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            <input type="text" id="fullName" name="fullName" class="mh-input mh-input-with-icon" 
                                   value="<c:out value="${user.fullName}" escapeXml="true" />" 
                                   required maxlength="100" autocomplete="name"
                                   placeholder="Nhập họ và tên">
                        </div>
                    </div>

                    <div class="mh-form-group">
                        <label for="email" class="mh-label">Địa chỉ email (chỉ đọc)</label>
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            <input type="email" id="email" class="mh-input mh-input-with-icon" 
                                   value="<c:out value="${user.email}" escapeXml="true" />" 
                                   readonly disabled>
                        </div>
                    </div>
                </div>

                <div class="mh-form-group">
                    <label for="avatarUrl" class="mh-label">Đường dẫn ảnh đại diện (HTTPS, tùy chọn)</label>
                    <div class="mh-input-wrap">
                        <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                        <input type="url" id="avatarUrl" name="avatarUrl" class="mh-input mh-input-with-icon" 
                               value="<c:out value="${user.avatarUrl}" escapeXml="true" />" 
                               placeholder="https://example.com/images/avatar.jpg" maxlength="500">
                    </div>
                </div>

                <div class="mh-profile-group-title" style="margin-top: 28px;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16" aria-hidden="true"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    <span>Phân quyền &amp; Bảo mật tài khoản</span>
                </div>

                <div class="mh-form-grid">
                    <div class="mh-form-group">
                        <label for="createdAt" class="mh-label">Ngày tham gia hệ thống</label>
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <input type="text" id="createdAt" class="mh-input mh-input-with-icon" 
                                   value="<c:out value="${user.formattedCreatedAt}" escapeXml="true" />" 
                                   readonly disabled>
                        </div>
                    </div>

                    <div class="mh-form-group">
                        <label for="accountRole" class="mh-label">Vai trò tài khoản</label>
                        <div class="mh-input-wrap">
                            <svg class="mh-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            <input type="text" id="accountRole" class="mh-input mh-input-with-icon" 
                                   value="<c:out value="${user.admin ? 'Quản trị viên (ADMIN)' : 'Thành viên (USER)'}" escapeXml="true" />" 
                                   readonly disabled>
                        </div>
                    </div>
                </div>

                <div class="mh-form-actions" style="margin-top: 32px; padding-top: 20px; border-top: 1px solid rgba(171, 137, 135, 0.2);">
                    <a href="${pageContext.request.contextPath}/" class="mh-btn mh-btn-secondary" style="border-radius: 9999px;">
                        Về trang chủ
                    </a>
                    <button type="submit" class="mh-btn mh-btn-primary" style="border-radius: 9999px; display: inline-flex; align-items: center; gap: 8px;">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16" aria-hidden="true"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                        <span>Lưu thay đổi</span>
                    </button>
                </div>
            </form>
        </div>
    </main>

    <mh:footer />
</body>
</html>
