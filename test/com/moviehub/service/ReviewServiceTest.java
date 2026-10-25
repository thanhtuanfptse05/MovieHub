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
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit tests for 005-reviews-rating module (ReviewService).
 * Enforces EARS criteria REV-AC-01 through REV-AC-11 and success criteria REV-SC-01 through REV-SC-05.
 */
public class ReviewServiceTest {

    private StubReviewDAO reviewDAO;
    private StubMovieDAO movieDAO;
    private StubUserDAO userDAO;
    private ReviewService service;
    private Instant fixedNow;

    @Before
    public void setUp() {
        reviewDAO = new StubReviewDAO();
        movieDAO = new StubMovieDAO();
        userDAO = new StubUserDAO();
        fixedNow = Instant.parse("2026-10-26T00:00:00Z");
        Clock clock = Clock.fixed(fixedNow, ZoneId.of("UTC"));

        service = new ReviewService(reviewDAO, movieDAO, userDAO, clock);

        // Seed users
        User u1 = createUser(100L, "Nguyễn Văn A", "a@example.com", User.STATUS_ACTIVE);
        User u2 = createUser(200L, "Trần Thị B", "b@example.com", User.STATUS_ACTIVE);
        User uInactive = createUser(300L, "Banned User", "banned@example.com", User.STATUS_INACTIVE);

        userDAO.saveUser(u1);
        userDAO.saveUser(u2);
        userDAO.saveUser(uInactive);

        // Seed movies
        Movie m1 = createMovie(1L, "Inception", Movie.STATUS_PUBLISHED);
        Movie mHidden = createMovie(2L, "Hidden Movie", Movie.STATUS_HIDDEN);
        Movie mDraft = createMovie(3L, "Draft Movie", Movie.STATUS_DRAFT);

        movieDAO.saveMovie(m1);
        movieDAO.saveMovie(mHidden);
        movieDAO.saveMovie(mDraft);
    }

    private User createUser(Long id, String name, String email, String status) {
        User u = new User();
        u.setId(id);
        u.setFullName(name);
        u.setEmail(email);
        u.setStatus(status);
        u.setRole(User.ROLE_USER);
        return u;
    }

    private Movie createMovie(Long id, String title, String status) {
        Movie m = new Movie();
        m.setId(id);
        m.setTitle(title);
        m.setStatus(status);
        m.setReleaseYear(2022);
        return m;
    }

    // ---------------------------------------------------------------- validation (REV-AC-01)

    @Test(expected = IllegalArgumentException.class)
    public void createReview_NullContent_ThrowsIllegalArgument() {
        service.createReview(100L, 1L, 5, null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void createReview_BlankContent_ThrowsIllegalArgument() {
        service.createReview(100L, 1L, 5, "   ");
    }

    @Test(expected = IllegalArgumentException.class)
    public void createReview_ContentExceeds1000Chars_ThrowsIllegalArgument() {
        String longText = "a".repeat(1001);
        service.createReview(100L, 1L, 5, longText);
    }

    @Test(expected = IllegalArgumentException.class)
    public void createReview_RatingZero_ThrowsIllegalArgument() {
        service.createReview(100L, 1L, 0, "Nội dung hợp lệ");
    }

    @Test(expected = IllegalArgumentException.class)
    public void createReview_RatingSix_ThrowsIllegalArgument() {
        service.createReview(100L, 1L, 6, "Nội dung hợp lệ");
    }

    @Test(expected = IllegalArgumentException.class)
    public void createReview_RatingNull_ThrowsIllegalArgument() {
        service.createReview(100L, 1L, null, "Nội dung hợp lệ");
    }

    // ---------------------------------------------------------------- create lifecycle (REV-AC-02, REV-AC-03, REV-AC-10)

    @Test
    public void createReview_Success_SetsPendingAndReturnsReview() {
        Review r = service.createReview(100L, 1L, 5, "Phim rất hay và sâu sắc!");
        assertNotNull(r.getId());
        assertEquals(Long.valueOf(100L), r.getUserId());
        assertEquals(Long.valueOf(1L), r.getMovieId());
        assertEquals(Integer.valueOf(5), r.getRating());
        assertEquals("Phim rất hay và sâu sắc!", r.getContent());
        assertEquals(Review.STATUS_PENDING, r.getStatus());
        assertNull(r.getModeratedBy());
        assertNull(r.getModeratedAt());
        assertNull(r.getDeletedAt());
        assertEquals(Integer.valueOf(1), r.getVersion());
        assertEquals(Integer.valueOf(1), r.getContentRevision());
        assertEquals(fixedNow, r.getCreatedAt());
        assertEquals(fixedNow, r.getUpdatedAt());
    }

    @Test(expected = ForbiddenException.class)
    public void createReview_InactiveUser_ThrowsForbidden() {
        service.createReview(300L, 1L, 5, "Bình luận từ tài khoản khóa");
    }

    @Test(expected = NotFoundException.class)
    public void createReview_UnpublishedMovie_ThrowsNotFound() {
        service.createReview(100L, 2L, 5, "Bình luận cho phim ẩn");
    }

    @Test(expected = NotFoundException.class)
    public void createReview_NonExistentMovie_ThrowsNotFound() {
        service.createReview(100L, 9999L, 5, "Bình luận cho phim không tồn tại");
    }

    @Test(expected = ConflictException.class)
    public void createReview_DuplicateActiveReview_ThrowsConflict409() {
        service.createReview(100L, 1L, 5, "Đánh giá lần 1");
        // Attempting to create again while active must fail with 409
        service.createReview(100L, 1L, 4, "Đánh giá lần 2");
    }

    @Test
    public void createReview_RestoresSoftDeletedReview_IncrementsRevisionAndSetsPending() {
        Review original = service.createReview(100L, 1L, 5, "Đánh giá ban đầu");
        // Soft delete original
        service.deleteReview(100L, original.getId(), original.getVersion());

        // Restore via create
        Review restored = service.createReview(100L, 1L, 4, "Đánh giá đã sửa lại sau khi xóa");
        assertEquals(original.getId(), restored.getId()); // Same row restored!
        assertNull(restored.getDeletedAt());
        assertEquals(Integer.valueOf(4), restored.getRating());
        assertEquals("Đánh giá đã sửa lại sau khi xóa", restored.getContent());
        assertEquals(Review.STATUS_PENDING, restored.getStatus());
        assertEquals(Integer.valueOf(3), restored.getVersion()); // 1 -> delete=2 -> restore=3
        assertEquals(Integer.valueOf(2), restored.getContentRevision()); // 1 -> restore=2
    }

    // ---------------------------------------------------------------- update lifecycle (REV-AC-04, REV-AC-05, REV-AC-09)

    @Test(expected = NotFoundException.class)
    public void updateReview_NonExistentReview_ThrowsNotFound() {
        service.updateReview(100L, 9999L, 1L, 1, 5, "Sửa đánh giá ảo");
    }

    @Test(expected = NotFoundException.class)
    public void updateReview_DeletedReview_ThrowsNotFound() {
        Review r = service.createReview(100L, 1L, 5, "Sắp bị xóa");
        service.deleteReview(100L, r.getId(), r.getVersion());

        service.updateReview(100L, r.getId(), 1L, r.getVersion() + 1, 4, "Cố sửa review đã xóa");
    }

    @Test(expected = ForbiddenException.class)
    public void updateReview_OtherUserReview_ThrowsForbidden403() {
        Review r = service.createReview(100L, 1L, 5, "Đánh giá của U1");
        // U2 attempts to edit U1's review
        service.updateReview(200L, r.getId(), 1L, r.getVersion(), 3, "U2 sửa bài U1");
    }

    @Test(expected = IllegalArgumentException.class)
    public void updateReview_MovieIdMismatch_ThrowsIllegalArgument() {
        Review r = service.createReview(100L, 1L, 5, "Đánh giá phim 1");
        // Submitting update with different movieId
        service.updateReview(100L, r.getId(), 2L, r.getVersion(), 4, "Sửa sai movieId");
    }

    @Test(expected = ConflictException.class)
    public void updateReview_StaleVersion_ThrowsConflict409() {
        Review r = service.createReview(100L, 1L, 5, "Đánh giá ban đầu");
        // Passing wrong version (e.g. 99 instead of 1)
        service.updateReview(100L, r.getId(), 1L, 99, 4, "Sửa với stale version");
    }

    @Test
    public void updateReview_IdenticalContentAndRating_NoOp_RetainsApproved() {
        Review r = service.createReview(100L, 1L, 5, "Nội dung chuẩn");
        // Simulate admin approval directly on stored entity
        r.setStatus(Review.STATUS_APPROVED);
        r.setModeratedBy(999L);
        r.setModeratedAt(fixedNow);

        // Submit identical rating and content
        Review updated = service.updateReview(100L, r.getId(), 1L, r.getVersion(), 5, "Nội dung chuẩn");
        assertEquals(Review.STATUS_APPROVED, updated.getStatus());
        assertEquals(Integer.valueOf(1), updated.getVersion());
        assertEquals(Integer.valueOf(1), updated.getContentRevision());
        assertNotNull(updated.getModeratedBy());
    }

    @Test
    public void updateReview_ModifiedContent_ResetsToPendingAndIncrementsRevision() {
        Review r = service.createReview(100L, 1L, 5, "Nội dung cũ");
        r.setStatus(Review.STATUS_APPROVED);
        r.setModeratedBy(999L);
        r.setModeratedAt(fixedNow);

        Review updated = service.updateReview(100L, r.getId(), 1L, r.getVersion(), 5, "Nội dung mới đã sửa!");
        assertEquals(Review.STATUS_PENDING, updated.getStatus());
        assertNull(updated.getModeratedBy());
        assertNull(updated.getModeratedAt());
        assertEquals(Integer.valueOf(2), updated.getVersion());
        assertEquals(Integer.valueOf(2), updated.getContentRevision());
    }

    @Test
    public void updateReview_ModifiedRating_ResetsToPendingAndIncrementsRevision() {
        Review r = service.createReview(100L, 1L, 5, "Nội dung giữ nguyên");
        r.setStatus(Review.STATUS_APPROVED);

        Review updated = service.updateReview(100L, r.getId(), 1L, r.getVersion(), 4, "Nội dung giữ nguyên");
        assertEquals(Review.STATUS_PENDING, updated.getStatus());
        assertEquals(Integer.valueOf(4), updated.getRating());
        assertEquals(Integer.valueOf(2), updated.getVersion());
    }

    @Test
    public void updateReview_ResubmitRejectedReview_ResetsToPendingEvenIfIdentical() {
        Review r = service.createReview(100L, 1L, 5, "Nội dung bị từ chối");
        r.setStatus(Review.STATUS_REJECTED);
        r.setModeratedBy(999L);
        r.setModeratedAt(fixedNow);

        // Resubmit rejected review with same content
        Review updated = service.updateReview(100L, r.getId(), 1L, r.getVersion(), 5, "Nội dung bị từ chối");
        assertEquals(Review.STATUS_PENDING, updated.getStatus());
        assertNull(updated.getModeratedBy());
        assertNull(updated.getModeratedAt());
        assertEquals(Integer.valueOf(2), updated.getVersion());
        assertEquals(Integer.valueOf(2), updated.getContentRevision());
    }

    // ---------------------------------------------------------------- delete lifecycle (REV-AC-05, REV-AC-06, REV-AC-09)

    @Test(expected = NotFoundException.class)
    public void deleteReview_NonExistentReview_ThrowsNotFound() {
        service.deleteReview(100L, 9999L, 1);
    }

    @Test(expected = ForbiddenException.class)
    public void deleteReview_OtherUserReview_ThrowsForbidden403() {
        Review r = service.createReview(100L, 1L, 5, "Đánh giá của U1");
        service.deleteReview(200L, r.getId(), r.getVersion());
    }

    @Test(expected = ConflictException.class)
    public void deleteReview_StaleVersion_ThrowsConflict409() {
        Review r = service.createReview(100L, 1L, 5, "Đánh giá của U1");
        service.deleteReview(100L, r.getId(), 99);
    }

    @Test
    public void deleteReview_Success_SetsDeletedAtAndIncrementsVersion() {
        Review r = service.createReview(100L, 1L, 5, "Sắp bị xóa");
        boolean ok = service.deleteReview(100L, r.getId(), r.getVersion());
        assertTrue(ok);

        Review stored = reviewDAO.findById(r.getId()).orElse(null);
        assertNotNull(stored);
        assertNotNull(stored.getDeletedAt());
        assertEquals(Integer.valueOf(2), stored.getVersion());
    }

    @Test
    public void deleteReview_IdempotentRetrySameVersion_ReturnsTrue() {
        Review r = service.createReview(100L, 1L, 5, "Sắp bị xóa");
        service.deleteReview(100L, r.getId(), 1); // Version increments to 2

        // Retrying delete with version 2 (the deleted version)
        boolean retryOk = service.deleteReview(100L, r.getId(), 2);
        assertTrue(retryOk);
    }

    @Test(expected = ConflictException.class)
    public void deleteReview_RetryStaleVersionAfterRestore_ThrowsConflict409() {
        Review r = service.createReview(100L, 1L, 5, "Sắp bị xóa");
        service.deleteReview(100L, r.getId(), 1); // Version becomes 2, deletedAt != null
        // Restored
        service.createReview(100L, 1L, 4, "Khôi phục lại"); // Version becomes 3, deletedAt == null

        // Old delete form with version 2 submits
        service.deleteReview(100L, r.getId(), 2);
    }

    // ---------------------------------------------------------------- rating calculations & pagination (REV-AC-07, REV-US-03)

    @Test
    public void getPublicRatingSummary_ZeroReviews_ReturnsNullAndZero() {
        Object[] summary = service.getPublicRatingSummary(1L);
        assertNull(summary[0]);
        assertEquals(0L, summary[1]);
    }

    @Test
    public void getPublicRatingSummary_CalculatesAverage_RoundsHalfUpToOneDecimal() {
        // Given two review APPROVED điểm 5 và 4, một PENDING điểm 1 (REV-US-03)
        Review r1 = service.createReview(100L, 1L, 5, "Review 5 sao");
        r1.setStatus(Review.STATUS_APPROVED);
        reviewDAO.save(r1);

        Review r2 = service.createReview(200L, 1L, 4, "Review 4 sao");
        r2.setStatus(Review.STATUS_APPROVED);
        reviewDAO.save(r2);

        // U3 writes pending review
        User u3 = createUser(301L, "User 3", "u3@example.com", User.STATUS_ACTIVE);
        userDAO.saveUser(u3);
        Review r3 = service.createReview(301L, 1L, 1, "Review 1 sao PENDING");
        // r3 remains PENDING

        // Public rating summary must only include r1 (5) and r2 (4) -> avg = 4.5, count = 2
        Object[] summary = service.getPublicRatingSummary(1L);
        assertEquals(4.5, (Double) summary[0], 0.001);
        assertEquals(2L, summary[1]);

        // When review 5 is deleted -> avg = 4.0, count = 1
        service.deleteReview(100L, r1.getId(), r1.getVersion());
        Object[] summaryAfterDelete = service.getPublicRatingSummary(1L);
        assertEquals(4.0, (Double) summaryAfterDelete[0], 0.001);
        assertEquals(1L, summaryAfterDelete[1]);
    }

    @Test
    public void getPublicReviews_PaginatesTenPerPage_ExcludesPendingAndDeleted() {
        // Create 15 approved reviews
        for (int i = 1; i <= 15; i++) {
            long uid = 1000L + i;
            User u = createUser(uid, "User " + i, "user" + i + "@example.com", User.STATUS_ACTIVE);
            userDAO.saveUser(u);

            Review r = service.createReview(uid, 1L, 5, "Đánh giá thứ " + i);
            r.setStatus(Review.STATUS_APPROVED);
            reviewDAO.save(r);
        }

        // Add 1 pending review
        User uPending = createUser(2000L, "Pending User", "pending@example.com", User.STATUS_ACTIVE);
        userDAO.saveUser(uPending);
        service.createReview(2000L, 1L, 2, "Đang chờ duyệt");

        ReviewPage page1 = service.getPublicReviews(1L, 1);
        assertEquals(1, page1.getPage());
        assertEquals(10, page1.getItems().size());
        assertEquals(15L, page1.getTotalCount());
        assertEquals(2, page1.getTotalPages());
        assertTrue(page1.hasNext());
        assertFalse(page1.hasPrevious());

        ReviewPage page2 = service.getPublicReviews(1L, 2);
        assertEquals(2, page2.getPage());
        assertEquals(5, page2.getItems().size());
        assertFalse(page2.hasNext());
        assertTrue(page2.hasPrevious());
    }

    @Test
    public void getUserReview_ReturnsUserActiveReviewRegardlessOfStatus() {
        Review r = service.createReview(100L, 1L, 5, "Đánh giá của tôi");
        // When PENDING
        Optional<ReviewItem> itemOpt = service.getUserReview(100L, 1L);
        assertTrue(itemOpt.isPresent());
        assertEquals(Review.STATUS_PENDING, itemOpt.get().getStatus());
        assertEquals("Chờ duyệt", itemOpt.get().getStatusBadge());

        // When soft-deleted -> empty
        service.deleteReview(100L, r.getId(), r.getVersion());
        Optional<ReviewItem> deletedOpt = service.getUserReview(100L, 1L);
        assertFalse(deletedOpt.isPresent());
    }

    // ---------------------------------------------------------------- Stub DAOs

    static class StubReviewDAO extends ReviewDAO {
        private final Map<Long, Review> store = new HashMap<>();
        private final AtomicLong idGen = new AtomicLong(100);

        @Override
        public Optional<Review> findById(Long id) {
            if (id == null) return Optional.empty();
            return Optional.ofNullable(store.get(id));
        }

        @Override
        public Optional<Review> findByUserAndMovie(Long userId, Long movieId) {
            for (Review r : store.values()) {
                if (r.getUserId().equals(userId) && r.getMovieId().equals(movieId)) {
                    return Optional.of(r);
                }
            }
            return Optional.empty();
        }

        @Override
        public Optional<ReviewItem> findUserReviewItem(Long userId, Long movieId) {
            for (Review r : store.values()) {
                if (r.getUserId().equals(userId) && r.getMovieId().equals(movieId) && r.isActive()) {
                    return Optional.of(new ReviewItem(
                            r.getId(), r.getUserId(), r.getMovieId(), "Author", null,
                            r.getRating(), r.getContent(), r.getStatus(), r.getCreatedAt(), r.getUpdatedAt(), r.getVersion()
                    ));
                }
            }
            return Optional.empty();
        }

        @Override
        public Review save(Review r) {
            if (r.getId() == null) {
                r.setId(idGen.incrementAndGet());
                if (r.getVersion() == null) {
                    r.setVersion(1);
                }
            } else {
                r.setVersion(r.getVersion() + 1);
            }
            store.put(r.getId(), r);
            return r;
        }

        @Override
        public List<ReviewItem> findPublicReviews(Long movieId, int page, int pageSize) {
            List<Review> approved = new ArrayList<>();
            for (Review r : store.values()) {
                if (r.getMovieId().equals(movieId) && r.isApproved()) {
                    approved.add(r);
                }
            }
            approved.sort((a, b) -> {
                int cmp = b.getCreatedAt().compareTo(a.getCreatedAt());
                if (cmp != 0) return cmp;
                return b.getId().compareTo(a.getId());
            });

            int start = (page - 1) * pageSize;
            if (start >= approved.size()) {
                return Collections.emptyList();
            }
            int end = Math.min(start + pageSize, approved.size());
            List<ReviewItem> items = new ArrayList<>();
            for (Review r : approved.subList(start, end)) {
                items.add(new ReviewItem(
                        r.getId(), r.getUserId(), r.getMovieId(), "Author " + r.getUserId(), null,
                        r.getRating(), r.getContent(), r.getStatus(), r.getCreatedAt(), r.getUpdatedAt(), r.getVersion()
                ));
            }
            return items;
        }

        @Override
        public long countPublicReviews(Long movieId) {
            long count = 0;
            for (Review r : store.values()) {
                if (r.getMovieId().equals(movieId) && r.isApproved()) {
                    count++;
                }
            }
            return count;
        }

        @Override
        public Object[] findRatingSummary(Long movieId) {
            long count = 0;
            long sum = 0;
            for (Review r : store.values()) {
                if (r.getMovieId().equals(movieId) && r.isApproved()) {
                    count++;
                    sum += r.getRating();
                }
            }
            if (count == 0) {
                return new Object[]{null, 0L};
            }
            return new Object[]{(double) sum / count, count};
        }
    }

    static class StubMovieDAO extends MovieDAO {
        private final Map<Long, Movie> movies = new HashMap<>();

        public void saveMovie(Movie m) {
            movies.put(m.getId(), m);
        }

        @Override
        public Movie findPublishedById(Long id) {
            Movie m = movies.get(id);
            if (m != null && Movie.STATUS_PUBLISHED.equals(m.getStatus())) {
                return m;
            }
            return null;
        }
    }

    static class StubUserDAO extends UserDAO {
        private final Map<Long, User> users = new HashMap<>();

        public void saveUser(User u) {
            users.put(u.getId(), u);
        }

        @Override
        public Optional<User> findById(Long id) {
            return Optional.ofNullable(users.get(id));
        }
    }
}
