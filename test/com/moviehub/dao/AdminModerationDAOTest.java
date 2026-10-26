package com.moviehub.dao;

import com.moviehub.dto.AdminModerationItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.Answer;
import com.moviehub.entity.Question;
import com.moviehub.entity.Review;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.lang.reflect.Proxy;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.Test;
import static org.junit.Assert.*;

/** Exercises the DAO's real cross-type merge with the database boundary substituted. */
public class AdminModerationDAOTest {
    private static final Instant TIME = Instant.parse("2026-10-26T00:00:00Z");

    @Test public void queueKeepsTimestampPrecisionBeforeApplyingTypeOrder() {
        Rows rows = new Rows();
        rows.review(1L, TIME.plusNanos(100));
        rows.answer(1L, TIME);
        PageResult<AdminModerationItem> result = new AdminModerationDAO().list(rows.entityManager(), "all", "PENDING", 1);
        assertEquals("answer", result.getItems().get(0).getType());
        assertEquals("review", result.getItems().get(1).getType());
    }
    @Test public void identicalTimestampsUseReviewQuestionAnswerThenId() {
        Rows rows = new Rows();
        rows.review(2L, TIME); rows.review(9L, TIME); rows.question(1L, TIME); rows.answer(1L, TIME);
        List<AdminModerationItem> items = new AdminModerationDAO().list(rows.entityManager(), "all", "PENDING", 1).getItems();
        assertEquals("review", items.get(0).getType()); assertEquals(Long.valueOf(2L), items.get(0).getId());
        assertEquals("review", items.get(1).getType()); assertEquals(Long.valueOf(9L), items.get(1).getId());
        assertEquals("question", items.get(2).getType()); assertEquals("answer", items.get(3).getType());
    }
    @Test public void mergedPageClampsAndUsesTenRows() {
        Rows rows = new Rows();
        for (long id = 1; id <= 7; id++) { rows.review(id, TIME); rows.question(id, TIME); rows.answer(id, TIME); }
        AdminModerationDAO dao = new AdminModerationDAO();
        PageResult<AdminModerationItem> first = dao.list(rows.entityManager(), "all", "PENDING", 1);
        assertEquals(10, first.getItems().size()); assertEquals(21, first.getTotal());
        PageResult<AdminModerationItem> last = dao.list(rows.entityManager(), "all", "PENDING", 99);
        assertEquals(3, last.getPage()); assertEquals(3, last.getTotalPages());
        assertEquals(1, last.getItems().size());
        assertEquals("answer", last.getItems().get(0).getType());
        assertEquals(Long.valueOf(7L), last.getItems().get(0).getId());
        assertFalse(last.isHasNext());
    }
    @Test public void singleTypeFilterDoesNotIncludeOtherTypes() {
        Rows rows = new Rows(); rows.review(1L, TIME); rows.answer(1L, TIME);
        PageResult<AdminModerationItem> result = new AdminModerationDAO().list(rows.entityManager(), "answer", "PENDING", 1);
        assertEquals(1, result.getTotal()); assertEquals("answer", result.getItems().get(0).getType());
    }
    @Test public void emptyQueueHasNoPaginationLinks() {
        PageResult<AdminModerationItem> result = new AdminModerationDAO().list(new Rows().entityManager(), "all", "PENDING", 50);
        assertEquals(1, result.getPage()); assertEquals(0, result.getTotalPages());
        assertTrue(result.getItems().isEmpty()); assertFalse(result.isHasPrevious()); assertFalse(result.isHasNext());
    }
    @Test public void queueRetainsBlockedParentsAndExplainsApprovalRestriction() {
        Rows rows = new Rows(); rows.answer(1L, TIME);
        rows.answers.get(0)[4] = "HIDDEN"; rows.answers.get(0)[7] = "PENDING";
        AdminModerationItem item = new AdminModerationDAO().list(rows.entityManager(), "all", "PENDING", 1).getItems().get(0);
        assertFalse(item.isApproveAllowed()); assertFalse(item.getApproveBlockedReason().isEmpty());
        assertEquals("HIDDEN", item.getMovieStatus()); assertEquals("PENDING", item.getQuestionStatus());
        assertEquals("Author", item.getAuthorName()); assertEquals(Integer.valueOf(1), item.getContentRevision());
    }

    private static final class Rows {
        final List<Object[]> reviews = new ArrayList<>(), questions = new ArrayList<>(), answers = new ArrayList<>();
        void review(long id, Instant at) {
            Review r = new Review(2L, 10L, 4, "Review"); r.setId(id); r.setCreatedAt(at);
            reviews.add(new Object[]{r, "Author", "Movie", "PUBLISHED"});
        }
        void question(long id, Instant at) {
            Question q = new Question(10L, 2L, "Question text"); q.setId(id); q.setCreatedAt(at);
            questions.add(new Object[]{q, "Author", "Movie", "PUBLISHED"});
        }
        void answer(long id, Instant at) {
            Answer a = new Answer(20L, 2L, "Answer"); a.setId(id); a.setCreatedAt(at);
            answers.add(new Object[]{a, "Author", 10L, "Movie", "PUBLISHED", 20L, "Question text", "APPROVED"});
        }
        EntityManager entityManager() {
            return (EntityManager) Proxy.newProxyInstance(EntityManager.class.getClassLoader(), new Class<?>[]{EntityManager.class},
                    (proxy, method, args) -> {
                        if (!"createQuery".equals(method.getName())) throw new UnsupportedOperationException(method.getName());
                        String jpql = (String) args[0];
                        List<Object[]> data = jpql.contains("from Review ") ? reviews : jpql.contains("from Question ") ? questions : answers;
                        Map<String,Object> params = new HashMap<>();
                        int[] limit = {Integer.MAX_VALUE};
                        return Proxy.newProxyInstance(TypedQuery.class.getClassLoader(), new Class<?>[]{TypedQuery.class},
                                (query, called, values) -> {
                                    switch (called.getName()) {
                                        case "setParameter": params.put((String) values[0], values[1]); return query;
                                        case "setMaxResults": limit[0] = (Integer) values[0]; return query;
                                        case "getSingleResult":
                                            assertEquals("PENDING", params.get("status"));
                                            return (long) data.size();
                                        case "getResultList":
                                            assertEquals("PENDING", params.get("status"));
                                            return new ArrayList<>(data.subList(0, Math.min(limit[0], data.size())));
                                        default: throw new UnsupportedOperationException(called.getName());
                                    }
                                });
                    });
        }
    }
}
