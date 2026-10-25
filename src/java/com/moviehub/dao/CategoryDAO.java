package com.moviehub.dao;

import com.moviehub.dto.CategoryOption;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import java.util.ArrayList;
import java.util.List;

/**
 * Read access to active (not soft-deleted) categories.
 */
public class CategoryDAO {

    public List<CategoryOption> findAllActive() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> rows = em.createQuery(
                    "select c.id, c.name from Category c where c.deletedAt is null order by c.name asc, c.id asc",
                    Object[].class).getResultList();
            List<CategoryOption> result = new ArrayList<>();
            for (Object[] row : rows) {
                result.add(new CategoryOption(((Number) row[0]).longValue(), (String) row[1]));
            }
            return result;
        } finally {
            em.close();
        }
    }

    public boolean existsActive(Long id) {
        if (id == null) {
            return false;
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                    "select count(c.id) from Category c where c.id = :id and c.deletedAt is null", Long.class)
                    .setParameter("id", id)
                    .getSingleResult();
            return count != null && count > 0;
        } finally {
            em.close();
        }
    }
}
