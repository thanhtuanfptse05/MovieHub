package com.moviehub.dao;

import com.moviehub.dto.AdminModerationItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.Answer;
import com.moviehub.entity.Movie;
import com.moviehub.entity.Question;
import com.moviehub.entity.Review;
import com.moviehub.entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.function.Function;

public class AdminModerationDAO {
    public <T> T read(Function<EntityManager,T> work) { return AdminTransactions.read(work); }
    public <T> T write(Long actorId, Function<EntityManager,T> work) { return AdminTransactions.write(actorId, work); }
    public User findUser(EntityManager em, Long id) { return id == null ? null : em.find(User.class, id); }
    public Movie findMovie(EntityManager em, Long id) { return id == null ? null : em.find(Movie.class, id); }
    public Review findReview(EntityManager em, Long id) {
        // Validate even a no-op against a concurrent author edit without advancing its version.
        return id == null ? null : em.find(Review.class, id, LockModeType.OPTIMISTIC);
    }
    public Question findQuestion(EntityManager em, Long id) { return id == null ? null : em.find(Question.class, id); }
    public Answer findAnswer(EntityManager em, Long id) { return id == null ? null : em.find(Answer.class, id); }

    public PageResult<AdminModerationItem> list(EntityManager em, String type, String status, int requestedPage) {
        long total = 0;
        if (includes(type, "review")) total += count(em, "Review", "r", " and r.deletedAt is null", status);
        if (includes(type, "question")) total += count(em, "Question", "q", "", status);
        if (includes(type, "answer")) total += count(em, "Answer", "a", "", status);
        int totalPages = PageResult.totalPagesFor(total);
        int page = PageResult.clampPage(requestedPage, totalPages);
        if (total == 0) return new PageResult<>(new ArrayList<>(), 0, 1, 0);
        int end = (int) Math.min((long) page * PageResult.PAGE_SIZE, Integer.MAX_VALUE);
        List<AdminModerationItem> items = new ArrayList<>();
        // A type can contribute at most the first end rows to the merged page.
        if (includes(type, "review")) loadReviews(em, status, end, items);
        if (includes(type, "question")) loadQuestions(em, status, end, items);
        if (includes(type, "answer")) loadAnswers(em, status, end, items);
        items.sort(Comparator.comparing(AdminModerationItem::getCreatedAtInstant, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparingInt(item -> typeOrder(item.getType())).thenComparing(AdminModerationItem::getId));
        int start = Math.min((page - 1) * PageResult.PAGE_SIZE, items.size());
        int stop = Math.min(start + PageResult.PAGE_SIZE, items.size());
        return new PageResult<>(new ArrayList<>(items.subList(start, stop)), total, page, totalPages);
    }
    private static boolean includes(String type, String candidate) { return "all".equals(type) || candidate.equals(type); }
    private static int typeOrder(String type) { return "review".equals(type) ? 0 : "question".equals(type) ? 1 : 2; }
    private static long count(EntityManager em, String entity, String alias, String extra, String status) {
        return em.createQuery("select count(" + alias + ".id) from " + entity + " " + alias
                + " where " + alias + ".status = :status" + extra, Long.class).setParameter("status", status).getSingleResult();
    }
    private static void loadReviews(EntityManager em, String status, int limit, List<AdminModerationItem> items) {
        List<Object[]> rows = em.createQuery("select r, u.fullName, m.title, m.status from Review r, User u, Movie m"
                + " where r.userId = u.id and r.movieId = m.id and r.status = :status and r.deletedAt is null"
                + " order by r.createdAt asc, r.id asc", Object[].class)
                .setParameter("status", status).setMaxResults(limit).getResultList();
        for (Object[] row : rows) {
            Review r = (Review) row[0];
            items.add(new AdminModerationItem("review", r.getId(), (String) row[1], r.getMovieId(),
                    (String) row[2], (String) row[3], null, null, null, r.getContent(), r.getRating(),
                    r.getStatus(), r.getCreatedAt(), r.getVersion(), r.getContentRevision()));
        }
    }
    private static void loadQuestions(EntityManager em, String status, int limit, List<AdminModerationItem> items) {
        List<Object[]> rows = em.createQuery("select q, u.fullName, m.title, m.status from Question q, User u, Movie m"
                + " where q.userId = u.id and q.movieId = m.id and q.status = :status"
                + " order by q.createdAt asc, q.id asc", Object[].class)
                .setParameter("status", status).setMaxResults(limit).getResultList();
        for (Object[] row : rows) {
            Question q = (Question) row[0];
            items.add(new AdminModerationItem("question", q.getId(), (String) row[1], q.getMovieId(),
                    (String) row[2], (String) row[3], q.getId(), q.getContent(), q.getStatus(), q.getContent(), null,
                    q.getStatus(), q.getCreatedAt(), q.getVersion(), 1));
        }
    }
    private static void loadAnswers(EntityManager em, String status, int limit, List<AdminModerationItem> items) {
        List<Object[]> rows = em.createQuery("select a, u.fullName, m.id, m.title, m.status, q.id, q.content, q.status"
                + " from Answer a, User u, Question q, Movie m"
                + " where a.userId = u.id and a.questionId = q.id and q.movieId = m.id and a.status = :status"
                + " order by a.createdAt asc, a.id asc", Object[].class)
                .setParameter("status", status).setMaxResults(limit).getResultList();
        for (Object[] row : rows) {
            Answer a = (Answer) row[0];
            items.add(new AdminModerationItem("answer", a.getId(), (String) row[1], (Long) row[2],
                    (String) row[3], (String) row[4], (Long) row[5], (String) row[6], (String) row[7],
                    a.getContent(), null, a.getStatus(), a.getCreatedAt(), a.getVersion(), 1));
        }
    }
}
