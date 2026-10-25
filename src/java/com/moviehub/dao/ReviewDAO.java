package com.moviehub.dao;

import com.moviehub.dto.ReviewItem;
import com.moviehub.entity.Review;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data access operations for Movie Reviews and Ratings.
 * Adheres strictly to Layer 1-4 JPA transaction rules and Anti-Mojibake UTF-8 data safety.
 */
public class ReviewDAO {

    public Optional<Review> findById(Long id) {
        if (id == null) {
            return Optional.empty();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Review r = em.find(Review.class, id);
            return Optional.ofNullable(r);
        } finally {
            em.close();
        }
    }

    public Optional<Review> findByUserAndMovie(Long userId, Long movieId) {
        if (userId == null || movieId == null) {
            return Optional.empty();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Review> list = em.createQuery(
                    "select r from Review r where r.userId = :userId and r.movieId = :movieId", Review.class)
                    .setParameter("userId", userId)
                    .setParameter("movieId", movieId)
                    .getResultList();
            return list.isEmpty() ? Optional.empty() : Optional.of(list.get(0));
        } finally {
            em.close();
        }
    }

    public Optional<ReviewItem> findUserReviewItem(Long userId, Long movieId) {
        if (userId == null || movieId == null) {
            return Optional.empty();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> rows = em.createQuery(
                    "select r, u.fullName, u.avatarUrl from Review r, User u "
                    + "where r.userId = u.id and r.userId = :userId and r.movieId = :movieId and r.deletedAt is null", Object[].class)
                    .setParameter("userId", userId)
                    .setParameter("movieId", movieId)
                    .getResultList();
            if (rows.isEmpty()) {
                return Optional.empty();
            }
            Object[] row = rows.get(0);
            Review r = (Review) row[0];
            String authorName = (String) row[1];
            String authorAvatarUrl = (String) row[2];
            return Optional.of(new ReviewItem(
                    r.getId(), r.getUserId(), r.getMovieId(), authorName, authorAvatarUrl,
                    r.getRating(), r.getContent(), r.getStatus(), r.getCreatedAt(), r.getUpdatedAt(), r.getVersion()
            ));
        } finally {
            em.close();
        }
    }

    public Review save(Review review) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Review merged = em.merge(review);
            tx.commit();
            return merged;
        } catch (jakarta.persistence.OptimisticLockException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw new com.moviehub.exception.ConflictException("Đánh giá đã được chỉnh sửa ở phiên khác. Vui lòng tải lại trang.");
        } catch (jakarta.persistence.RollbackException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            if (ex.getCause() instanceof jakarta.persistence.OptimisticLockException
                    || (ex.getCause() != null && ex.getCause().getClass().getName().contains("StaleObjectState"))) {
                throw new com.moviehub.exception.ConflictException("Đánh giá đã được chỉnh sửa ở phiên khác. Vui lòng tải lại trang.");
            }
            throw ex;
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            if (ex.getClass().getName().contains("StaleObjectState")) {
                throw new com.moviehub.exception.ConflictException("Đánh giá đã được chỉnh sửa ở phiên khác. Vui lòng tải lại trang.");
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    public List<ReviewItem> findPublicReviews(Long movieId, int page, int pageSize) {
        if (movieId == null || page < 1 || pageSize < 1) {
            return new ArrayList<>();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> rows = em.createQuery(
                    "select r, u.fullName, u.avatarUrl from Review r, User u, Movie m "
                    + "where r.userId = u.id and r.movieId = m.id "
                    + "and r.movieId = :movieId and r.status = 'APPROVED' and r.deletedAt is null and m.status = 'PUBLISHED' "
                    + "order by r.createdAt desc, r.id desc", Object[].class)
                    .setParameter("movieId", movieId)
                    .setFirstResult((page - 1) * pageSize)
                    .setMaxResults(pageSize)
                    .getResultList();

            List<ReviewItem> items = new ArrayList<>(rows.size());
            for (Object[] row : rows) {
                Review r = (Review) row[0];
                String authorName = (String) row[1];
                String authorAvatarUrl = (String) row[2];
                items.add(new ReviewItem(
                        r.getId(), r.getUserId(), r.getMovieId(), authorName, authorAvatarUrl,
                        r.getRating(), r.getContent(), r.getStatus(), r.getCreatedAt(), r.getUpdatedAt(), r.getVersion()
                ));
            }
            return items;
        } finally {
            em.close();
        }
    }

    public long countPublicReviews(Long movieId) {
        if (movieId == null) {
            return 0L;
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                    "select count(r.id) from Review r, Movie m "
                    + "where r.movieId = m.id and r.movieId = :movieId and r.status = 'APPROVED' and r.deletedAt is null and m.status = 'PUBLISHED'", Long.class)
                    .setParameter("movieId", movieId)
                    .getSingleResult();
            return count != null ? count : 0L;
        } finally {
            em.close();
        }
    }

    public Object[] findRatingSummary(Long movieId) {
        if (movieId == null) {
            return new Object[]{null, 0L};
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Object[] row = em.createQuery(
                    "select avg(r.rating), count(r.id) from Review r, Movie m "
                    + "where r.movieId = m.id and r.movieId = :movieId and r.status = 'APPROVED' and r.deletedAt is null and m.status = 'PUBLISHED'", Object[].class)
                    .setParameter("movieId", movieId)
                    .getSingleResult();
            Double avg = row[0] == null ? null : ((Number) row[0]).doubleValue();
            Long count = row[1] == null ? 0L : ((Number) row[1]).longValue();
            return new Object[]{avg, count};
        } finally {
            em.close();
        }
    }
}
