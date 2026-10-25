package com.moviehub.dao;

import com.moviehub.dto.AdminDashboardDTO;
import com.moviehub.dto.CategoryStatDTO;
import com.moviehub.dto.TopMovieDTO;
import com.moviehub.entity.Category;
import com.moviehub.entity.Movie;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for Admin Analytics and Dashboard metrics (008-admin-analytics).
 * Executes optimized JPQL aggregate queries for KPI-01 through KPI-09 and P1 category statistics.
 */
public class AnalyticsDAO {

    /**
     * Executes all analytics calculations in a single read snapshot to ensure consistency (ANA-AC-09).
     */
    public AdminDashboardDTO fetchDashboardMetrics() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return fetchDashboardMetrics(em);
        } finally {
            em.close();
        }
    }

    /**
     * Overloaded method accepting an active EntityManager for transactional consistency and testability.
     */
    public AdminDashboardDTO fetchDashboardMetrics(EntityManager em) {
        AdminDashboardDTO dto = new AdminDashboardDTO();

        // KPI-01: Tổng phim (mọi trạng thái: DRAFT, PUBLISHED, HIDDEN)
        dto.setTotalMovies(countTotalMovies(em));

        // KPI-02: Phim đang công khai
        dto.setPublishedMovies(countPublishedMovies(em));

        // KPI-03: Người dùng role USER
        dto.setTotalUsers(countTotalUsers(em));

        // KPI-04: Tổng review chưa bị xóa mềm
        dto.setTotalReviews(countTotalReviews(em));

        // KPI-05: Tổng lượt mở chi tiết, mọi phim
        dto.setTotalViews(sumTotalViews(em));

        // KPI-06: Lượt xem cao nhất / thấp nhất
        dto.setMaxViews(findMaxViews(em));
        dto.setMinViews(findMinViews(em));

        // KPI-07: Điểm TB review đã duyệt, mọi phim
        dto.setAverageRating(findAverageApprovedRating(em));

        // KPI-08: Nội dung chờ duyệt
        long pendingReviews = countPendingReviews(em);
        long pendingQuestions = countPendingQuestions(em);
        long pendingAnswers = countPendingAnswers(em);
        dto.setPendingReviews(pendingReviews);
        dto.setPendingQuestions(pendingQuestions);
        dto.setPendingAnswers(pendingAnswers);
        dto.setTotalPending(pendingReviews + pendingQuestions + pendingAnswers);

        // KPI-09: Top 5 phim theo lượt xem
        dto.setTopMovies(findTop5ViewedMovies(em));

        // P1 FR-26: Phân bố số phim PUBLISHED theo từng thể loại
        dto.setCategoryStats(findCategoryStats(em));

        return dto;
    }

    public long countTotalMovies(EntityManager em) {
        Long count = em.createQuery("SELECT count(m.id) FROM Movie m", Long.class)
                .getSingleResult();
        return count != null ? count : 0L;
    }

    public long countPublishedMovies(EntityManager em) {
        Long count = em.createQuery("SELECT count(m.id) FROM Movie m WHERE m.status = 'PUBLISHED'", Long.class)
                .getSingleResult();
        return count != null ? count : 0L;
    }

    public long countTotalUsers(EntityManager em) {
        Long count = em.createQuery("SELECT count(u.id) FROM User u WHERE u.role = 'USER'", Long.class)
                .getSingleResult();
        return count != null ? count : 0L;
    }

    public long countTotalReviews(EntityManager em) {
        Long count = em.createQuery("SELECT count(r.id) FROM Review r WHERE r.deletedAt IS NULL", Long.class)
                .getSingleResult();
        return count != null ? count : 0L;
    }

    public long sumTotalViews(EntityManager em) {
        Number sum = em.createQuery("SELECT coalesce(sum(m.viewCount), 0) FROM Movie m", Number.class)
                .getSingleResult();
        return sum != null ? sum.longValue() : 0L;
    }

    public Long findMaxViews(EntityManager em) {
        Number max = em.createQuery("SELECT max(m.viewCount) FROM Movie m", Number.class)
                .getSingleResult();
        return max != null ? max.longValue() : null;
    }

    public Long findMinViews(EntityManager em) {
        Number min = em.createQuery("SELECT min(m.viewCount) FROM Movie m", Number.class)
                .getSingleResult();
        return min != null ? min.longValue() : null;
    }

    public Double findAverageApprovedRating(EntityManager em) {
        Number avg = em.createQuery(
                "SELECT avg(r.rating) FROM Review r WHERE r.status = 'APPROVED' AND r.deletedAt IS NULL", Number.class)
                .getSingleResult();
        return avg != null ? avg.doubleValue() : null;
    }

    public long countPendingReviews(EntityManager em) {
        Long count = em.createQuery(
                "SELECT count(r.id) FROM Review r WHERE r.status = 'PENDING' AND r.deletedAt IS NULL", Long.class)
                .getSingleResult();
        return count != null ? count : 0L;
    }

    public long countPendingQuestions(EntityManager em) {
        Long count = em.createQuery(
                "SELECT count(q.id) FROM Question q WHERE q.status = 'PENDING'", Long.class)
                .getSingleResult();
        return count != null ? count : 0L;
    }

    public long countPendingAnswers(EntityManager em) {
        Long count = em.createQuery(
                "SELECT count(a.id) FROM Answer a WHERE a.status = 'PENDING'", Long.class)
                .getSingleResult();
        return count != null ? count : 0L;
    }

    public List<TopMovieDTO> findTop5ViewedMovies(EntityManager em) {
        List<Movie> list = em.createQuery(
                "SELECT m FROM Movie m ORDER BY m.viewCount DESC, m.id DESC", Movie.class)
                .setMaxResults(5)
                .getResultList();

        List<TopMovieDTO> result = new ArrayList<>();
        for (Movie m : list) {
            result.add(new TopMovieDTO(m.getId(), m.getTitle(), m.getReleaseYear(), m.getStatus(), m.getViewCount()));
        }
        return result;
    }

    public List<CategoryStatDTO> findCategoryStats(EntityManager em) {
        // 1. Get all active categories
        List<Category> categories = em.createQuery(
                "SELECT c FROM Category c WHERE c.deletedAt IS NULL ORDER BY c.name ASC, c.id ASC", Category.class)
                .getResultList();

        // 2. Count distinct published movies per category
        List<Object[]> rows = em.createQuery(
                "SELECT c.id, count(distinct m.id) FROM Movie m JOIN m.categories c " +
                "WHERE m.status = 'PUBLISHED' AND c.deletedAt IS NULL " +
                "GROUP BY c.id", Object[].class)
                .getResultList();

        Map<Long, Long> countMap = new HashMap<>();
        for (Object[] row : rows) {
            Long catId = ((Number) row[0]).longValue();
            Long count = ((Number) row[1]).longValue();
            countMap.put(catId, count);
        }

        List<CategoryStatDTO> result = new ArrayList<>();
        for (Category c : categories) {
            long count = countMap.getOrDefault(c.getId(), 0L);
            result.add(new CategoryStatDTO(c.getId(), c.getName(), count));
        }

        // Sort by movieCount DESC, name ASC, id ASC
        result.sort((a, b) -> {
            int cmp = Long.compare(b.getMovieCount(), a.getMovieCount());
            if (cmp != 0) {
                return cmp;
            }
            cmp = a.getName().compareToIgnoreCase(b.getName());
            if (cmp != 0) {
                return cmp;
            }
            return Long.compare(a.getCategoryId(), b.getCategoryId());
        });

        return result;
    }
}
