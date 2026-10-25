<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="mh" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Thông tin phim <c:out value="${movie.title}" escapeXml="true" />">
    <title><c:out value="${movie.title}" escapeXml="true" /> | MovieHub</title>
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <script src="${ctx}/assets/js/catalog.js" defer></script>
</head>
<body>
    <mh:header active="movies" />

    <main class="mh-page">
        <nav class="mh-breadcrumb" aria-label="Breadcrumb">
            <a href="${ctx}/">Trang chủ</a><span>/</span>
            <a href="${ctx}/movies">Phim</a><span>/</span>
            <span aria-current="page"><c:out value="${movie.title}" escapeXml="true" /></span>
        </nav>

        <section class="mh-detail">
            <div class="mh-detail-media">
                <c:choose>
                    <c:when test="${movie.hasMedia}">
                        <video id="mh-player" class="mh-player" controls preload="metadata" playsinline
                               poster="<c:out value="${movie.posterUrl}" escapeXml="true" />"
                               src="<c:out value="${movie.primaryMediaUrl}" escapeXml="true" />"
                               data-fallback="<c:out value="${movie.fallbackMediaUrl}" escapeXml="true" />">
                            Trình duyệt của bạn không hỗ trợ phát video.
                        </video>
                        <div class="mh-player-bar">
                            <p id="mh-player-notice" class="mh-player-notice" role="status" hidden></p>
                            <button type="button" id="mh-switch-trailer" class="mh-btn mh-btn-secondary mh-btn-sm" hidden>
                                Chuyển sang trailer
                            </button>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="mh-player mh-player-empty" role="status">
                            <c:choose>
                                <c:when test="${not empty movie.posterUrl}">
                                    <img src="<c:out value="${movie.posterUrl}" escapeXml="true" />" alt=""
                                         referrerpolicy="no-referrer" data-fallback="${ctx}/assets/img/poster-placeholder.svg">
                                </c:when>
                                <c:otherwise>
                                    <img src="${ctx}/assets/img/poster-placeholder.svg" alt="">
                                </c:otherwise>
                            </c:choose>
                            <p>Phim này chưa có video để phát.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="mh-detail-info">
                <h1 class="mh-detail-title"><c:out value="${movie.title}" escapeXml="true" /></h1>

                <ul class="mh-facts">
                    <li><c:out value="${movie.releaseYear}" /></li>
                    <li><c:out value="${movie.durationMinutes}" /> phút</li>
                    <li><fmt:formatNumber value="${movie.viewCount}" /> lượt xem</li>
                </ul>

                <div class="mh-rating-box">
                    <c:choose>
                        <c:when test="${movie.rated}">
                            <span class="mh-rating-score">★ <c:out value="${movie.ratingText}" /></span>
                            <span class="mh-rating-count"><c:out value="${movie.reviewCount}" /> đánh giá</span>
                        </c:when>
                        <c:otherwise>
                            <span class="mh-rating-count">Chưa đánh giá</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="mh-detail-actions">
                    <c:choose>
                        <c:when test="${not empty sessionScope.userId}">
                            <c:choose>
                                <c:when test="${isFavorited}">
                                    <form action="${ctx}/favorites/remove" method="POST" class="mh-inline-form">
                                        <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                                        <input type="hidden" name="movieId" value="${movie.id}">
                                        <input type="hidden" name="returnTo" value="/movies/detail?id=${movie.id}">
                                        <button type="submit" class="mh-btn mh-btn-secondary mh-btn-favorite is-active" title="Bỏ khỏi danh sách yêu thích">
                                            ♥ Đã yêu thích
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <form action="${ctx}/favorites/add" method="POST" class="mh-inline-form">
                                        <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                                        <input type="hidden" name="movieId" value="${movie.id}">
                                        <button type="submit" class="mh-btn mh-btn-primary mh-btn-favorite" title="Thêm vào danh sách yêu thích">
                                            ♡ Yêu thích
                                        </button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <c:url var="favLoginUrl" value="/login">
                                <c:param name="returnTo" value="/movies/detail?id=${movie.id}" />
                            </c:url>
                            <a href="${favLoginUrl}" class="mh-btn mh-btn-secondary mh-btn-favorite" title="Đăng nhập để thêm vào yêu thích">
                                ♡ Yêu thích
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>

                <c:if test="${not empty movie.categories}">
                    <ul class="mh-chips" aria-label="Thể loại">
                        <c:forEach var="cat" items="${movie.categories}">
                            <c:url var="catUrl" value="/movies">
                                <c:param name="category" value="${cat.id}" />
                            </c:url>
                            <li><a href="${catUrl}" class="mh-chip"><c:out value="${cat.name}" escapeXml="true" /></a></li>
                        </c:forEach>
                    </ul>
                </c:if>

                <h2 class="mh-subtitle">Nội dung</h2>
                <p class="mh-description"><c:out value="${movie.description}" escapeXml="true" /></p>
            </div>
        </section>

        <!-- Reviews & Rating Section (005-reviews-rating) -->
        <section id="reviews" class="mh-reviews-section">
            <div class="mh-section-header">
                <h2 class="mh-section-title">Đánh giá &amp; Bình luận</h2>
                <div class="mh-rating-summary-pill">
                    <c:choose>
                        <c:when test="${movie.rated}">
                            <span class="mh-star-icon">★</span>
                            <strong><c:out value="${movie.ratingText}" /></strong>
                            <span class="mh-count-sub">(<c:out value="${reviewsPage.totalCount}" /> lượt đánh giá)</span>
                        </c:when>
                        <c:otherwise>
                            <span class="mh-count-sub">Chưa có đánh giá</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Author's Review Area (Authenticated only) -->
            <c:choose>
                <c:when test="${not empty sessionScope.userId}">
                    <c:choose>
                        <c:when test="${not empty userReview}">
                            <div class="mh-review-box mh-user-review-card">
                                <div class="mh-review-card-head">
                                    <div class="mh-review-author-meta">
                                        <span class="mh-user-review-tag">Đánh giá của bạn</span>
                                        <c:choose>
                                            <c:when test="${userReview.status eq 'APPROVED'}">
                                                <span class="mh-badge mh-badge-approved">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${userReview.status eq 'REJECTED'}">
                                                <span class="mh-badge mh-badge-rejected">Bị từ chối</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="mh-badge mh-badge-pending">Chờ duyệt</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="mh-review-date"><c:out value="${userReview.formattedDate}" /></div>
                                </div>

                                <div class="mh-review-rating-stars">
                                    <c:forEach begin="1" end="5" var="i">
                                        <span class="mh-star ${i <= userReview.rating ? 'is-active' : ''}">★</span>
                                    </c:forEach>
                                    <span class="mh-star-number">${userReview.rating}/5</span>
                                </div>

                                <div class="mh-review-body">
                                    <p><c:out value="${userReview.content}" escapeXml="true" /></p>
                                </div>

                                <div class="mh-review-card-actions">
                                    <button type="button" class="mh-btn mh-btn-secondary mh-btn-sm" id="btn-toggle-edit-review" onclick="document.getElementById('edit-review-form-container').hidden = !document.getElementById('edit-review-form-container').hidden;">
                                        Sửa đánh giá
                                    </button>
                                    <form action="${ctx}/reviews/delete" method="POST" class="mh-inline-form" onsubmit="return confirm('Bạn có chắc chắn muốn xóa đánh giá này?');">
                                        <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                                        <input type="hidden" name="reviewId" value="${userReview.id}">
                                        <input type="hidden" name="version" value="${userReview.version}">
                                        <input type="hidden" name="movieId" value="${movie.id}">
                                        <button type="submit" class="mh-btn mh-btn-danger mh-btn-sm">Xóa đánh giá</button>
                                    </form>
                                </div>

                                <!-- Collapsible Edit Form -->
                                <div id="edit-review-form-container" class="mh-edit-form-wrap" hidden>
                                    <form action="${ctx}/reviews/save" method="POST" class="mh-review-form">
                                        <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                                        <input type="hidden" name="mode" value="update">
                                        <input type="hidden" name="movieId" value="${movie.id}">
                                        <input type="hidden" name="reviewId" value="${userReview.id}">
                                        <input type="hidden" name="version" value="${userReview.version}">

                                        <h3 class="mh-form-subtitle">Chỉnh sửa đánh giá của bạn</h3>

                                        <div class="mh-form-group">
                                            <label class="mh-label">Điểm đánh giá (sao)</label>
                                            <div class="mh-star-picker">
                                                <c:forEach begin="1" end="5" var="s">
                                                    <label class="mh-star-picker-item">
                                                        <input type="radio" name="rating" value="${s}" ${userReview.rating == s ? 'checked' : ''} required>
                                                        <span>★ ${s}</span>
                                                    </label>
                                                </c:forEach>
                                            </div>
                                        </div>

                                        <div class="mh-form-group">
                                            <label for="edit-content" class="mh-label">Nội dung nhận xét (tối đa 1000 ký tự)</label>
                                            <textarea id="edit-content" name="content" class="mh-textarea" rows="4" maxlength="1000" required><c:out value="${userReview.content}" escapeXml="true" /></textarea>
                                        </div>

                                        <div class="mh-form-actions">
                                            <button type="submit" class="mh-btn mh-btn-primary">Lưu thay đổi</button>
                                            <button type="button" class="mh-btn mh-btn-secondary" onclick="document.getElementById('edit-review-form-container').hidden = true;">Hủy</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Create Review Form -->
                            <div class="mh-review-box mh-write-review-card">
                                <h3 class="mh-form-subtitle">Viết đánh giá của bạn</h3>
                                <form action="${ctx}/reviews/save" method="POST" class="mh-review-form">
                                    <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                                    <input type="hidden" name="mode" value="create">
                                    <input type="hidden" name="movieId" value="${movie.id}">

                                    <div class="mh-form-group">
                                        <label class="mh-label">Điểm đánh giá</label>
                                        <div class="mh-star-picker">
                                            <c:forEach begin="1" end="5" var="s">
                                                <label class="mh-star-picker-item">
                                                    <input type="radio" name="rating" value="${s}" ${s == 5 ? 'checked' : ''} required>
                                                    <span>★ ${s}</span>
                                                </label>
                                            </c:forEach>
                                        </div>
                                    </div>

                                    <div class="mh-form-group">
                                        <label for="create-content" class="mh-label">Nội dung nhận xét (tối đa 1000 ký tự)</label>
                                        <textarea id="create-content" name="content" class="mh-textarea" rows="3" maxlength="1000" placeholder="Chia sẻ suy nghĩ và cảm nhận của bạn về bộ phim này..." required></textarea>
                                    </div>

                                    <div class="mh-form-actions">
                                        <button type="submit" class="mh-btn mh-btn-primary">Gửi đánh giá</button>
                                    </div>
                                </form>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <!-- Guest Prompt -->
                    <div class="mh-review-box mh-guest-prompt">
                        <p>Đăng nhập để chia sẻ cảm nhận và chấm điểm cho bộ phim này.</p>
                        <c:url var="revLoginUrl" value="/login">
                            <c:param name="returnTo" value="/movies/detail?id=${movie.id}#reviews" />
                        </c:url>
                        <a href="${revLoginUrl}" class="mh-btn mh-btn-primary mh-btn-sm">Đăng nhập để đánh giá</a>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Public Reviews List -->
            <div class="mh-public-reviews-wrap">
                <h3 class="mh-form-subtitle">Đánh giá từ cộng đồng (${reviewsPage.totalCount})</h3>

                <c:choose>
                    <c:when test="${empty reviewsPage.items}">
                        <div class="mh-empty-box">
                            <p class="mh-empty-text">Chưa có đánh giá nào được duyệt cho phim này. Hãy là người đầu tiên chia sẻ cảm nhận!</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="mh-reviews-grid">
                            <c:forEach var="rev" items="${reviewsPage.items}">
                                <article class="mh-review-card">
                                    <div class="mh-review-card-head">
                                        <div class="mh-author-info">
                                            <c:choose>
                                                <c:when test="${not empty rev.authorAvatarUrl}">
                                                    <img src="<c:out value="${rev.authorAvatarUrl}" escapeXml="true" />" alt="" class="mh-author-avatar">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="mh-avatar-fallback"><c:out value="${fn:substring(rev.authorName, 0, 1)}" /></div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div>
                                                <strong class="mh-author-name"><c:out value="${rev.authorName}" escapeXml="true" /></strong>
                                                <span class="mh-review-date"><c:out value="${rev.formattedDate}" /></span>
                                            </div>
                                        </div>
                                        <div class="mh-review-stars" aria-label="${rev.rating} trên 5 sao">
                                            <c:forEach begin="1" end="5" var="i">
                                                <span class="mh-star ${i <= rev.rating ? 'is-active' : ''}">★</span>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <div class="mh-review-content">
                                        <p><c:out value="${rev.content}" escapeXml="true" /></p>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>

                        <!-- Review Pagination -->
                        <c:if test="${reviewsPage.totalPages > 1}">
                            <nav class="mh-pagination" aria-label="Phân trang đánh giá">
                                <c:if test="${reviewsPage.hasPrevious()}">
                                    <c:url var="prevPageUrl" value="/movies/detail">
                                        <c:param name="id" value="${movie.id}" />
                                        <c:param name="reviewPage" value="${reviewsPage.page - 1}" />
                                    </c:url>
                                    <a href="${prevPageUrl}#reviews" class="mh-btn mh-btn-secondary mh-btn-sm">&laquo; Trang trước</a>
                                </c:if>

                                <span class="mh-pagination-info">Trang ${reviewsPage.page} / ${reviewsPage.totalPages}</span>

                                <c:if test="${reviewsPage.hasNext()}">
                                    <c:url var="nextPageUrl" value="/movies/detail">
                                        <c:param name="id" value="${movie.id}" />
                                        <c:param name="reviewPage" value="${reviewsPage.page + 1}" />
                                    </c:url>
                                    <a href="${nextPageUrl}#reviews" class="mh-btn mh-btn-secondary mh-btn-sm">Trang sau &raquo;</a>
                                </c:if>
                            </nav>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <mh:movieRow sectionId="sec-similar" title="Phim tương tự" items="${similar}" />
    </main>

    <footer class="mh-footer">MovieHub</footer>
</body>
</html>
