package com.moviehub.dao;

import com.moviehub.dto.AdminUserItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

public class AdminUserDAO {
    public <T> T read(Function<EntityManager,T> work) { return AdminTransactions.read(work); }
    public <T> T write(Long actorId, Function<EntityManager,T> work) { return AdminTransactions.write(actorId, work); }
    public User findById(EntityManager em, Long id) { return id == null ? null : em.find(User.class, id); }
    public User findForUpdate(EntityManager em, Long id) {
        User user = findById(em, id);
        if (user != null) em.refresh(user, jakarta.persistence.LockModeType.PESSIMISTIC_WRITE);
        return user;
    }
    public long countActiveAdmins(EntityManager em) {
        return em.createQuery("select count(u.id) from User u where u.role = :role and u.status = :status", Long.class)
                .setParameter("role", User.ROLE_ADMIN).setParameter("status", User.STATUS_ACTIVE).getSingleResult();
    }
    public PageResult<AdminUserItem> list(EntityManager em, String q, String role, String status, int requestedPage) {
        String where = " where 1 = 1";
        if (!q.isEmpty()) where += " and lower(u.email) like :q escape '!'";
        if (role != null) where += " and u.role = :role";
        if (status != null) where += " and u.status = :status";
        long total = bind(em.createQuery("select count(u.id) from User u" + where, Long.class), q, role, status).getSingleResult();
        int totalPages = PageResult.totalPagesFor(total);
        int page = PageResult.clampPage(requestedPage, totalPages);
        List<User> users = bind(em.createQuery("select u from User u" + where + " order by u.createdAt desc, u.id desc", User.class), q, role, status)
                .setFirstResult((page - 1) * PageResult.PAGE_SIZE).setMaxResults(PageResult.PAGE_SIZE).getResultList();
        List<AdminUserItem> items = new ArrayList<>(users.size());
        for (User user : users) items.add(new AdminUserItem(user));
        return new PageResult<>(items, total, page, totalPages);
    }
    private <T> TypedQuery<T> bind(TypedQuery<T> query, String q, String role, String status) {
        if (!q.isEmpty()) query.setParameter("q", "%" + q.replace("!", "!!").replace("%", "!%").replace("_", "!_").replace("[", "![") + "%");
        if (role != null) query.setParameter("role", role);
        if (status != null) query.setParameter("status", status);
        return query;
    }
}
