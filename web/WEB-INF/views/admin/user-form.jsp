<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="users" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa người dùng | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <c:url var="backUrl" value="/admin/users"><c:param name="q" value="${q}" /><c:param name="status" value="${status}" /><c:param name="role" value="${role}" /><c:param name="page" value="${returnPage}" /></c:url>
    <div class="mh-admin-title-row"><h1>Chỉnh sửa người dùng</h1><a class="mh-admin-link" href="<c:out value='${backUrl}' />">Về danh sách người dùng</a></div>
    <%@ include file="notices.jspf" %>
    <section class="mh-admin-panel"><h2><c:out value="${user.fullName}" /></h2><p><c:out value="${user.email}" /></p><p class="mh-admin-cell-meta">Tham gia <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy" /></p></section>
    <form method="post" action="<c:url value='/admin/users/update' />" data-confirm-kind="user" data-current-role="<c:out value='${user.role}' />" data-current-status="<c:out value='${user.status}' />" data-confirm="Thay đổi quyền hoặc khóa tài khoản “<c:out value='${user.fullName}' />”?" data-confirm-action="Lưu thay đổi" data-saving-label="Đang lưu…">
        <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />"><input type="hidden" name="id" value="<c:out value='${form.id}' />"><input type="hidden" name="version" value="<c:out value='${form.version}' />">
        <%@ include file="return-filters.jspf" %>
        <div class="mh-admin-panel mh-admin-form-grid">
            <div class="mh-admin-field"><label for="field-role">Vai trò</label><select id="field-role" name="role" aria-invalid="${not empty fieldErrors.role}" aria-describedby="error-role">
                <option value="USER" <c:if test="${form.role == 'USER'}">selected</c:if> <c:if test="${user.id == currentUserId}">disabled</c:if>>Người dùng</option><option value="ADMIN" <c:if test="${form.role == 'ADMIN'}">selected</c:if>>Quản trị viên</option>
            </select><p id="error-role" class="mh-admin-field-error"><c:out value="${fieldErrors.role}" /></p></div>
            <div class="mh-admin-field"><label for="field-status">Trạng thái</label><select id="field-status" name="status" aria-invalid="${not empty fieldErrors.status}" aria-describedby="error-status">
                <option value="ACTIVE" <c:if test="${form.status == 'ACTIVE'}">selected</c:if>>Hoạt động</option><option value="INACTIVE" <c:if test="${form.status == 'INACTIVE'}">selected</c:if> <c:if test="${user.id == currentUserId}">disabled</c:if>>Đã khóa</option>
            </select><p id="error-status" class="mh-admin-field-error"><c:out value="${fieldErrors.status}" /></p></div>
            <c:if test="${user.id == currentUserId}"><p class="mh-admin-hint mh-admin-full">Đây là tài khoản bạn đang sử dụng.</p></c:if>
        </div>
        <noscript><label class="mh-admin-check"><input type="checkbox" required> Tôi xác nhận thay đổi quyền và trạng thái đã chọn.</label></noscript>
        <div class="mh-admin-actions"><button class="mh-admin-button mh-admin-button-primary" type="submit">Lưu thay đổi</button><a class="mh-admin-link" href="<c:out value='${backUrl}' />">Hủy</a></div>
    </form>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>

