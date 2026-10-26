<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="dashboard" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng quan quản trị | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <div class="mh-admin-title-row"><h1>Quản trị MovieHub</h1></div>
    <%@ include file="notices.jspf" %>
    <nav class="mh-admin-hub" aria-label="Công việc quản trị">
        <a href="<c:out value='${adminMoviesUrl}' />"><h2>Phim</h2><p>Thêm phim, chỉnh sửa nội dung và xuất bản.</p></a>
        <a href="<c:out value='${adminModerationUrl}' />"><h2>Duyệt nội dung</h2><p>Xem đánh giá, câu hỏi và câu trả lời.</p></a>
        <a href="<c:out value='${adminCategoriesUrl}' />"><h2>Thể loại</h2><p>Thêm và chỉnh sửa thể loại phim.</p></a>
        <a href="<c:out value='${adminUsersUrl}' />"><h2>Người dùng</h2><p>Quản lý quyền và trạng thái tài khoản.</p></a>
    </nav>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>

