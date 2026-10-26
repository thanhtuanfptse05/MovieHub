<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="categories" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý thể loại | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <c:set var="listPath" value="/admin/categories" />
    <div class="mh-admin-title-row"><h1>Thể loại</h1></div>
    <%@ include file="notices.jspf" %>
    <div class="mh-admin-category-layout">
        <section class="mh-admin-panel"><h2>Thêm thể loại</h2><form class="mh-admin-stack" method="post" action="<c:url value='/admin/categories/save' />" data-saving-label="Đang lưu…">
            <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
            <%@ include file="return-filters.jspf" %>
            <div class="mh-admin-field "><label for="field-name">Tên thể loại</label><input id="field-name" name="name" type="text" value="<c:out value='${form.name}' />" required maxlength="100" aria-invalid="${not empty fieldErrors.name}" aria-describedby="error-name"><p id="error-name" class="mh-admin-field-error"><c:out value="${fieldErrors.name}" /></p></div>
            <div class="mh-admin-field "><label for="field-slug">Đường dẫn</label><input id="field-slug" name="slug" type="text" value="<c:out value='${form.slug}' />" required maxlength="120" pattern="[a-z0-9]+(-[a-z0-9]+)*" aria-invalid="${not empty fieldErrors.slug}" aria-describedby="error-slug hint-slug"><p id="hint-slug" class="mh-admin-hint">Chữ thường không dấu, chữ số và dấu gạch nối.</p><p id="error-slug" class="mh-admin-field-error"><c:out value="${fieldErrors.slug}" /></p></div>
            <div><button class="mh-admin-button mh-admin-button-primary" type="submit">Thêm thể loại</button></div>
        </form></section>
        <section aria-label="Các thể loại">
            <form class="mh-admin-toolbar" method="get" action="<c:out value='${adminCategoriesUrl}' />">
                <div class="mh-admin-field mh-admin-search"><label for="category-search">Tìm thể loại</label><input id="category-search" type="search" name="q" maxlength="200" value="<c:out value='${q}' />"></div>
                <div class="mh-admin-actions"><button class="mh-admin-button" type="submit">Tìm kiếm</button><a class="mh-admin-link" href="<c:out value='${adminCategoriesUrl}' />">Xóa lọc</a></div>
            </form>
            <c:choose><c:when test="${empty pageResult}"><div class="mh-admin-empty" role="alert">Không thể tải danh sách thể loại. Vui lòng tải lại.</div></c:when><c:when test="${empty pageResult.items}"><div class="mh-admin-empty">Không có thể loại phù hợp.</div></c:when><c:otherwise>
            <p class="mh-admin-count"><fmt:formatNumber value="${pageResult.total}" /> thể loại</p>
            <div class="mh-admin-table-frame" role="region" aria-label="Danh sách thể loại" tabindex="0"><table class="mh-admin-table"><thead><tr><th scope="col">Thể loại</th><th scope="col">Đường dẫn</th><th scope="col">Thao tác</th></tr></thead><tbody>
            <c:forEach var="item" items="${pageResult.items}"><c:url var="editCategoryUrl" value="/admin/categories/edit"><c:param name="id" value="${item.id}" /><c:param name="q" value="${q}" /><c:param name="page" value="${pageResult.page}" /></c:url>
                <tr><td><a class="mh-admin-cell-title" href="<c:out value='${editCategoryUrl}' />"><c:out value="${item.name}" /></a></td><td><c:out value="${item.slug}" /></td><td><div class="mh-admin-actions"><a class="mh-admin-link" href="<c:out value='${editCategoryUrl}' />">Chỉnh sửa</a><form method="post" action="<c:url value='/admin/categories/delete' />" data-confirm="Xóa thể loại “<c:out value='${item.name}' />”?" data-confirm-action="Xóa thể loại">
                    <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />"><input type="hidden" name="id" value="<c:out value='${item.id}' />"><input type="hidden" name="version" value="<c:out value='${item.version}' />">
                    <%@ include file="return-filters.jspf" %>
                    <button class="mh-admin-button mh-admin-button-danger" type="submit">Xóa</button>
                </form></div></td></tr>
            </c:forEach></tbody></table></div>
            <%@ include file="pagination.jspf" %>
            </c:otherwise></c:choose>
        </section>
    </div>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>

