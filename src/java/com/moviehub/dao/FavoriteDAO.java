package com.moviehub.dao;

import com.moviehub.entity.Favorite;
import com.moviehub.entity.Movie;
import com.moviehub.entity.User;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

/**
 * Data access operations for user favorites.
 * Strictly uses parameterized JPQL and active transactions for mutating operations.
 */
public class FavoriteDAO {

    /**
     * Checks if user currently has an active (not soft-deleted) favorite for the movie.
     */
    public boolean isFavorited(Long userId, Long movieId) {
        if (userId == null || movieId == null) {
            return false;
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                    "select count(f.id) from Favorite f where f.user.id = :userId and f.movie.id = :movieId and f.deletedAt is null", Long.class)
                    .setParameter("userId", userId)
                    .setParameter("movieId", movieId)
                    .getSingleResult();
            return count != null && count > 0;
        } finally {
            em.close();
        }
    }

    /**
     * Finds existing favorite entry regardless of deleted_at status.
     */
    public Optional<Favorite> findByUserAndMovie(Long userId, Long movieId) {
        if (userId == null || movieId == null) {
            return Optional.empty();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Favorite> list = em.createQuery(
                    "select f from Favorite f where f.user.id = :userId and f.movie.id = :movieId", Favorite.class)
                    .setParameter("userId", userId)
                    .setParameter("movieId", movieId)
                    .getResultList();
            return list.isEmpty() ? Optional.empty() : Optional.of(list.get(0));
        } finally {
            em.close();
        }
    }

    /**
     * Adds favorite or restores a soft-deleted row (FAV-AC-03).
     * If already active, it is a no-op.
     */
    public void addOrRestore(Long userId, Long movieId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            List<Favorite> list = em.createQuery(
                    "select f from Favorite f where f.user.id = :userId and f.movie.id = :movieId", Favorite.class)
                    .setParameter("userId", userId)
                    .setParameter("movieId", movieId)
                    .getResultList();

            if (!list.isEmpty()) {
                Favorite existing = list.get(0);
                if (existing.getDeletedAt() != null) {
                    existing.setDeletedAt(null);
                    existing.setCreatedAt(Instant.now());
                    em.merge(existing);
                }
            } else {
                User userRef = em.getReference(User.class, userId);
                Movie movieRef = em.getReference(Movie.class, movieId);
                Favorite newFav = new Favorite(userRef, movieRef);
                em.persist(newFav);
            }
            tx.commit();
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    /**
     * Soft-removes favorite for given user and movie (FAV-AC-05).
     * If row is already soft-deleted or doesn't exist, it is a no-op.
     */
    public boolean softRemove(Long userId, Long movieId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            List<Favorite> list = em.createQuery(
                    "select f from Favorite f where f.user.id = :userId and f.movie.id = :movieId", Favorite.class)
                    .setParameter("userId", userId)
                    .setParameter("movieId", movieId)
                    .getResultList();

            boolean removed = false;
            if (!list.isEmpty()) {
                Favorite existing = list.get(0);
                if (existing.getDeletedAt() == null) {
                    existing.setDeletedAt(Instant.now());
                    em.merge(existing);
                    removed = true;
                }
            }
            tx.commit();
            return removed;
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    /**
     * Returns page of movie IDs from active favorites where the movie is currently PUBLISHED.
     * Ordered by f.createdAt desc, f.id desc.
     */
    public List<Long> findActiveMovieIdsByUser(Long userId, int offset, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                    "select f.movie.id from Favorite f join f.movie m"
                    + " where f.user.id = :userId and f.deletedAt is null"
                    + " and m.status = 'PUBLISHED'"
                    + " order by f.createdAt desc, f.id desc", Long.class)
                    .setParameter("userId", userId);
            query.setFirstResult(offset);
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Counts active favorites of the user where the movie is currently PUBLISHED.
     */
    public long countActiveByUser(Long userId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "select count(f.id) from Favorite f join f.movie m"
                    + " where f.user.id = :userId and f.deletedAt is null"
                    + " and m.status = 'PUBLISHED'", Long.class)
                    .setParameter("userId", userId)
                    .getSingleResult();
        } finally {
            em.close();
        }
    }
}
