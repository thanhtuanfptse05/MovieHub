<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Không thể thực hiện | Quản trị MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <div class="mh-admin-title-row">
        <h1>Không thể hoàn tất thao tác</h1>
    </div>
    <%@ include file="notices.jspf" %>
    <div class="mh-admin-panel" style="max-width: 640px; border-left: 4px solid var(--mh-accent);">
        <h2 style="margin-bottom: 12px; color: var(--mh-text);">
            <c:choose>
                <c:when test="${statusCode == 409}">Tranh chấp dữ liệu (409 Conflict)</c:when>
                <c:when test="${statusCode == 404}">Không tìm thấy nội dung (404 Not Found)</c:when>
                <c:when test="${statusCode == 403}">Từ chối truy cập (403 Forbidden)</c:when>
                <c:otherwise>Lỗi xử lý yêu cầu quản trị (<c:out value="${statusCode}" />)</c:otherwise>
            </c:choose>
        </h2>
        <p style="color: var(--mh-text-muted); line-height: 1.6; margin-bottom: 24px;">
            <c:choose>
                <c:when test="${not empty errorMessage}"><c:out value="${errorMessage}" escapeXml="true" /></c:when>
                <c:when test="${statusCode == 409}">Bản ghi đã được chỉnh sửa bởi một quản trị viên khác hoặc dữ liệu vừa thay đổi. Vui lòng tải lại để lấy dữ liệu mới nhất.</c:when>
                <c:otherwise>Yêu cầu quản trị không thể hoàn tất do dữ liệu không hợp lệ hoặc tài nguyên không còn khả dụng.</c:otherwise>
            </c:choose>
        </p>
        <div class="mh-admin-actions">
            <c:if test="${not empty reloadUrl}">
                <a class="mh-admin-button mh-admin-button-primary" href="<c:out value='${reloadUrl}' />">Tải lại danh sách</a>
            </c:if>
            <a class="mh-admin-button" href="<c:out value='${adminHomeUrl}' />">Về bảng điều khiển</a>
        </div>
    </div>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>
