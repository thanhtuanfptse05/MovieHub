<%@ tag language="java" pageEncoding="UTF-8" description="MovieHub Cinema Footer" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<footer class="mh-footer-main" role="contentinfo">
    <div class="mh-footer-glow" aria-hidden="true"></div>
    <div class="mh-footer-container">
        <div class="mh-footer-grid">
            <!-- Brand & Mission Column -->
            <div class="mh-footer-brand-col">
                <a href="${ctx}/" class="mh-footer-logo" aria-label="MovieHub Trang chủ">
                    <span class="mh-logo-text">Movie<span class="mh-logo-accent">Hub</span></span>
                </a>
                <p class="mh-footer-tagline">
                    Nền tảng xem phim trực tuyến, thảo luận cộng đồng và đánh giá điện ảnh đỉnh cao với hình ảnh sắc nét, âm thanh sống động.
                </p>
                <div class="mh-footer-badges" aria-label="Đặc tính nền tảng">
                    <span class="mh-footer-badge">
                        <svg class="mh-badge-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                        Full HD 1080p
                    </span>
                    <span class="mh-footer-badge">
                        <svg class="mh-badge-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M11 5L6 9H2v6h4l5 4V5z"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"/></svg>
                        Âm thanh vòm
                    </span>
                    <span class="mh-footer-badge">
                        <svg class="mh-badge-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                        Phụ đề tiếng Việt
                    </span>
                </div>
            </div>

            <!-- Column 1: Khám phá -->
            <div class="mh-footer-col">
                <h3 class="mh-footer-heading">Khám phá</h3>
                <ul class="mh-footer-list">
                    <li><a href="${ctx}/" class="mh-footer-link">Trang chủ</a></li>
                    <li><a href="${ctx}/movies" class="mh-footer-link">Tất cả phim</a></li>
                    <li><a href="${ctx}/movies?sort=newest" class="mh-footer-link">Mới cập nhật</a></li>
                    <li><a href="${ctx}/movies?sort=views" class="mh-footer-link">Xem nhiều nhất</a></li>
                    <li><a href="${ctx}/movies?sort=rating" class="mh-footer-link">Đánh giá cao</a></li>
                </ul>
            </div>

            <!-- Column 2: Tính năng cá nhân & Cộng đồng -->
            <div class="mh-footer-col">
                <h3 class="mh-footer-heading">Tính năng</h3>
                <ul class="mh-footer-list">
                    <li><a href="${ctx}/favorites" class="mh-footer-link">Danh sách yêu thích</a></li>
                    <c:choose>
                        <c:when test="${not empty sessionScope.userId}">
                            <li><a href="${ctx}/profile" class="mh-footer-link">Hồ sơ cá nhân</a></li>
                            <c:if test="${sessionScope.userRole == 'ADMIN'}">
                                <li>
                                    <a href="${ctx}/admin/dashboard" class="mh-footer-link mh-footer-link-admin">
                                        <svg class="mh-link-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                        Quản trị hệ thống
                                    </a>
                                </li>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${ctx}/login" class="mh-footer-link">Đăng nhập tài khoản</a></li>
                            <li><a href="${ctx}/register" class="mh-footer-link">Đăng ký thành viên</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>

            <!-- Column 3: Thông tin hệ thống -->
            <div class="mh-footer-col">
                <h3 class="mh-footer-heading">Hệ thống</h3>
                <div class="mh-footer-status-card">
                    <div class="mh-footer-status-indicator">
                        <span class="mh-status-pulse" aria-hidden="true"></span>
                        <span class="mh-status-text">Hệ thống trực tuyến</span>
                    </div>
                    <p class="mh-footer-status-desc">
                        Máy chủ vận hành ổn định, sẵn sàng phục vụ 24/7.
                    </p>
                </div>
                <div class="mh-footer-system-meta">
                    <span class="mh-system-chip">MovieHub v2.1.0</span>
                    <span class="mh-system-chip">Jakarta EE 10</span>
                </div>
            </div>
        </div>

        <!-- Sub-footer / Bottom bar -->
        <div class="mh-footer-bottom">
            <div class="mh-footer-bottom-info">
                <p class="mh-footer-copy">© 2026 MovieHub. Đã đăng ký bản quyền. Nền tảng chia sẻ và thảo luận điện ảnh.</p>
            </div>
            <div class="mh-footer-bottom-actions">
                <button type="button" class="mh-footer-backtop" onclick="window.scrollTo({top: 0, behavior: 'smooth'})" aria-label="Cuộn lên đầu trang">
                    <span>Về đầu trang</span>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="mh-backtop-icon" aria-hidden="true"><polyline points="18 15 12 9 6 15"/></svg>
                </button>
            </div>
        </div>
    </div>
</footer>
