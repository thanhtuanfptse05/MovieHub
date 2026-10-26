<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="users" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý người dùng | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <c:set var="listPath" value="/admin/users" />
    <div class="mh-admin-title-row"><h1>Người dùng</h1></div>
    <%@ include file="notices.jspf" %>
    <form class="mh-admin-toolbar" method="get" action="<c:out value='${adminUsersUrl}' />">
        <div class="mh-admin-field mh-admin-search"><label for="user-search">Tìm theo email</label><input id="user-search" type="search" name="q" maxlength="200" value="<c:out value='${q}' />"></div>
        <div class="mh-admin-field"><label for="user-role">Vai trò</label><select id="user-role" name="role"><option value="">Tất cả</option><option value="USER" <c:if test="${role == 'USER'}">selected</c:if>>Người dùng</option><option value="ADMIN" <c:if test="${role == 'ADMIN'}">selected</c:if>>Quản trị viên</option></select></div>
        <div class="mh-admin-field"><label for="user-status">Trạng thái</label><select id="user-status" name="status"><option value="">Tất cả</option><option value="ACTIVE" <c:if test="${status == 'ACTIVE'}">selected</c:if>>Hoạt động</option><option value="INACTIVE" <c:if test="${status == 'INACTIVE'}">selected</c:if>>Đã khóa</option></select></div>
        <div class="mh-admin-actions"><button class="mh-admin-button" type="submit">Tìm kiếm</button><a class="mh-admin-link" href="<c:out value='${adminUsersUrl}' />">Xóa lọc</a></div>
    </form>
    <c:choose><c:when test="${empty pageResult}"><div class="mh-admin-empty" role="alert">Không thể tải danh sách người dùng. Vui lòng tải lại.</div></c:when><c:when test="${empty pageResult.items}"><div class="mh-admin-empty">Không có người dùng phù hợp.</div></c:when><c:otherwise>
    <p class="mh-admin-count"><fmt:formatNumber value="${pageResult.total}" /> người dùng</p>
    <div class="mh-admin-table-frame" role="region" aria-label="Danh sách người dùng" tabindex="0"><table class="mh-admin-table"><thead><tr><th scope="col">Người dùng</th><th scope="col">Vai trò</th><th scope="col">Trạng thái</th><th scope="col" class="mh-admin-num">Ngày tham gia</th><th scope="col">Thao tác</th></tr></thead><tbody>
    <c:forEach var="item" items="${pageResult.items}"><c:url var="editUserUrl" value="/admin/users/edit"><c:param name="id" value="${item.id}" /><c:param name="q" value="${q}" /><c:param name="role" value="${role}" /><c:param name="status" value="${status}" /><c:param name="page" value="${pageResult.page}" /></c:url>
        <tr><td class="mh-admin-identity"><a class="mh-admin-cell-title" href="<c:out value='${editUserUrl}' />"><c:out value="${item.fullName}" /></a><p class="mh-admin-cell-meta"><c:out value="${item.email}" /></p></td><td><c:choose><c:when test="${item.role == 'ADMIN'}">Quản trị viên</c:when><c:otherwise>Người dùng</c:otherwise></c:choose></td><td><span class="mh-admin-status ${item.status == 'ACTIVE' ? 'mh-admin-status-positive' : ''}"><c:choose><c:when test="${item.status == 'ACTIVE'}">Hoạt động</c:when><c:otherwise>Đã khóa</c:otherwise></c:choose></span></td><td class="mh-admin-num"><fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy" /></td><td><a class="mh-admin-link" href="<c:out value='${editUserUrl}' />">Chỉnh sửa</a></td></tr>
    </c:forEach></tbody></table></div>
    <%@ include file="pagination.jspf" %>
    </c:otherwise></c:choose>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>

