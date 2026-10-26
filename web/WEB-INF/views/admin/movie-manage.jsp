<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="movies" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý phim | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <c:set var="listPath" value="/admin/movies" />
    <c:url var="createMovieUrl" value="/admin/movies/create"><c:param name="q" value="${q}" /><c:param name="status" value="${status}" /><c:param name="page" value="${pageResult.page}" /></c:url>
    <div class="mh-admin-title-row"><h1>Phim</h1><a class="mh-admin-button mh-admin-button-primary" href="<c:out value='${createMovieUrl}' />">Thêm phim</a></div>
    <%@ include file="notices.jspf" %>
    <form class="mh-admin-toolbar" method="get" action="<c:out value='${adminMoviesUrl}' />">
        <div class="mh-admin-field mh-admin-search"><label for="movie-search">Tìm phim</label><input id="movie-search" type="search" name="q" maxlength="200" value="<c:out value='${q}' />" placeholder="Tên phim hoặc đường dẫn"></div>
        <div class="mh-admin-field"><label for="movie-status">Trạng thái</label><select id="movie-status" name="status"><option value="">Tất cả</option value="DRAFT" <c:if test="${status == 'DRAFT'}">selected</c:if>>Bản nháp</option><option value="PUBLISHED" <c:if test="${status == 'PUBLISHED'}">selected</c:if>>Công khai</option><option value="HIDDEN" <c:if test="${status == 'HIDDEN'}">selected</c:if>>Đã ẩn</option></select></div>
        <div class="mh-admin-actions"><button class="mh-admin-button" type="submit">Tìm kiếm</button><a class="mh-admin-link" href="<c:out value='${adminMoviesUrl}' />">Xóa lọc</a></div>
    </form>
    <c:choose><c:when test="${empty pageResult}"><div class="mh-admin-empty" role="alert">Không thể tải danh sách phim. Vui lòng tải lại.</div></c:when><c:when test="${empty pageResult.items}"><div class="mh-admin-empty"><p>Không có phim phù hợp.</p><a class="mh-admin-link" href="<c:out value='${adminMoviesUrl}' />">Xem tất cả phim</a></div></c:when><c:otherwise>
    <p class="mh-admin-count"><fmt:formatNumber value="${pageResult.total}" /> phim</p>
    <div class="mh-admin-table-frame" role="region" aria-label="Danh sách phim" tabindex="0">
    <table class="mh-admin-table"><thead><tr><th scope="col">Phim</th><th scope="col">Trạng thái</th><th scope="col" class="mh-admin-num">Lượt xem</th><th scope="col" class="mh-admin-num">Cập nhật</th><th scope="col">Thao tác</th></tr></thead>
    <tbody><c:forEach var="item" items="${pageResult.items}">
        <c:url var="editMovieUrl" value="/admin/movies/edit"><c:param name="id" value="${item.id}" /><c:param name="q" value="${q}" /><c:param name="status" value="${status}" /><c:param name="page" value="${pageResult.page}" /></c:url>
        <tr><td class="mh-admin-identity"><div class="mh-admin-movie">
            <c:choose><c:when test="${not empty item.posterUrl}"><img class="mh-admin-poster" src="<c:out value='${item.posterUrl}' />" alt="" width="40" height="60" loading="lazy" data-poster></c:when><c:otherwise><span class="mh-admin-poster" aria-hidden="true"></span></c:otherwise></c:choose>
            <div><a class="mh-admin-cell-title" href="<c:out value='${editMovieUrl}' />"><c:out value="${item.title}" /></a><p class="mh-admin-cell-meta"><c:out value="${item.releaseYear}" /><c:if test="${not empty item.categoryNames}"> · <c:forEach var="categoryName" items="${item.categoryNames}" varStatus="loop"><c:if test="${not loop.first}">, </c:if><c:out value="${categoryName}" /></c:forEach></c:if></p></div>
        </div></td>
        <td><span class="mh-admin-status ${item.status == 'PUBLISHED' ? 'mh-admin-status-positive' : ''}"><c:choose><c:when test="${item.status == 'PUBLISHED'}">Công khai</c:when><c:when test="${item.status == 'HIDDEN'}">Đã ẩn</c:when><c:otherwise>Bản nháp</c:otherwise></c:choose></span></td>
        <td class="mh-admin-num"><fmt:formatNumber value="${item.viewCount}" /></td>
        <td class="mh-admin-num"><fmt:formatDate value="${item.updatedAt}" pattern="dd/MM/yyyy" /></td>
        <td><div class="mh-admin-actions"><a class="mh-admin-link" href="<c:out value='${editMovieUrl}' />">Chỉnh sửa</a>
            <c:if test="${item.status != 'HIDDEN'}"><form method="post" action="<c:url value='/admin/movies/hide' />" data-confirm="Ẩn phim “<c:out value='${item.title}' />” khỏi trang xem phim?" data-confirm-action="Ẩn phim">
                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />"><input type="hidden" name="id" value="<c:out value='${item.id}' />"><input type="hidden" name="version" value="<c:out value='${item.version}' />">
                <%@ include file="return-filters.jspf" %>
                <button class="mh-admin-button mh-admin-button-danger" type="submit">Ẩn</button>
            </form></c:if>
        </div></td></tr>
    </c:forEach></tbody></table></div>
    <%@ include file="pagination.jspf" %>
    </c:otherwise></c:choose>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>

