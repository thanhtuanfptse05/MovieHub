<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="adminSection" value="moderation" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt nội dung | MovieHub</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style.css' />">
    <link rel="stylesheet" href="<c:url value='/assets/css/admin.css' />">
    <script src="<c:url value='/assets/js/admin.js' />" charset="UTF-8" defer></script>
</head>
<body class="mh-admin">
<%@ include file="header.jspf" %>
<main id="admin-main" class="mh-admin-main">
    <c:set var="listPath" value="/admin/moderation" />
    <div class="mh-admin-title-row"><h1>Duyệt nội dung</h1></div>
    <%@ include file="notices.jspf" %>
    <form class="mh-admin-toolbar" method="get" action="<c:out value='${adminModerationUrl}' />">
        <div class="mh-admin-field"><label for="moderation-type">Loại nội dung</label><select id="moderation-type" name="type"><option value="all" <c:if test="${type == 'all'}">selected</c:if>>Tất cả</option><option value="review" <c:if test="${type == 'review'}">selected</c:if>>Đánh giá</option><option value="question" <c:if test="${type == 'question'}">selected</c:if>>Câu hỏi</option><option value="answer" <c:if test="${type == 'answer'}">selected</c:if>>Câu trả lời</option></select></div>
        <div class="mh-admin-field"><label for="moderation-status">Trạng thái</label><select id="moderation-status" name="status"><option value="PENDING" <c:if test="${status == 'PENDING'}">selected</c:if>>Chờ duyệt</option><option value="APPROVED" <c:if test="${status == 'APPROVED'}">selected</c:if>>Đã duyệt</option><option value="REJECTED" <c:if test="${status == 'REJECTED'}">selected</c:if>>Từ chối</option></select></div>
        <button class="mh-admin-button" type="submit">Lọc nội dung</button>
    </form>
    <c:choose><c:when test="${empty pageResult}"><div class="mh-admin-empty" role="alert">Không thể tải nội dung. Vui lòng tải lại.</div></c:when><c:when test="${empty pageResult.items}"><div class="mh-admin-empty">Không có nội dung phù hợp.</div></c:when><c:otherwise>
    <p class="mh-admin-count"><fmt:formatNumber value="${pageResult.total}" /> nội dung</p>
    <div class="mh-admin-moderation-list"><c:forEach var="item" items="${pageResult.items}">
        <article class="mh-admin-panel" aria-labelledby="moderation-<c:out value='${item.type}' />-<c:out value='${item.id}' />">
            <div class="mh-admin-moderation-head">
                <div><h2 id="moderation-<c:out value='${item.type}' />-<c:out value='${item.id}' />"><c:choose><c:when test="${item.type == 'review'}">Đánh giá</c:when><c:when test="${item.type == 'question'}">Câu hỏi</c:when><c:otherwise>Câu trả lời</c:otherwise></c:choose> của <c:out value="${item.authorName}" /></h2><p class="mh-admin-cell-meta"><fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm" /></p></div>
                <span class="mh-admin-status ${item.status == 'PENDING' ? 'mh-admin-status-pending' : item.status == 'APPROVED' ? 'mh-admin-status-positive' : 'mh-admin-status-rejected'}"><c:choose><c:when test="${item.status == 'PENDING'}">Chờ duyệt</c:when><c:when test="${item.status == 'APPROVED'}">Đã duyệt</c:when><c:otherwise>Từ chối</c:otherwise></c:choose></span>
            </div>
            <c:url var="contextMovieUrl" value="/admin/movies/edit"><c:param name="id" value="${item.movieId}" /></c:url>
            <p class="mh-admin-context">Phim: <a href="<c:out value='${contextMovieUrl}' />"><c:out value="${item.movieTitle}" /></a></p>
            <c:if test="${item.type == 'answer' and not empty item.questionContent}"><p class="mh-admin-context">Câu hỏi: <c:out value="${item.questionContent}" /></p></c:if>
            <c:if test="${item.type == 'review' and not empty item.rating}"><p class="mh-admin-rating">Điểm: <c:out value="${item.rating}" /> / 5</p></c:if>
            <p class="mh-admin-content"><c:out value="${item.content}" /></p>
            <c:if test="${not item.approveAllowed}"><p class="mh-admin-decision-note" id="blocked-<c:out value='${item.type}' />-<c:out value='${item.id}' />"><c:out value="${item.approveBlockedReason}" /></p></c:if>
            <form class="mh-admin-actions" method="post" action="<c:url value='/admin/moderation/decide' />" data-saving-label="Đang lưu…">
                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />"><input type="hidden" name="type" value="<c:out value='${item.type}' />"><input type="hidden" name="id" value="<c:out value='${item.id}' />"><input type="hidden" name="version" value="<c:out value='${item.version}' />"><input type="hidden" name="contentRevision" value="<c:out value='${item.contentRevision}' />">
                <%@ include file="return-filters.jspf" %>
                <button class="mh-admin-button" type="submit" name="action" value="APPROVE" <c:if test="${not item.approveAllowed}">disabled aria-describedby="blocked-<c:out value='${item.type}' />-<c:out value='${item.id}' />"</c:if>>Duyệt</button>
                <button class="mh-admin-button mh-admin-button-danger" type="submit" name="action" value="REJECT">Từ chối</button>
            </form>
        </article>
    </c:forEach></div>
    <%@ include file="pagination.jspf" %>
    </c:otherwise></c:choose>
</main>
<%@ include file="footer.jspf" %>
</body>
</html>

