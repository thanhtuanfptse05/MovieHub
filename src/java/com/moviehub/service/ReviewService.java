package com.moviehub.service;

import com.moviehub.dao.MovieDAO;
import com.moviehub.dao.ReviewDAO;
import com.moviehub.dao.UserDAO;
import com.moviehub.dto.ReviewItem;
import com.moviehub.dto.ReviewPage;
import com.moviehub.entity.Movie;
import com.moviehub.entity.Review;
import com.moviehub.entity.User;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.ForbiddenException;
import com.moviehub.exception.NotFoundException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.Normalizer;
import java.time.Clock;
import java.time.Instant;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

/**
 * Service encapsulating business rules for movie reviews and ratings (005-reviews-rating).
 * Strictly implements EARS criteria REV-AC-01 through REV-AC-11.
 */
public class ReviewService {

    public static final int PAGE_SIZE = 10;
    public static final int MAX_CONTENT_LENGTH = 1000;

    private final ReviewDAO reviewDAO;
    private final MovieDAO movieDAO;
    private final UserDAO userDAO;
    private final Clock clock;

    public ReviewService() {
        this(new ReviewDAO(), new MovieDAO(), new UserDAO(), Clock.systemUTC());
    }

    public ReviewService(ReviewDAO reviewDAO, MovieDAO movieDAO, UserDAO userDAO, Clock clock) {
        this.reviewDAO = reviewDAO;
        this.movieDAO = movieDAO;
        this.userDAO = userDAO;
        this.clock = clock;
    }

    // ---------------------------------------------------------------- validation

    public String validateAndNormalizeContent(String rawContent) {
        if (rawContent == null) {
            throw new IllegalArgumentException("Nội dung đánh giá không được để trống.");
        }
        String normalized = Normalizer.normalize(rawContent.trim(), Normalizer.Form.NFC).trim();
        if (normalized.isEmpty()) {
            throw new IllegalArgumentException("Nội dung đánh giá không được để trống.");
        }
        if (normalized.length() > MAX_CONTENT_LENGTH) {
            throw new IllegalArgumentException("Nội dung đánh giá không được vượt quá 1000 ký tự.");
        }
        return normalized;
    }

    public void validateRating(Integer rating) {
        if (rating == null || rating < 1 || rating > 5) {
            throw new IllegalArgumentException("Điểm đánh giá phải là số nguyên từ 1 đến 5 sao.");
        }
    }

    private void checkActiveActor(Long actorId) {
        if (actorId == null) {
            throw new ForbiddenException("Bạn cần đăng nhập để thực hiện thao tác này.");
        }
        User actor = userDAO.findById(actorId).orElse(null);
        if (actor == null || !User.STATUS_ACTIVE.equals(actor.getStatus())) {
            throw new ForbiddenException("Tài khoản của bạn đã bị khóa hoặc không tồn tại.");
        }
    }

    private Movie checkPublishedMovie(Long movieId) {
        if (movieId == null) {
            throw new NotFoundException("Phim không tồn tại.");
        }
        Movie movie = movieDAO.findPublishedById(movieId);
        if (movie == null) {
            throw new NotFoundException("Phim không tồn tại hoặc chưa phát hành.");
        }
        return movie;
    }

    // ---------------------------------------------------------------- review lifecycle

    /**
     * Creates a new review or restores a soft-deleted one (REV-AC-02, REV-SC-05).
     * If an active review already exists, throws ConflictException 409 (REV-AC-03).
     */
    public Review createReview(Long actorId, Long movieId, Integer rating, String rawContent) {
        checkActiveActor(actorId);
        checkPublishedMovie(movieId);
        validateRating(rating);
        String content = validateAndNormalizeContent(rawContent);

        Optional<Review> existingOpt = reviewDAO.findByUserAndMovie(actorId, movieId);
        Instant now = Instant.now(clock);

        if (existingOpt.isPresent()) {
            Review existing = existingOpt.get();
            if (existing.isActive()) {
                throw new ConflictException("Bạn đã có đánh giá cho phim này. Hãy dùng chức năng sửa đánh giá.");
            }
            // Restore soft-deleted review
            existing.setDeletedAt(null);
            existing.setRating(rating);
            existing.setContent(content);
            existing.setStatus(Review.STATUS_PENDING);
            existing.setModeratedBy(null);
            existing.setModeratedAt(null);
            existing.setUpdatedAt(now);
            existing.setContentRevision(existing.getContentRevision() + 1);
            return reviewDAO.save(existing);
        }

        // New review
        Review r = new Review();
        r.setUserId(actorId);
        r.setMovieId(movieId);
        r.setRating(rating);
        r.setContent(content);
        r.setStatus(Review.STATUS_PENDING);
        r.setModeratedBy(null);
        r.setModeratedAt(null);
        r.setCreatedAt(now);
        r.setUpdatedAt(now);
        r.setDeletedAt(null);
        r.setVersion(1);
        r.setContentRevision(1);
        return reviewDAO.save(r);
    }

    /**
     * Updates an existing review (REV-AC-04, REV-AC-05, REV-AC-09, REV-AC-10).
     * Identical content/rating submission is a no-op that retains APPROVED status.
     * Modified content/rating or resubmitting REJECTED resets to PENDING and clears audit.
     */
    public Review updateReview(Long actorId, Long reviewId, Long movieId, Integer version, Integer rating, String rawContent) {
        checkActiveActor(actorId);
        validateRating(rating);
        String content = validateAndNormalizeContent(rawContent);

        if (reviewId == null) {
            throw new IllegalArgumentException("Mã đánh giá không hợp lệ.");
        }

        Review review = reviewDAO.findById(reviewId)
                .orElseThrow(() -> new NotFoundException("Đánh giá không tồn tại."));

        if (!review.isActive()) {
            throw new NotFoundException("Đánh giá đã bị xóa.");
        }

        if (!actorId.equals(review.getUserId())) {
            throw new ForbiddenException("Bạn không có quyền chỉnh sửa đánh giá của người khác.");
        }

        if (movieId == null || !movieId.equals(review.getMovieId())) {
            throw new IllegalArgumentException("Thông tin phim không khớp với đánh giá.");
        }

        checkPublishedMovie(review.getMovieId());

        if (version == null || !version.equals(review.getVersion())) {
            throw new ConflictException("Đánh giá đã được cập nhật ở phiên khác. Vui lòng tải lại trang.");
        }

        boolean wasRejected = Review.STATUS_REJECTED.equals(review.getStatus());
        boolean contentChanged = !content.equals(review.getContent());
        boolean ratingChanged = !rating.equals(review.getRating());

        // Identical submission of an un-rejected review is a no-op
        if (!wasRejected && !contentChanged && !ratingChanged) {
            return review;
        }

        Instant now = Instant.now(clock);
        review.setRating(rating);
        review.setContent(content);
        review.setStatus(Review.STATUS_PENDING);
        review.setModeratedBy(null);
        review.setModeratedAt(null);
        review.setUpdatedAt(now);
        review.setContentRevision(review.getContentRevision() + 1);

        return reviewDAO.save(review);
    }

    /**
     * Soft-deletes a review (REV-AC-05, REV-AC-06, REV-AC-09).
     * Idempotent retry with the same version on an already-deleted review succeeds.
     */
    public boolean deleteReview(Long actorId, Long reviewId, Integer version) {
        checkActiveActor(actorId);

        if (reviewId == null) {
            throw new IllegalArgumentException("Mã đánh giá không hợp lệ.");
        }

        Review review = reviewDAO.findById(reviewId)
                .orElseThrow(() -> new NotFoundException("Đánh giá không tồn tại."));

        // If already deleted
        if (!review.isActive()) {
            if (version != null && version.equals(review.getVersion())) {
                // Idempotent retry on same version
                return true;
            }
            throw new ConflictException("Đánh giá đã bị thay đổi hoặc đã được khôi phục.");
        }

        if (!actorId.equals(review.getUserId())) {
            throw new ForbiddenException("Bạn không có quyền xóa đánh giá của người khác.");
        }

        checkPublishedMovie(review.getMovieId());

        if (version == null || !version.equals(review.getVersion())) {
            throw new ConflictException("Đánh giá đã được chỉnh sửa ở phiên khác. Vui lòng tải lại trang.");
        }

        Instant now = Instant.now(clock);
        review.setDeletedAt(now);
        review.setUpdatedAt(now);

        reviewDAO.save(review);
        return true;
    }

    // ---------------------------------------------------------------- query methods

    /**
     * Gets user's active review for a movie, or empty if not reviewed/deleted.
     */
    public Optional<ReviewItem> getUserReview(Long userId, Long movieId) {
        if (userId == null || movieId == null) {
            return Optional.empty();
        }
        return reviewDAO.findUserReviewItem(userId, movieId);
    }

    /**
     * Paginated list of public approved reviews for a published movie (10/page).
     */
    public ReviewPage getPublicReviews(Long movieId, int page) {
        if (movieId == null) {
            return new ReviewPage(Collections.emptyList(), 1, PAGE_SIZE, 0L);
        }
        Movie movie = movieDAO.findPublishedById(movieId);
        if (movie == null) {
            return new ReviewPage(Collections.emptyList(), 1, PAGE_SIZE, 0L);
        }

        int targetPage = Math.max(1, page);
        long totalCount = reviewDAO.countPublicReviews(movieId);
        if (totalCount == 0) {
            return new ReviewPage(Collections.emptyList(), targetPage, PAGE_SIZE, 0L);
        }

        List<ReviewItem> items = reviewDAO.findPublicReviews(movieId, targetPage, PAGE_SIZE);
        return new ReviewPage(items, targetPage, PAGE_SIZE, totalCount);
    }

    /**
     * Returns {average, count} of public reviews.
     * Average rounded to 1 decimal place HALF_UP, or null when count is 0.
     */
    public Object[] getPublicRatingSummary(Long movieId) {
        if (movieId == null) {
            return new Object[]{null, 0L};
        }
        Movie movie = movieDAO.findPublishedById(movieId);
        if (movie == null) {
            return new Object[]{null, 0L};
        }

        Object[] summary = reviewDAO.findRatingSummary(movieId);
        Double rawAvg = (Double) summary[0];
        Long count = (Long) summary[1];

        if (count == null || count == 0L || rawAvg == null) {
            return new Object[]{null, 0L};
        }

        double rounded = BigDecimal.valueOf(rawAvg)
                .setScale(1, RoundingMode.HALF_UP)
                .doubleValue();
        return new Object[]{rounded, count};
    }
}
