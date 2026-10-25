package com.moviehub.dao;

import com.moviehub.dto.CategoryOption;
import com.moviehub.dto.MovieCard;
import com.moviehub.entity.Movie;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Read-side data access for the public movie catalog. Every query is parameterized JPQL and
 * every public query is restricted to status PUBLISHED. Sorting uses a fixed whitelist.
 */
public class MovieDAO {

    public static final String SORT_NEWEST = "newest";
    public static final String SORT_VIEWS = "views";
    public static final String SORT_RATING = "rating";
    public static final String SORT_TITLE = "title";

    private static final String REVIEW_JOIN =
            " left join Review r on r.movieId = m.id and r.status = 'APPROVED' and r.deletedAt is null";

    /** Escape char used in LIKE patterns; also escapes SQL Server's '[' wildcard. */
    public static final char LIKE_ESCAPE = '!';

    public static String toLikePattern(String lowerCaseTerm) {
        StringBuilder sb = new StringBuilder("%");
        for (int i = 0; i < lowerCaseTerm.length(); i++) {
            char ch = lowerCaseTerm.charAt(i);
            if (ch == '%' || ch == '_' || ch == '[' || ch == LIKE_ESCAPE) {
                sb.append(LIKE_ESCAPE);
            }
            sb.append(ch);
        }
        return sb.append('%').toString();
    }

    private static String whereClause(String likePattern, Long categoryId, Integer year) {
        StringBuilder where = new StringBuilder(" where m.status = 'PUBLISHED'");
        if (likePattern != null) {
            where.append(" and lower(m.title) like :pattern escape '").append(LIKE_ESCAPE).append("'");
        }
        if (categoryId != null) {
            where.append(" and m.id in (select m2.id from Movie m2 join m2.categories c2")
                    .append(" where c2.id = :categoryId and c2.deletedAt is null)");
        }
        if (year != null) {
            where.append(" and m.releaseYear = :year");
        }
        return where.toString();
    }

    private static void bind(Query query, String likePattern, Long categoryId, Integer year) {
        if (likePattern != null) {
            query.setParameter("pattern", likePattern);
        }
        if (categoryId != null) {
            query.setParameter("categoryId", categoryId);
        }
        if (year != null) {
            query.setParameter("year", year);
        }
    }

    /** Count of DISTINCT public movies matching the filter. */
    public long countFiltered(String likePattern, Long categoryId, Integer year) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                    "select count(m.id) from Movie m" + whereClause(likePattern, categoryId, year), Long.class);
            bind(query, likePattern, categoryId, year);
            return query.getSingleResult();
        } finally {
            em.close();
        }
    }

    /** One page of ids in stable, whitelist-driven order. */
    public List<Long> findFilteredIds(String likePattern, Long categoryId, Integer year,
                                      String sort, int offset, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("select m.id from Movie m");
            String orderBy;
            if (SORT_RATING.equals(sort)) {
                jpql.append(REVIEW_JOIN);
                jpql.append(whereClause(likePattern, categoryId, year));
                jpql.append(" group by m.id");
                orderBy = " order by case when count(r.id) = 0 then 1 else 0 end,"
                        + " avg(r.rating) desc, count(r.id) desc, m.id desc";
            } else {
                jpql.append(whereClause(likePattern, categoryId, year));
                orderBy = orderByFor(sort);
            }
            jpql.append(orderBy);
            TypedQuery<Long> query = em.createQuery(jpql.toString(), Long.class);
            bind(query, likePattern, categoryId, year);
            query.setFirstResult(offset);
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    private static String orderByFor(String sort) {
        if (SORT_VIEWS.equals(sort)) {
            return " order by m.viewCount desc, m.id desc";
        }
        if (SORT_TITLE.equals(sort)) {
            return " order by m.title asc, m.id asc";
        }
        return " order by m.updatedAt desc, m.id desc";
    }

    /** Featured movie ids (public, featured=true), newest first. */
    public List<Long> findFeaturedIds(int limit) {
        return singleListQuery("select m.id from Movie m where m.status = 'PUBLISHED' and m.featured = true"
                + " order by m.updatedAt desc, m.id desc", limit);
    }

    public List<Long> findNewestIds(int limit) {
        return singleListQuery("select m.id from Movie m where m.status = 'PUBLISHED'"
                + " order by m.updatedAt desc, m.id desc", limit);
    }

    public List<Long> findMostViewedIds(int limit) {
        return singleListQuery("select m.id from Movie m where m.status = 'PUBLISHED'"
                + " order by m.viewCount desc, m.id desc", limit);
    }

    /** Public movies with at least one public review, best average first. */
    public List<Long> findTopRatedIds(int limit) {
        return singleListQuery("select m.id from Movie m" + REVIEW_JOIN
                + " where m.status = 'PUBLISHED' group by m.id having count(r.id) >= 1"
                + " order by avg(r.rating) desc, count(r.id) desc, m.id desc", limit);
    }

    private List<Long> singleListQuery(String jpql, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(jpql, Long.class);
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /** Cards for the given ids, returned in the same order as {@code ids}; non-public ids are dropped. */
    public List<MovieCard> findCardsByIds(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<Object[]> query = em.createQuery(
                    "select m.id, m.title, m.releaseYear, m.posterUrl, m.viewCount, avg(r.rating), count(r.id)"
                    + " from Movie m" + REVIEW_JOIN
                    + " where m.status = 'PUBLISHED' and m.id in :ids"
                    + " group by m.id, m.title, m.releaseYear, m.posterUrl, m.viewCount", Object[].class);
            query.setParameter("ids", ids);
            Map<Long, MovieCard> byId = new HashMap<>();
            for (Object[] row : query.getResultList()) {
                Long id = ((Number) row[0]).longValue();
                Double avg = row[5] == null ? null : ((Number) row[5]).doubleValue();
                long count = row[6] == null ? 0L : ((Number) row[6]).longValue();
                byId.put(id, new MovieCard(id, (String) row[1], (Integer) row[2], (String) row[3],
                        ((Number) row[4]).longValue(), avg, count));
            }
            List<MovieCard> ordered = new ArrayList<>(ids.size());
            for (Long id : ids) {
                MovieCard card = byId.get(id);
                if (card != null) {
                    ordered.add(card);
                }
            }
            return ordered;
        } finally {
            em.close();
        }
    }

    /** Movie entity by id, or null if not found. */
    public Movie findById(Long id) {
        if (id == null) {
            return null;
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(Movie.class, id);
        } finally {
            em.close();
        }
    }

    /** Public movie entity or null. */
    public Movie findPublishedById(Long id) {
        if (id == null) {
            return null;
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Movie> found = em.createQuery(
                    "select m from Movie m where m.id = :id and m.status = 'PUBLISHED'", Movie.class)
                    .setParameter("id", id)
                    .getResultList();
            return found.isEmpty() ? null : found.get(0);
        } finally {
            em.close();
        }
    }

    /** Active (not deleted) category names for a movie, alphabetical. */
    public List<CategoryOption> findActiveCategories(Long movieId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> rows = em.createQuery(
                    "select c.id, c.name from Movie m join m.categories c"
                    + " where m.id = :id and c.deletedAt is null order by c.name asc, c.id asc", Object[].class)
                    .setParameter("id", movieId)
                    .getResultList();
            List<CategoryOption> result = new ArrayList<>();
            for (Object[] row : rows) {
                result.add(new CategoryOption(((Number) row[0]).longValue(), (String) row[1]));
            }
            return result;
        } finally {
            em.close();
        }
    }

    /** Returns {average, count} of public reviews; average is null when count is 0. */
    public Object[] findRatingSummary(Long movieId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Object[] row = em.createQuery(
                    "select avg(r.rating), count(r.id) from Review r"
                    + " where r.movieId = :id and r.status = 'APPROVED' and r.deletedAt is null", Object[].class)
                    .setParameter("id", movieId)
                    .getSingleResult();
            Double avg = row[0] == null ? null : ((Number) row[0]).doubleValue();
            Long count = row[1] == null ? 0L : ((Number) row[1]).longValue();
            return new Object[]{avg, count};
        } finally {
            em.close();
        }
    }

    /** Similar public movies sharing at least one active category with {@code movieId}. */
    public List<Long> findSimilarIds(Long movieId, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                    "select m2.id from Movie m2 join m2.categories c"
                    + " where m2.status = 'PUBLISHED' and m2.id <> :id and c.deletedAt is null"
                    + " and c.id in (select c0.id from Movie cur join cur.categories c0"
                    + "   where cur.id = :id and c0.deletedAt is null)"
                    + " group by m2.id, m2.viewCount"
                    + " order by count(c.id) desc, m2.viewCount desc, m2.id desc", Long.class);
            query.setParameter("id", movieId);
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /** Distinct release years of public movies, newest first. */
    public List<Integer> findPublicYears() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("select distinct m.releaseYear from Movie m"
                    + " where m.status = 'PUBLISHED' order by m.releaseYear desc", Integer.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Atomically adds one view to a movie that is still PUBLISHED. Does not touch updatedAt/version so
     * counting a view never reorders the "newest" lists. Returns false when nothing was updated.
     */
    public boolean incrementViewCount(Long movieId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            int updated = em.createQuery(
                    "update Movie m set m.viewCount = m.viewCount + 1"
                    + " where m.id = :id and m.status = 'PUBLISHED'")
                    .setParameter("id", movieId)
                    .executeUpdate();
            tx.commit();
            return updated == 1;
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }
}
