package com.moviehub.dao;

import com.moviehub.dto.PageResult;
import com.moviehub.entity.Category;
import com.moviehub.entity.Movie;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.Locale;
import java.util.function.Function;

/** JPA catalog operations used within the shared administrator transaction guard. */
public class AdminCatalogDAO {
    public <T> T read(Function<EntityManager, T> work) { return AdminTransactions.read(work); }
    public <T> T write(Long actorId, Function<EntityManager, T> work) { return AdminTransactions.write(actorId, work); }
    public Movie findMovie(EntityManager em, Long id) { return em.find(Movie.class, id); }
    public Movie findMovieForUpdate(EntityManager em, Long id) { return em.find(Movie.class, id, LockModeType.PESSIMISTIC_WRITE); }
    public Category findCategory(EntityManager em, Long id) { return em.find(Category.class, id); }
    public void persistMovie(EntityManager em, Movie movie) { em.persist(movie); }
    public void persistCategory(EntityManager em, Category category) { em.persist(category); }
    public void flush(EntityManager em) { em.flush(); }
    public boolean movieSlugExists(EntityManager em, String slug, Long excludedId) {
        TypedQuery<Long> query = em.createQuery("select count(m.id) from Movie m where m.slug = :slug" + (excludedId == null ? "" : " and m.id <> :id"), Long.class).setParameter("slug", slug);
        if (excludedId != null) query.setParameter("id", excludedId);
        return query.getSingleResult() > 0;
    }
    public long countMovies(EntityManager em, String q, String status) {
        return bindMovie(em.createQuery("select count(m.id) from Movie m" + movieWhere(q, status), Long.class), q, status).getSingleResult();
    }
    public List<Movie> findMovies(EntityManager em, String q, String status, int offset) {
        return bindMovie(em.createQuery("select m from Movie m" + movieWhere(q, status) + " order by m.updatedAt desc, m.id desc", Movie.class), q, status)
                .setFirstResult(offset).setMaxResults(PageResult.PAGE_SIZE).getResultList();
    }
    private static String movieWhere(String q, String status) {
        return " where 1=1" + (q == null || q.isEmpty() ? "" : " and (lower(m.title) like :q escape '!' or lower(m.slug) like :q escape '!')")
                + (status == null || status.isEmpty() ? "" : " and m.status = :status");
    }
    private static <T> TypedQuery<T> bindMovie(TypedQuery<T> query, String q, String status) {
        if (q != null && !q.isEmpty()) query.setParameter("q", MovieDAO.toLikePattern(q.toLowerCase(Locale.ROOT)));
        if (status != null && !status.isEmpty()) query.setParameter("status", status);
        return query;
    }
    public long countCategories(EntityManager em, String q) {
        return bindCategory(em.createQuery("select count(c.id) from Category c" + categoryWhere(q), Long.class), q).getSingleResult();
    }
    public List<Category> findCategories(EntityManager em, String q, int offset) {
        return bindCategory(em.createQuery("select c from Category c" + categoryWhere(q) + " order by c.name asc, c.id asc", Category.class), q)
                .setFirstResult(offset).setMaxResults(PageResult.PAGE_SIZE).getResultList();
    }
    public List<Category> findAllActiveCategories(EntityManager em) {
        return em.createQuery("select c from Category c where c.deletedAt is null order by c.name asc, c.id asc", Category.class).getResultList();
    }
    public List<Category> findAllCategories(EntityManager em) { return em.createQuery("select c from Category c", Category.class).getResultList(); }
    public boolean categoryHasMovies(EntityManager em, Long id) {
        return em.createQuery("select count(m.id) from Movie m join m.categories c where c.id = :id", Long.class).setParameter("id", id).getSingleResult() > 0;
    }
    private static String categoryWhere(String q) {
        return " where c.deletedAt is null" + (q == null || q.isEmpty() ? "" : " and (lower(c.name) like :q escape '!' or lower(c.slug) like :q escape '!')");
    }
    private static <T> TypedQuery<T> bindCategory(TypedQuery<T> query, String q) {
        if (q != null && !q.isEmpty()) query.setParameter("q", MovieDAO.toLikePattern(q.toLowerCase(Locale.ROOT)));
        return query;
    }
}
