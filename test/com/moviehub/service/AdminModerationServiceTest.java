package com.moviehub.service;

import com.moviehub.dao.AdminModerationDAO;
import com.moviehub.dto.AdminModerationItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.Answer;
import com.moviehub.entity.Movie;
import com.moviehub.entity.Question;
import com.moviehub.entity.Review;
import com.moviehub.entity.User;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.ForbiddenException;
import jakarta.persistence.EntityManager;
import java.lang.reflect.Proxy;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

public class AdminModerationServiceTest {
    private MemoryDAO dao;
    private AdminModerationService service;
    private final Instant now = Instant.parse("2026-10-26T12:00:00Z");

    @Before public void setUp() {
        dao = new MemoryDAO();
        User admin = new User("Administrator", "admin@example.com", "private", "ADMIN", "ACTIVE");
        admin.setId(1L); dao.users.put(1L, admin);
        Movie movie = new Movie(); movie.setId(10L); movie.setTitle("Film"); movie.setStatus("PUBLISHED"); dao.movies.put(10L, movie);
        Review review = new Review(2L, 10L, 4, "Review content"); review.setId(5L); dao.reviews.put(5L, review);
        Question question = new Question(10L, 2L, "Question content"); question.setId(5L); question.setStatus("APPROVED"); dao.questions.put(5L, question);
        Answer answer = new Answer(5L, 2L, "Answer content"); answer.setId(5L); dao.answers.put(5L, answer);
        service = new AdminModerationService(dao, Clock.fixed(now, ZoneOffset.UTC));
    }
    @Test public void approvalChangesOnlyDecisionAndAuditOnCorrectType() {
        assertTrue(service.decide(1L, "review", 5L, "APPROVE", 1, 1));
        Review review = dao.reviews.get(5L);
        assertEquals("APPROVED", review.getStatus());
        assertEquals(Long.valueOf(1), review.getModeratedBy());
        assertEquals(now, review.getModeratedAt());
        assertEquals(Integer.valueOf(1), review.getContentRevision());
        assertEquals("Review content", review.getContent());
        assertEquals(Integer.valueOf(4), review.getRating());
        assertEquals("PENDING", dao.answers.get(5L).getStatus());
    }
    @Test public void sameTargetAndContentRevisionPreserveFirstAuditDespiteStaleVersion() {
        Review r = dao.reviews.get(5L); r.setStatus("APPROVED"); r.setVersion(8);
        r.setModeratedBy(9L); r.setModeratedAt(now.minusSeconds(60));
        Instant previousUpdated = r.getUpdatedAt();
        assertFalse(service.decide(1L, "review", 5L, "APPROVE", 1, 1));
        assertEquals(Long.valueOf(9), r.getModeratedBy());
        assertEquals(now.minusSeconds(60), r.getModeratedAt());
        assertEquals(Integer.valueOf(8), r.getVersion());
        assertEquals(previousUpdated, r.getUpdatedAt());
    }
    @Test(expected = ConflictException.class) public void sameStatusCannotHideChangedContentRevision() {
        Review r = dao.reviews.get(5L); r.setStatus("APPROVED"); r.setContentRevision(2);
        service.decide(1L, "review", 5L, "APPROVE", 1, 1);
    }
    @Test(expected = ConflictException.class) public void staleVersionCannotChangeDecision() {
        dao.reviews.get(5L).setVersion(2);
        service.decide(1L, "review", 5L, "APPROVE", 1, 1);
    }
    @Test(expected = ConflictException.class) public void hiddenMovieBlocksApprovalBeforeNoOp() {
        dao.movies.get(10L).setStatus("HIDDEN"); dao.reviews.get(5L).setStatus("APPROVED");
        service.decide(1L, "review", 5L, "APPROVE", 1, 1);
    }
    @Test(expected = ConflictException.class) public void deletedReviewBlocksRejectEvenForNoOp() {
        Review r = dao.reviews.get(5L); r.setDeletedAt(now); r.setStatus("REJECTED");
        service.decide(1L, "review", 5L, "REJECT", 1, 1);
    }
    @Test public void hiddenMovieStillAllowsReject() {
        dao.movies.get(10L).setStatus("HIDDEN");
        assertTrue(service.decide(1L, "review", 5L, "REJECT", 1, 1));
        assertEquals("REJECTED", dao.reviews.get(5L).getStatus());
    }
    @Test(expected = ConflictException.class) public void unapprovedQuestionBlocksAnswerApprovalBeforeNoOp() {
        dao.questions.get(5L).setStatus("REJECTED"); dao.answers.get(5L).setStatus("APPROVED");
        service.decide(1L, "answer", 5L, "APPROVE", 1, 1);
    }
    @Test public void unapprovedQuestionStillAllowsAnswerRejection() {
        dao.questions.get(5L).setStatus("PENDING");
        assertTrue(service.decide(1L, "answer", 5L, "REJECT", 1, 1));
        assertEquals("REJECTED", dao.answers.get(5L).getStatus());
    }
    @Test public void rejectingQuestionPreservesAllAnswerDecisions() {
        dao.answers.get(5L).setStatus("APPROVED");
        assertTrue(service.decide(1L, "question", 5L, "REJECT", 1, 1));
        assertEquals("REJECTED", dao.questions.get(5L).getStatus());
        assertEquals("APPROVED", dao.answers.get(5L).getStatus());
    }
    @Test public void rejectedQuestionCanBeApprovedAgain() {
        dao.questions.get(5L).setStatus("REJECTED");
        assertTrue(service.decide(1L, "question", 5L, "APPROVE", 1, 1));
        assertEquals("APPROVED", dao.questions.get(5L).getStatus());
    }
    @Test(expected = ConflictException.class) public void questionRevisionMustRemainOne() {
        service.decide(1L, "question", 5L, "REJECT", 1, 2);
    }
    @Test(expected = ForbiddenException.class) public void currentActorMustStillBeActiveAdmin() {
        dao.users.get(1L).setRole("USER");
        service.decide(1L, "review", 5L, "APPROVE", 1, 1);
    }
    @Test(expected = IllegalArgumentException.class) public void rejectsAllAsDecisionType() {
        service.decide(1L, "all", 5L, "APPROVE", 1, 1);
    }
    @Test(expected = IllegalArgumentException.class) public void rejectsUnsupportedAction() {
        service.decide(1L, "review", 5L, "DELETE", 1, 1);
    }
    @Test public void queueDefaultsToAllPending() {
        service.list(null, null, 1);
        assertEquals("all", dao.type); assertEquals("PENDING", dao.status);
    }
    @Test(expected = IllegalArgumentException.class) public void queueRejectsInvalidStatus() {
        service.list("review", "DELETED", 1);
    }

    private static final class MemoryDAO extends AdminModerationDAO {
        final Map<Long, User> users = new HashMap<>();
        final Map<Long, Movie> movies = new HashMap<>();
        final Map<Long, Review> reviews = new HashMap<>();
        final Map<Long, Question> questions = new HashMap<>();
        final Map<Long, Answer> answers = new HashMap<>();
        String type, status;
        private final EntityManager em = (EntityManager) Proxy.newProxyInstance(
                EntityManager.class.getClassLoader(), new Class<?>[]{EntityManager.class},
                (proxy, method, args) -> null);
        @Override public <T> T read(Function<EntityManager,T> work) { return work.apply(em); }
        @Override public <T> T write(Long actorId, Function<EntityManager,T> work) { return work.apply(em); }
        @Override public User findUser(EntityManager em, Long id) { return users.get(id); }
        @Override public Movie findMovie(EntityManager em, Long id) { return movies.get(id); }
        @Override public Review findReview(EntityManager em, Long id) { return reviews.get(id); }
        @Override public Question findQuestion(EntityManager em, Long id) { return questions.get(id); }
        @Override public Answer findAnswer(EntityManager em, Long id) { return answers.get(id); }
        @Override public PageResult<AdminModerationItem> list(EntityManager em, String type, String status, int page) {
            this.type = type; this.status = status;
            return new PageResult<>(Collections.emptyList(), 0, 1, 0);
        }
    }
}
