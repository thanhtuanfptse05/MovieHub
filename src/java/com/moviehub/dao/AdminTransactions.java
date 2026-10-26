package com.moviehub.dao;

import com.moviehub.entity.User;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.ForbiddenException;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.LockModeType;
import jakarta.persistence.OptimisticLockException;
import java.util.List;
import java.util.function.Function;

/** Shared transaction boundary and stable row lock for administrative writes. */
public final class AdminTransactions {
    private AdminTransactions() { }

    public static <T> T read(Function<EntityManager,T> work) {
        EntityManager em = JPAUtil.getEntityManager();
        try { return work.apply(em); } finally { em.close(); }
    }

    public static <T> T write(Long actorId, Function<EntityManager,T> work) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            List<User> anchors = em.createQuery("select u from User u order by u.id", User.class)
                    .setMaxResults(1).setLockMode(LockModeType.PESSIMISTIC_WRITE).getResultList();
            if (anchors.isEmpty() || actorId == null) throw new ForbiddenException("Bạn không có quyền thực hiện thao tác này.");
            User actor = em.find(User.class, actorId);
            if (actor != null) em.refresh(actor);
            if (actor == null || !User.ROLE_ADMIN.equals(actor.getRole()) || !User.STATUS_ACTIVE.equals(actor.getStatus())) {
                throw new ForbiddenException("Bạn không có quyền thực hiện thao tác này.");
            }
            T result = work.apply(em);
            tx.commit();
            return result;
        } catch (RuntimeException ex) {
            if (tx.isActive()) tx.rollback();
            for (Throwable cause = ex; cause != null; cause = cause.getCause()) {
                if (cause instanceof OptimisticLockException || cause.getClass().getSimpleName().contains("StaleObject")) {
                    throw new ConflictException("Dữ liệu đã thay đổi. Vui lòng tải lại trang.");
                }
            }
            throw ex;
        } finally { em.close(); }
    }
}
