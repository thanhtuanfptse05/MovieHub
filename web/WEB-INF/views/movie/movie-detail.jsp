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
    <script src="${ctx}/assets/js/catalog.js" charset="UTF-8" defer></script>
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
                               data-fallback="<c:out value="${movie.fallbackMediaUrl}" escapeXml="true" />"
                               data-error-notice="Không phát được video chính. Bạn có thể chuyển sang trailer."
                               data-error-fallback="Không phát được video này trên trình duyệt của bạn.">
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

        <!-- Q&A Discussions Section (006-qa) -->
        <section id="qa" class="mh-section mh-qa-section" aria-labelledby="qa-heading">
            <div class="mh-section-header">
                <h2 id="qa-heading" class="mh-section-title">Hỏi đáp về phim</h2>
                <span class="mh-count-sub"><c:out value="${questionsPage.totalCount}" /> câu hỏi cộng đồng</span>
            </div>

            <!-- Flash notification if available -->
            <c:if test="${not empty sessionScope.flashMessage}">
                <div class="mh-alert mh-alert-success" role="status">
                    <c:out value="${sessionScope.flashMessage}" />
                </div>
                <c:remove var="flashMessage" scope="session" />
            </c:if>

            <!-- Ask Question Card (Authenticated) or Login Prompt (Guest) -->
            <c:choose>
                <c:when test="${not empty sessionScope.userId}">
                    <div class="mh-review-box mh-qa-ask-card">
                        <h3 class="mh-form-subtitle">Đặt câu hỏi về bộ phim</h3>
                        <form action="${ctx}/questions/create" method="POST" class="mh-qa-form">
                            <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                            <input type="hidden" name="movieId" value="${movie.id}">
                            <input type="hidden" name="submissionId" value="${questionNonce}">

                            <div class="mh-form-group">
                                <label for="question-content" class="mh-label">Nội dung câu hỏi (10 – 500 ký tự)</label>
                                <textarea id="question-content" name="content" class="mh-textarea" rows="3"
                                          minlength="10" maxlength="500" required
                                          placeholder="Đặt câu hỏi thảo luận về cốt truyện, nhân vật hoặc bối cảnh..."></textarea>
                                <span class="mh-char-counter" id="question-counter">10 - 500 ký tự</span>
                            </div>

                            <div class="mh-form-actions">
                                <button type="submit" class="mh-btn mh-btn-primary">Gửi câu hỏi</button>
                            </div>
                        </form>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="mh-review-box mh-guest-prompt">
                        <p>Đăng nhập để đặt câu hỏi hoặc tham gia thảo luận cùng cộng đồng người xem.</p>
                        <c:url var="qaLoginUrl" value="/login">
                            <c:param name="returnTo" value="/movies/detail?id=${movie.id}#qa" />
                        </c:url>
                        <a href="${qaLoginUrl}" class="mh-btn mh-btn-primary mh-btn-sm">Đăng nhập để hỏi đáp</a>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- User's Submitted Q&A (Personal Tracking) -->
            <c:if test="${not empty myQaPageData and myQaPageData.hasItems}">
                <div class="mh-qa-my-submissions">
                    <h3 class="mh-form-subtitle">Nội dung bạn đã gửi</h3>
                    <div class="mh-qa-my-list">
                        <c:forEach var="item" items="${myQaPageData.items}">
                            <div class="mh-qa-my-item">
                                <div class="mh-qa-item-head">
                                    <div class="mh-qa-tags">
                                        <span class="mh-tag-type ${item.question ? 'is-q' : 'is-a'}"><c:out value="${item.typeLabel}" /></span>
                                        <c:choose>
                                            <c:when test="${item.status eq 'APPROVED'}">
                                                <span class="mh-badge mh-badge-approved">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${item.status eq 'REJECTED'}">
                                                <span class="mh-badge mh-badge-rejected">Bị từ chối</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="mh-badge mh-badge-pending">Chờ duyệt</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <span class="mh-review-date"><c:out value="${item.formattedDate}" /></span>
                                </div>
                                <c:if test="${item.answer}">
                                    <div class="mh-qa-parent-ref">
                                        Trả lời cho: <em><c:out value="${item.questionTitle}" escapeXml="true" /></em>
                                    </div>
                                </c:if>
                                <div class="mh-qa-body">
                                    <p><c:out value="${item.content}" escapeXml="true" /></p>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- My QA Pagination -->
                    <c:if test="${myQaPageData.totalPages > 1}">
                        <nav class="mh-pagination" aria-label="Phân trang nội dung đã gửi">
                            <c:if test="${myQaPageData.hasPrevious()}">
                                <c:url var="prevMyUrl" value="/movies/detail">
                                    <c:param name="id" value="${movie.id}" />
                                    <c:param name="myQaPage" value="${myQaPageData.page - 1}" />
                                </c:url>
                                <a href="${prevMyUrl}#qa" class="mh-btn mh-btn-secondary mh-btn-sm">&laquo; Trước</a>
                            </c:if>
                            <span class="mh-pagination-info">Trang ${myQaPageData.page} / ${myQaPageData.totalPages}</span>
                            <c:if test="${myQaPageData.hasNext()}">
                                <c:url var="nextMyUrl" value="/movies/detail">
                                    <c:param name="id" value="${movie.id}" />
                                    <c:param name="myQaPage" value="${myQaPageData.page + 1}" />
                                </c:url>
                                <a href="${nextMyUrl}#qa" class="mh-btn mh-btn-secondary mh-btn-sm">Sau &raquo;</a>
                            </c:if>
                        </nav>
                    </c:if>
                </div>
            </c:if>

            <!-- Selected Question Thread (when questionId is active) -->
            <c:if test="${not empty selectedQuestion}">
                <div class="mh-qa-thread" id="qa-thread">
                    <div class="mh-qa-thread-header">
                        <c:url var="backAllUrl" value="/movies/detail">
                            <c:param name="id" value="${movie.id}" />
                        </c:url>
                        <a href="${backAllUrl}#qa" class="mh-btn mh-btn-secondary mh-btn-sm">&larr; Xem tất cả câu hỏi</a>
                        <span class="mh-qa-thread-status">Chi tiết thảo luận</span>
                    </div>

                    <!-- Question card -->
                    <div class="mh-qa-thread-question">
                        <div class="mh-qa-author-bar">
                            <c:choose>
                                <c:when test="${not empty selectedQuestion.authorAvatarUrl}">
                                    <img src="<c:out value="${selectedQuestion.authorAvatarUrl}" escapeXml="true" />" alt="" class="mh-author-avatar">
                                </c:when>
                                <c:otherwise>
                                    <div class="mh-avatar-fallback"><c:out value="${fn:substring(selectedQuestion.authorName, 0, 1)}" /></div>
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <strong class="mh-author-name"><c:out value="${selectedQuestion.authorName}" escapeXml="true" /></strong>
                                <span class="mh-review-date"><c:out value="${selectedQuestion.formattedDate}" /></span>
                            </div>
                        </div>
                        <h3 class="mh-qa-thread-title"><c:out value="${selectedQuestion.content}" escapeXml="true" /></h3>
                    </div>

                    <!-- Answers List -->
                    <div class="mh-qa-thread-answers">
                        <h4 class="mh-qa-answers-heading">Câu trả lời (<c:out value="${answersPage != null ? answersPage.totalCount : 0}" />)</h4>
                        <c:choose>
                            <c:when test="${empty answersPage or not answersPage.hasItems}">
                                <div class="mh-empty-box">
                                    <p class="mh-empty-text">Chưa có câu trả lời nào được duyệt cho câu hỏi này.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="ans" items="${answersPage.items}">
                                    <article class="mh-qa-answer-card">
                                        <div class="mh-qa-author-bar">
                                            <c:choose>
                                                <c:when test="${not empty ans.authorAvatarUrl}">
                                                    <img src="<c:out value="${ans.authorAvatarUrl}" escapeXml="true" />" alt="" class="mh-author-avatar">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="mh-avatar-fallback"><c:out value="${fn:substring(ans.authorName, 0, 1)}" /></div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div>
                                                <strong class="mh-author-name"><c:out value="${ans.authorName}" escapeXml="true" /></strong>
                                                <span class="mh-review-date"><c:out value="${ans.formattedDate}" /></span>
                                            </div>
                                        </div>
                                        <div class="mh-qa-answer-body">
                                            <p><c:out value="${ans.content}" escapeXml="true" /></p>
                                        </div>
                                    </article>
                                </c:forEach>

                                <!-- Answer Pagination -->
                                <c:if test="${answersPage.totalPages > 1}">
                                    <nav class="mh-pagination" aria-label="Phân trang câu trả lời">
                                        <c:if test="${answersPage.hasPrevious()}">
                                            <c:url var="prevAnsUrl" value="/movies/detail">
                                                <c:param name="id" value="${movie.id}" />
                                                <c:param name="questionId" value="${selectedQuestion.id}" />
                                                <c:param name="answerPage" value="${answersPage.page - 1}" />
                                            </c:url>
                                            <a href="${prevAnsUrl}#qa-thread" class="mh-btn mh-btn-secondary mh-btn-sm">&laquo; Trước</a>
                                        </c:if>
                                        <span class="mh-pagination-info">Trang ${answersPage.page} / ${answersPage.totalPages}</span>
                                        <c:if test="${answersPage.hasNext()}">
                                            <c:url var="nextAnsUrl" value="/movies/detail">
                                                <c:param name="id" value="${movie.id}" />
                                                <c:param name="questionId" value="${selectedQuestion.id}" />
                                                <c:param name="answerPage" value="${answersPage.page + 1}" />
                                            </c:url>
                                            <a href="${nextAnsUrl}#qa-thread" class="mh-btn mh-btn-secondary mh-btn-sm">Sau &raquo;</a>
                                        </c:if>
                                    </nav>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Reply Form (Authenticated) -->
                    <c:choose>
                        <c:when test="${not empty sessionScope.userId}">
                            <div class="mh-qa-reply-box">
                                <h4 class="mh-form-subtitle">Trả lời câu hỏi này</h4>
                                <form action="${ctx}/answers/create" method="POST" class="mh-qa-form">
                                    <input type="hidden" name="csrfToken" value="<c:out value="${csrfToken}" escapeXml="true" />">
                                    <input type="hidden" name="movieId" value="${movie.id}">
                                    <input type="hidden" name="questionId" value="${selectedQuestion.id}">
                                    <input type="hidden" name="submissionId" value="${answerNonce}">

                                    <div class="mh-form-group">
                                        <label for="answer-content" class="mh-label">Nội dung câu trả lời (1 – 1000 ký tự)</label>
                                        <textarea id="answer-content" name="content" class="mh-textarea" rows="3"
                                                  minlength="1" maxlength="1000" required
                                                  placeholder="Chia sẻ câu trả lời của bạn..."></textarea>
                                    </div>

                                    <div class="mh-form-actions">
                                        <button type="submit" class="mh-btn mh-btn-primary">Gửi câu trả lời</button>
                                    </div>
                                </form>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="mh-guest-prompt-sm">
                                <c:url var="ansLoginUrl" value="/login">
                                    <c:param name="returnTo" value="/movies/detail?id=${movie.id}&questionId=${selectedQuestion.id}#qa-thread" />
                                </c:url>
                                <a href="${ansLoginUrl}" class="mh-link">Đăng nhập để trả lời câu hỏi này &rarr;</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <!-- Public Questions List -->
            <div class="mh-qa-community-list">
                <h3 class="mh-qa-list-title">Danh sách câu hỏi thảo luận</h3>
                <c:choose>
                    <c:when test="${empty questionsPage or not questionsPage.hasItems}">
                        <div class="mh-empty-box">
                            <p class="mh-empty-text">Chưa có câu hỏi nào về bộ phim này. Hãy là người đầu tiên đặt câu hỏi!</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="mh-qa-grid">
                            <c:forEach var="q" items="${questionsPage.items}">
                                <article class="mh-qa-card">
                                    <div class="mh-qa-card-head">
                                        <div class="mh-qa-author-bar">
                                            <c:choose>
                                                <c:when test="${not empty q.authorAvatarUrl}">
                                                    <img src="<c:out value="${q.authorAvatarUrl}" escapeXml="true" />" alt="" class="mh-author-avatar">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="mh-avatar-fallback"><c:out value="${fn:substring(q.authorName, 0, 1)}" /></div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div>
                                                <strong class="mh-author-name"><c:out value="${q.authorName}" escapeXml="true" /></strong>
                                                <span class="mh-review-date"><c:out value="${q.formattedDate}" /></span>
                                            </div>
                                        </div>
                                        <span class="mh-qa-answer-count-badge">${q.answerCount} câu trả lời</span>
                                    </div>

                                    <div class="mh-qa-card-body">
                                        <p><c:out value="${q.content}" escapeXml="true" /></p>
                                    </div>

                                    <div class="mh-qa-card-actions">
                                        <c:url var="threadUrl" value="/movies/detail">
                                            <c:param name="id" value="${movie.id}" />
                                            <c:param name="questionId" value="${q.id}" />
                                        </c:url>
                                        <a href="${threadUrl}#qa" class="mh-btn mh-btn-secondary mh-btn-sm">
                                            Xem thảo luận (${q.answerCount}) &rarr;
                                        </a>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>

                        <!-- Questions Pagination -->
                        <c:if test="${questionsPage.totalPages > 1}">
                            <nav class="mh-pagination" aria-label="Phân trang câu hỏi">
                                <c:if test="${questionsPage.hasPrevious()}">
                                    <c:url var="prevQUrl" value="/movies/detail">
                                        <c:param name="id" value="${movie.id}" />
                                        <c:param name="questionPage" value="${questionsPage.page - 1}" />
                                    </c:url>
                                    <a href="${prevQUrl}#qa" class="mh-btn mh-btn-secondary mh-btn-sm">&laquo; Trang trước</a>
                                </c:if>

                                <span class="mh-pagination-info">Trang ${questionsPage.page} / ${questionsPage.totalPages}</span>

                                <c:if test="${questionsPage.hasNext()}">
                                    <c:url var="nextQUrl" value="/movies/detail">
                                        <c:param name="id" value="${movie.id}" />
                                        <c:param name="questionPage" value="${questionsPage.page + 1}" />
                                    </c:url>
                                    <a href="${nextQUrl}#qa" class="mh-btn mh-btn-secondary mh-btn-sm">Trang sau &raquo;</a>
                                </c:if>
                            </nav>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <mh:movieRow sectionId="sec-similar" title="Phim tương tự" items="${similar}" />
    </main>

    <mh:footer />
</body>
</html>
