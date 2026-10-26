<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Tìm kiếm và lọc phim theo tên, thể loại, năm phát hành.">
    <title>Danh sách phim | MovieHub</title>
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <script src="${ctx}/assets/js/catalog.js" charset="UTF-8" defer></script>
</head>
<body>
    <mh:header active="movies" />

    <main class="mh-page">
        <h1 class="mh-page-title">Danh sách phim</h1>

        <form action="${ctx}/movies" method="GET" class="mh-filter" role="search">
            <div class="mh-filter-field mh-filter-q">
                <label for="q" class="mh-label">Tên phim</label>
                <input type="search" id="q" name="q" class="mh-input${query.errors['q'] != null ? ' has-error' : ''}"
                       value="<c:out value="${query.q}" escapeXml="true" />" maxlength="200"
                       placeholder="Nhập tên phim">
                <c:if test="${query.errors['q'] != null}">
                    <p class="mh-field-error"><c:out value="${query.errors['q']}" /></p>
                </c:if>
            </div>

            <div class="mh-filter-field">
                <label for="category" class="mh-label">Thể loại</label>
                <select id="category" name="category" class="mh-input${query.errors['category'] != null ? ' has-error' : ''}">
                    <option value="">Tất cả</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}" ${query.categoryId == cat.id ? 'selected' : ''}>
                            <c:out value="${cat.name}" escapeXml="true" />
                        </option>
                    </c:forEach>
                </select>
                <c:if test="${query.errors['category'] != null}">
                    <p class="mh-field-error"><c:out value="${query.errors['category']}" /></p>
                </c:if>
            </div>

            <div class="mh-filter-field">
                <label for="year" class="mh-label">Năm</label>
                <select id="year" name="year" class="mh-input${query.errors['year'] != null ? ' has-error' : ''}">
                    <option value="">Tất cả</option>
                    <c:forEach var="y" items="${years}">
                        <option value="${y}" ${query.year == y ? 'selected' : ''}>${y}</option>
                    </c:forEach>
                </select>
                <c:if test="${query.errors['year'] != null}">
                    <p class="mh-field-error"><c:out value="${query.errors['year']}" /></p>
                </c:if>
            </div>

            <div class="mh-filter-field">
                <label for="sort" class="mh-label">Sắp xếp</label>
                <select id="sort" name="sort" class="mh-input">
                    <option value="newest" ${query.sort == 'newest' ? 'selected' : ''}>Mới cập nhật</option>
                    <option value="views" ${query.sort == 'views' ? 'selected' : ''}>Xem nhiều</option>
                    <option value="rating" ${query.sort == 'rating' ? 'selected' : ''}>Đánh giá cao</option>
                    <option value="title" ${query.sort == 'title' ? 'selected' : ''}>Tên A-Z</option>
                </select>
            </div>

            <div class="mh-filter-actions">
                <button type="submit" class="mh-btn mh-btn-primary">Tìm</button>
                <a href="${ctx}/movies" class="mh-btn mh-btn-secondary">Xóa lọc</a>
            </div>
        </form>

        <c:choose>
            <c:when test="${not query.valid}">
                <div class="mh-alert mh-alert-error" role="alert">
                    Bộ lọc chưa hợp lệ. Vui lòng kiểm tra các trường được đánh dấu.
                </div>
            </c:when>
            <c:when test="${result.total == 0}">
                <div class="mh-empty">
                    <p class="mh-empty-title">Không tìm thấy phim phù hợp</p>
                    <p class="mh-empty-desc">Hãy thử đổi từ khóa hoặc bỏ bớt bộ lọc.</p>
                </div>
            </c:when>
            <c:otherwise>
                <p class="mh-result-count">
                    <strong><c:out value="${result.total}" /></strong> phim
                    <span class="mh-dot"></span> Trang <c:out value="${result.page}" />/<c:out value="${result.totalPages}" />
                </p>
                <div class="mh-grid">
                    <c:forEach var="m" items="${result.items}">
                        <mh:movieCard card="${m}" />
                    </c:forEach>
                </div>
                <mh:pager query="${query}" result="${result}" />
            </c:otherwise>
        </c:choose>
    </main>

    <mh:footer />
</body>
</html>
