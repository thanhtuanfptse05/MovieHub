package com.moviehub.dao;

import com.moviehub.dto.QuestionItem;
import com.moviehub.entity.Question;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data access operations for Questions.
 */
public class QuestionDAO {

    public Optional<Question> findById(Long id) {
        if (id == null) {
            return Optional.empty();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Question q = em.find(Question.class, id);
            return Optional.ofNullable(q);
        } finally {
            em.close();
        }
    }

    public Question save(Question question) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Question merged = em.merge(question);
            tx.commit();
            return merged;
        } catch (jakarta.persistence.OptimisticLockException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw new com.moviehub.exception.ConflictException("Dữ liệu câu hỏi đã thay đổi. Vui lòng thử lại.");
        } catch (jakarta.persistence.RollbackException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            if (ex.getCause() instanceof jakarta.persistence.OptimisticLockException
                    || (ex.getCause() != null && ex.getCause().getClass().getName().contains("StaleObjectState"))) {
                throw new com.moviehub.exception.ConflictException("Dữ liệu câu hỏi đã thay đổi. Vui lòng thử lại.");
            }
            throw ex;
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            if (ex.getClass().getName().contains("StaleObjectState")) {
                throw new com.moviehub.exception.ConflictException("Dữ liệu câu hỏi đã thay đổi. Vui lòng thử lại.");
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    public List<QuestionItem> findPublicQuestions(Long movieId, int page, int pageSize) {
        if (movieId == null || page < 1 || pageSize < 1) {
            return new ArrayList<>();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> rows = em.createQuery(
                    "select q, u.fullName, u.avatarUrl, "
                    + "(select count(a.id) from Answer a where a.questionId = q.id and a.status = 'APPROVED') "
                    + "from Question q, User u, Movie m "
                    + "where q.userId = u.id and q.movieId = m.id "
                    + "and q.movieId = :movieId and q.status = 'APPROVED' and m.status = 'PUBLISHED' "
                    + "order by q.createdAt desc, q.id desc", Object[].class)
                    .setParameter("movieId", movieId)
                    .setFirstResult((page - 1) * pageSize)
                    .setMaxResults(pageSize)
                    .getResultList();

            List<QuestionItem> items = new ArrayList<>(rows.size());
            for (Object[] row : rows) {
                Question q = (Question) row[0];
                String authorName = (String) row[1];
                String authorAvatarUrl = (String) row[2];
                long answerCount = row[3] == null ? 0L : ((Number) row[3]).longValue();
                items.add(new QuestionItem(
                        q.getId(), q.getMovieId(), q.getUserId(), authorName, authorAvatarUrl,
                        q.getContent(), q.getStatus(), q.getCreatedAt(), answerCount
                ));
            }
            return items;
        } finally {
            em.close();
        }
    }

    public long countPublicQuestions(Long movieId) {
        if (movieId == null) {
            return 0L;
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                    "select count(q.id) from Question q, Movie m "
                    + "where q.movieId = m.id and q.movieId = :movieId and q.status = 'APPROVED' and m.status = 'PUBLISHED'", Long.class)
                    .setParameter("movieId", movieId)
                    .getSingleResult();
            return count != null ? count : 0L;
        } finally {
            em.close();
        }
    }

    public List<Question> findByUserIdAndMovieId(Long userId, Long movieId) {
        if (userId == null || movieId == null) {
            return new ArrayList<>();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "select q from Question q "
                    + "where q.userId = :userId and q.movieId = :movieId "
                    + "order by q.createdAt desc, q.id desc", Question.class)
                    .setParameter("userId", userId)
                    .setParameter("movieId", movieId)
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
