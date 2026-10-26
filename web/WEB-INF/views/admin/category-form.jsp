<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="categories" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa thể loại | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <c:url var="backUrl" value="/admin/categories"><c:param name="q" value="${q}" /><c:param name="page" value="${returnPage}" /></c:url>
    <div class="mh-admin-title-row"><h1>Chỉnh sửa thể loại</h1><a class="mh-admin-link" href="<c:out value='${backUrl}' />">Về danh sách thể loại</a></div>
    <%@ include file="notices.jspf" %>
    <form method="post" action="<c:url value='/admin/categories/save' />" data-saving-label="Đang lưu…">
        <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />"><input type="hidden" name="id" value="<c:out value='${form.id}' />"><input type="hidden" name="version" value="<c:out value='${form.version}' />">
        <%@ include file="return-filters.jspf" %>
        <div class="mh-admin-panel mh-admin-form-grid">
            <div class="mh-admin-field "><label for="field-name">Tên thể loại</label><input id="field-name" name="name" type="text" value="<c:out value='${form.name}' />" required maxlength="100" aria-invalid="${not empty fieldErrors.name}" aria-describedby="error-name"><p id="error-name" class="mh-admin-field-error"><c:out value="${fieldErrors.name}" /></p></div>
            <div class="mh-admin-field "><label for="field-slug">Đường dẫn</label><input id="field-slug" name="slug" type="text" value="<c:out value='${form.slug}' />" required maxlength="120" pattern="[a-z0-9]+(-[a-z0-9]+)*" aria-invalid="${not empty fieldErrors.slug}" aria-describedby="error-slug hint-slug"><p id="hint-slug" class="mh-admin-hint">Chữ thường không dấu, chữ số và dấu gạch nối.</p><p id="error-slug" class="mh-admin-field-error"><c:out value="${fieldErrors.slug}" /></p></div>
        </div>
        <div class="mh-admin-actions"><button class="mh-admin-button mh-admin-button-primary" type="submit">Lưu thay đổi</button><a class="mh-admin-link" href="<c:out value='${backUrl}' />">Hủy</a></div>
    </form>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>

