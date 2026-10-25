package com.moviehub.dao;

import com.moviehub.dto.AnswerItem;
import com.moviehub.entity.Answer;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data access operations for Answers.
 */
public class AnswerDAO {

    public Optional<Answer> findById(Long id) {
        if (id == null) {
            return Optional.empty();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Answer a = em.find(Answer.class, id);
            return Optional.ofNullable(a);
        } finally {
            em.close();
        }
    }

    public Answer save(Answer answer) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Answer merged = em.merge(answer);
            tx.commit();
            return merged;
        } catch (jakarta.persistence.OptimisticLockException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw new com.moviehub.exception.ConflictException("Dữ liệu câu trả lời đã thay đổi. Vui lòng thử lại.");
        } catch (jakarta.persistence.RollbackException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            if (ex.getCause() instanceof jakarta.persistence.OptimisticLockException
                    || (ex.getCause() != null && ex.getCause().getClass().getName().contains("StaleObjectState"))) {
                throw new com.moviehub.exception.ConflictException("Dữ liệu câu trả lời đã thay đổi. Vui lòng thử lại.");
            }
            throw ex;
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            if (ex.getClass().getName().contains("StaleObjectState")) {
                throw new com.moviehub.exception.ConflictException("Dữ liệu câu trả lời đã thay đổi. Vui lòng thử lại.");
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    public List<AnswerItem> findPublicAnswers(Long questionId, int page, int pageSize) {
        if (questionId == null || page < 1 || pageSize < 1) {
            return new ArrayList<>();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> rows = em.createQuery(
                    "select a, u.fullName, u.avatarUrl from Answer a, User u, Question q, Movie m "
                    + "where a.userId = u.id and a.questionId = q.id and q.movieId = m.id "
                    + "and a.questionId = :questionId and a.status = 'APPROVED' "
                    + "and q.status = 'APPROVED' and m.status = 'PUBLISHED' "
                    + "order by a.createdAt asc, a.id asc", Object[].class)
                    .setParameter("questionId", questionId)
                    .setFirstResult((page - 1) * pageSize)
                    .setMaxResults(pageSize)
                    .getResultList();

            List<AnswerItem> items = new ArrayList<>(rows.size());
            for (Object[] row : rows) {
                Answer a = (Answer) row[0];
                String authorName = (String) row[1];
                String authorAvatarUrl = (String) row[2];
                items.add(new AnswerItem(
                        a.getId(), a.getQuestionId(), a.getUserId(), authorName, authorAvatarUrl,
                        a.getContent(), a.getStatus(), a.getCreatedAt()
                ));
            }
            return items;
        } finally {
            em.close();
        }
    }

    public long countPublicAnswers(Long questionId) {
        if (questionId == null) {
            return 0L;
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                    "select count(a.id) from Answer a, Question q, Movie m "
                    + "where a.questionId = q.id and q.movieId = m.id "
                    + "and a.questionId = :questionId and a.status = 'APPROVED' "
                    + "and q.status = 'APPROVED' and m.status = 'PUBLISHED'", Long.class)
                    .setParameter("questionId", questionId)
                    .getSingleResult();
            return count != null ? count : 0L;
        } finally {
            em.close();
        }
    }

    public List<Object[]> findUserAnswersWithQuestion(Long userId, Long movieId) {
        if (userId == null || movieId == null) {
            return new ArrayList<>();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "select a, q from Answer a, Question q "
                    + "where a.questionId = q.id and a.userId = :userId and q.movieId = :movieId "
                    + "order by a.createdAt desc, a.id desc", Object[].class)
                    .setParameter("userId", userId)
                    .setParameter("movieId", movieId)
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
