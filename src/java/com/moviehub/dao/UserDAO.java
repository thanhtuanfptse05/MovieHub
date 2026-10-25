package com.moviehub.dao;

import com.moviehub.entity.User;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import java.time.Instant;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for User entity utilizing JPA EntityManager.
 * Enforces parameterized queries and active transaction management with rollback.
 */
public class UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public Optional<User> findById(Long id) {
        if (id == null) {
            return Optional.empty();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.find(User.class, id);
            return Optional.ofNullable(user);
        } finally {
            em.close();
        }
    }

    public Optional<User> findByEmail(String canonicalEmail) {
        if (canonicalEmail == null || canonicalEmail.trim().isEmpty()) {
            return Optional.empty();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<User> query = em.createNamedQuery("User.findByEmail", User.class);
            query.setParameter("email", canonicalEmail.trim().toLowerCase());
            User user = query.getSingleResult();
            return Optional.ofNullable(user);
        } catch (NoResultException ex) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    public boolean existsByEmail(String canonicalEmail) {
        if (canonicalEmail == null || canonicalEmail.trim().isEmpty()) {
            return false;
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<Long> query = em.createNamedQuery("User.countByEmail", Long.class);
            query.setParameter("email", canonicalEmail.trim().toLowerCase());
            Long count = query.getSingleResult();
            return count != null && count > 0;
        } finally {
            em.close();
        }
    }

    public User save(User user) {
        if (user == null) {
            throw new IllegalArgumentException("User entity cannot be null");
        }
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (user.getId() == null) {
                em.persist(user);
            } else {
                user = em.merge(user);
            }
            tx.commit();
            return user;
        } catch (Exception ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            LOGGER.log(Level.SEVERE, "Failed to save user: " + ex.getMessage(), ex);
            throw new RuntimeException("Error persisting user entity", ex);
        } finally {
            em.close();
        }
    }

    /**
     * Atomically updates password and increments credentialsVersion.
     * Guarantees that only one concurrent reset with expectedCredentialsVersion succeeds.
     *
     * @param userId user id
     * @param newPasswordHash new BCrypt password hash
     * @param expectedCredentialsVersion credentialsVersion expected at read time
     * @return true if updated successfully, false if credentialsVersion or status mismatched
     */
    public boolean updatePasswordAndIncrementCredentials(Long userId, String newPasswordHash, int expectedCredentialsVersion) {
        if (userId == null || newPasswordHash == null) {
            return false;
        }
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            int updatedRows = em.createQuery(
                "UPDATE User u SET u.passwordHash = :hash, u.credentialsVersion = u.credentialsVersion + 1, u.updatedAt = :now " +
                "WHERE u.id = :id AND u.credentialsVersion = :expectedVersion AND u.status = :status"
            )
            .setParameter("hash", newPasswordHash)
            .setParameter("now", Instant.now())
            .setParameter("id", userId)
            .setParameter("expectedVersion", expectedCredentialsVersion)
            .setParameter("status", User.STATUS_ACTIVE)
            .executeUpdate();

            tx.commit();
            return updatedRows == 1;
        } catch (Exception ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            LOGGER.log(Level.SEVERE, "Failed atomic password reset for user ID " + userId + ": " + ex.getMessage(), ex);
            throw new RuntimeException("Error executing atomic password update", ex);
        } finally {
            em.close();
        }
    }
}
