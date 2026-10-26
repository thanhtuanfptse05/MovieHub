<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="movies" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin phim | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <c:url var="backUrl" value="/admin/movies"><c:param name="q" value="${q}" /><c:param name="status" value="${status}" /><c:param name="page" value="${returnPage}" /></c:url>
    <c:choose><c:when test="${editing}"><c:url var="saveMovieUrl" value="/admin/movies/edit" /></c:when><c:otherwise><c:url var="saveMovieUrl" value="/admin/movies/create" /></c:otherwise></c:choose>
    <div class="mh-admin-title-row"><h1><c:choose><c:when test="${editing}">Chỉnh sửa phim</c:when><c:otherwise>Thêm phim</c:otherwise></c:choose></h1><a class="mh-admin-link" href="<c:out value='${backUrl}' />">Về danh sách phim</a></div>
    <%@ include file="notices.jspf" %>
    <form method="post" action="<c:out value='${saveMovieUrl}' />" data-confirm-kind="movie" data-current-status="<c:out value='${movie.status}' />" data-confirm-hide="Ẩn phim “{title}” khỏi trang xem phim?" data-confirm-publish="Xuất bản phim “{title}” trên trang xem phim?" data-confirm-action="Lưu thay đổi" data-saving-label="Đang lưu…">
        <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />"><c:if test="${editing}"><input type="hidden" name="id" value="<c:out value='${form.id}' />"><input type="hidden" name="version" value="<c:out value='${form.version}' />"></c:if>
        <c:if test="${not editing}"><input type="hidden" name="submissionId" value="<c:out value='${submissionId}' />"></c:if>
        <%@ include file="return-filters.jspf" %>
        <fieldset class="mh-admin-panel mh-admin-form-section"><legend>Thông tin phim</legend><div class="mh-admin-form-grid">
            <div class="mh-admin-field mh-admin-full"><label for="field-title">Tên phim</label><input id="field-title" name="title" type="text" value="<c:out value='${form.title}' />" required maxlength="200" aria-invalid="${not empty fieldErrors.title}" aria-describedby="error-title"><p id="error-title" class="mh-admin-field-error"><c:out value="${fieldErrors.title}" /></p></div>
            <div class="mh-admin-field mh-admin-full"><label for="field-slug">Đường dẫn</label><input id="field-slug" name="slug" type="text" value="<c:out value='${form.slug}' />" required maxlength="250" pattern="[a-z0-9]+(-[a-z0-9]+)*" aria-invalid="${not empty fieldErrors.slug}" aria-describedby="error-slug hint-slug"><p id="hint-slug" class="mh-admin-hint">Chữ thường không dấu, chữ số và dấu gạch nối.</p><p id="error-slug" class="mh-admin-field-error"><c:out value="${fieldErrors.slug}" /></p></div>
            <div class="mh-admin-field "><label for="field-releaseYear">Năm phát hành</label><input id="field-releaseYear" name="releaseYear" type="text" value="<c:out value='${form.releaseYear}' />" required inputmode="numeric" maxlength="4" aria-invalid="${not empty fieldErrors.releaseYear}" aria-describedby="error-releaseYear"><p id="error-releaseYear" class="mh-admin-field-error"><c:out value="${fieldErrors.releaseYear}" /></p></div>
            <div class="mh-admin-field "><label for="field-durationMinutes">Thời lượng (phút)</label><input id="field-durationMinutes" name="durationMinutes" type="text" value="<c:out value='${form.durationMinutes}' />" required inputmode="numeric" maxlength="3" aria-invalid="${not empty fieldErrors.durationMinutes}" aria-describedby="error-durationMinutes"><p id="error-durationMinutes" class="mh-admin-field-error"><c:out value="${fieldErrors.durationMinutes}" /></p></div>
            <div class="mh-admin-field mh-admin-full"><label for="field-description">Mô tả</label><textarea id="field-description" name="description" required maxlength="10000" rows="6" aria-invalid="${not empty fieldErrors.description}" aria-describedby="error-description"><c:out value="${form.description}" /></textarea><p id="error-description" class="mh-admin-field-error"><c:out value="${fieldErrors.description}" /></p></div>
        </div></fieldset>
        <fieldset class="mh-admin-panel mh-admin-form-section"><legend>Poster và video</legend><div class="mh-admin-form-grid">
            <div class="mh-admin-field mh-admin-full"><label for="field-posterUrl">Đường dẫn poster</label><input id="field-posterUrl" name="posterUrl" type="url" value="<c:out value='${form.posterUrl}' />" maxlength="1000" aria-invalid="${not empty fieldErrors.posterUrl}" aria-describedby="error-posterUrl hint-posterUrl"><p id="hint-posterUrl" class="mh-admin-hint">Nhập đường dẫn ảnh HTTPS.</p><p id="error-posterUrl" class="mh-admin-field-error"><c:out value="${fieldErrors.posterUrl}" /></p></div>
            <div class="mh-admin-field "><label for="field-videoUrl">Đường dẫn video</label><input id="field-videoUrl" name="videoUrl" type="url" value="<c:out value='${form.videoUrl}' />" maxlength="1000" aria-invalid="${not empty fieldErrors.videoUrl}" aria-describedby="error-videoUrl hint-videoUrl"><p id="hint-videoUrl" class="mh-admin-hint">Đường dẫn trực tiếp đến tệp MP4.</p><p id="error-videoUrl" class="mh-admin-field-error"><c:out value="${fieldErrors.videoUrl}" /></p></div>
            <div class="mh-admin-field "><label for="field-trailerUrl">Đường dẫn trailer</label><input id="field-trailerUrl" name="trailerUrl" type="url" value="<c:out value='${form.trailerUrl}' />" maxlength="1000" aria-invalid="${not empty fieldErrors.trailerUrl}" aria-describedby="error-trailerUrl hint-trailerUrl"><p id="hint-trailerUrl" class="mh-admin-hint">Đường dẫn trực tiếp đến tệp MP4.</p><p id="error-trailerUrl" class="mh-admin-field-error"><c:out value="${fieldErrors.trailerUrl}" /></p></div>
        </div></fieldset>
        <fieldset class="mh-admin-panel mh-admin-form-section"><legend>Thể loại và hiển thị</legend><div class="mh-admin-form-grid">
            <div class="mh-admin-field mh-admin-full" id="field-categoryIds"><span class="mh-admin-legend" id="category-label">Thể loại</span>
                <c:choose><c:when test="${empty categories}"><p class="mh-admin-hint">Chưa có thể loại. <a href="<c:out value='${adminCategoriesUrl}' />">Thêm thể loại</a></p></c:when><c:otherwise>
                <div class="mh-admin-checks" role="group" aria-labelledby="category-label" aria-describedby="error-categoryIds"><c:forEach var="option" items="${categories}"><label class="mh-admin-check"><input type="checkbox" name="categoryIds" value="<c:out value='${option.id}' />" <c:if test="${selectedCategoryIds.contains(option.id)}">checked</c:if>><c:out value="${option.name}" /></label></c:forEach></div>
                </c:otherwise></c:choose><p id="error-categoryIds" class="mh-admin-field-error"><c:out value="${fieldErrors.categoryIds}" /></p>
            </div>
            <div class="mh-admin-field"><label for="field-status">Trạng thái</label><select id="field-status" name="status" aria-invalid="${not empty fieldErrors.status}" aria-describedby="error-status">
                <option value="DRAFT" <c:if test="${form.status == 'DRAFT'}">selected</c:if>>Bản nháp</option><option value="PUBLISHED" <c:if test="${form.status == 'PUBLISHED'}">selected</c:if>>Công khai</option><option value="HIDDEN" <c:if test="${form.status == 'HIDDEN'}">selected</c:if>>Đã ẩn</option>
            </select><p id="error-status" class="mh-admin-field-error"><c:out value="${fieldErrors.status}" /></p></div>
            <div class="mh-admin-field"><label class="mh-admin-check" for="field-featured"><input id="field-featured" type="checkbox" name="featured" value="true" <c:if test="${form.featured}">checked</c:if>>Phim nổi bật</label><p class="mh-admin-field-error"><c:out value="${fieldErrors.featured}" /></p></div>
        </div></fieldset>
        <noscript><label class="mh-admin-check"><input type="checkbox" required> Tôi xác nhận trạng thái hiển thị đã chọn.</label></noscript>
        <div class="mh-admin-actions"><button class="mh-admin-button mh-admin-button-primary" type="submit"><c:choose><c:when test="${editing}">Lưu thay đổi</c:when><c:otherwise>Tạo phim</c:otherwise></c:choose></button><a class="mh-admin-link" href="<c:out value='${backUrl}' />">Hủy</a></div>
    </form>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>

