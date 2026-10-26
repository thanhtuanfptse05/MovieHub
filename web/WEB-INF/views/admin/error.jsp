<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Không thể thực hiện | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <div class="mh-admin-title-row"><h1>Không thể thực hiện</h1></div>
    <%@ include file="notices.jspf" %>
    <div class="mh-admin-panel">
        <c:choose><c:when test="${statusCode == 409}"><p>Dữ liệu đã thay đổi hoặc thao tác chưa thể thực hiện. Vui lòng tải lại để kiểm tra.</p></c:when><c:otherwise><p>Vui lòng kiểm tra thông tin rồi thử lại.</p></c:otherwise></c:choose>
        <div class="mh-admin-actions">
            <c:if test="${not empty reloadUrl}"><a class="mh-admin-link" href="<c:out value='${reloadUrl}' />">Tải lại</a></c:if>
            <a class="mh-admin-link" href="<c:out value='${adminHomeUrl}' />">Về quản trị</a>
        </div>
    </div>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>

