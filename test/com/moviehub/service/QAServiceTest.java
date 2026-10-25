package com.moviehub.service;

import com.moviehub.dao.AnswerDAO;
import com.moviehub.dao.MovieDAO;
import com.moviehub.dao.QuestionDAO;
import com.moviehub.dao.UserDAO;
import com.moviehub.dto.AnswerItem;
import com.moviehub.dto.AnswerPage;
import com.moviehub.dto.MyQaItem;
import com.moviehub.dto.MyQaPage;
import com.moviehub.dto.QuestionItem;
import com.moviehub.dto.QuestionPage;
import com.moviehub.entity.Answer;
import com.moviehub.entity.Movie;
import com.moviehub.entity.Question;
import com.moviehub.entity.User;
import com.moviehub.exception.ForbiddenException;
import com.moviehub.exception.NotFoundException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit tests for QAService covering boundary validations, cascade visibility,
 * and private access isolation (006-qa).
 */
public class QAServiceTest {

    private StubQuestionDAO questionDAO;
    private StubAnswerDAO answerDAO;
    private StubMovieDAO movieDAO;
    private StubUserDAO userDAO;
    private QAService service;

    @Before
    public void setUp() {
        questionDAO = new StubQuestionDAO();
        answerDAO = new StubAnswerDAO();
        movieDAO = new StubMovieDAO();
        userDAO = new StubUserDAO();
        service = new QAService(questionDAO, answerDAO, movieDAO, userDAO);
        answerDAO.setDependencies(questionDAO, movieDAO);

        // Seed users
        User activeUser = new User();
        activeUser.setId(10L);
        activeUser.setEmail("active@example.com");
        activeUser.setFullName("Active User");
        activeUser.setStatus(User.STATUS_ACTIVE);
        userDAO.save(activeUser);

        User secondUser = new User();
        secondUser.setId(20L);
        secondUser.setEmail("second@example.com");
        secondUser.setFullName("Second User");
        secondUser.setStatus(User.STATUS_ACTIVE);
        userDAO.save(secondUser);

        User bannedUser = new User();
        bannedUser.setId(30L);
        bannedUser.setEmail("banned@example.com");
        bannedUser.setFullName("Banned User");
        bannedUser.setStatus("BANNED");
        userDAO.save(bannedUser);

        // Seed movies
        Movie pubMovie = new Movie();
        pubMovie.setId(1L);
        pubMovie.setTitle("Inception");
        pubMovie.setStatus(Movie.STATUS_PUBLISHED);
        movieDAO.save(pubMovie);

        Movie hiddenMovie = new Movie();
        hiddenMovie.setId(2L);
        hiddenMovie.setTitle("Secret Film");
        hiddenMovie.setStatus(Movie.STATUS_HIDDEN);
        movieDAO.save(hiddenMovie);
    }

    // ==========================================
    // QA-US-01: CREATE QUESTION
    // ==========================================

    @Test
    public void createQuestion_Success_PendingState() {
        Question q = service.createQuestion(10L, 1L, "Kết phim con quay có dừng lại không?");
        assertNotNull(q);
        assertEquals(Long.valueOf(10L), q.getUserId());
        assertEquals(Long.valueOf(1L), q.getMovieId());
        assertEquals("Kết phim con quay có dừng lại không?", q.getContent());
        assertEquals(Question.STATUS_PENDING, q.getStatus());
        assertEquals(Integer.valueOf(1), q.getVersion());
        assertNotNull(q.getCreatedAt());
    }

    @Test
    public void createQuestion_Boundary_Exactly10And500Chars() {
        String tenChars = "1234567890";
        Question q1 = service.createQuestion(10L, 1L, tenChars);
        assertEquals(tenChars, q1.getContent());

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 500; i++) sb.append("a");
        String fiveHundredChars = sb.toString();
        Question q2 = service.createQuestion(10L, 1L, fiveHundredChars);
        assertEquals(fiveHundredChars, q2.getContent());
    }

    @Test(expected = IllegalArgumentException.class)
    public void createQuestion_Throws_LessThan10Chars() {
        service.createQuestion(10L, 1L, "123456789");
    }

    @Test(expected = IllegalArgumentException.class)
    public void createQuestion_Throws_MoreThan500Chars() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 501; i++) sb.append("a");
        service.createQuestion(10L, 1L, sb.toString());
    }

    @Test(expected = IllegalArgumentException.class)
    public void createQuestion_Throws_BlankContent() {
        service.createQuestion(10L, 1L, "   \t\n  ");
    }

    @Test(expected = ForbiddenException.class)
    public void createQuestion_Throws_InactiveUser() {
        service.createQuestion(30L, 1L, "Có ai ở đây không nhỉ?");
    }

    @Test(expected = NotFoundException.class)
    public void createQuestion_Throws_HiddenMovie() {
        service.createQuestion(10L, 2L, "Phim này xem ở đâu vậy?");
    }

    @Test(expected = NotFoundException.class)
    public void createQuestion_Throws_NonExistentMovie() {
        service.createQuestion(10L, 999L, "Phim này xem ở đâu vậy?");
    }

    // ==========================================
    // QA-US-02: CREATE ANSWER
    // ==========================================

    @Test
    public void createAnswer_Success_ApprovedQuestion() {
        // Prepare approved question
        Question q = service.createQuestion(10L, 1L, "Kết phim con quay có dừng lại không?");
        q.setStatus(Question.STATUS_APPROVED);
        questionDAO.save(q);

        Answer a = service.createAnswer(20L, q.getId(), 1L, "Đoàn làm phim xác nhận đây là thực tại.");
        assertNotNull(a);
        assertEquals(Long.valueOf(20L), a.getUserId());
        assertEquals(q.getId(), a.getQuestionId());
        assertEquals("Đoàn làm phim xác nhận đây là thực tại.", a.getContent());
        assertEquals(Answer.STATUS_PENDING, a.getStatus());
        assertNotNull(a.getCreatedAt());
    }

    @Test
    public void createAnswer_Boundary_1And1000Chars() {
        Question q = service.createQuestion(10L, 1L, "Kết phim con quay có dừng lại không?");
        q.setStatus(Question.STATUS_APPROVED);
        questionDAO.save(q);

        Answer a1 = service.createAnswer(20L, q.getId(), 1L, "C");
        assertEquals("C", a1.getContent());

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 1000; i++) sb.append("x");
        Answer a2 = service.createAnswer(20L, q.getId(), 1L, sb.toString());
        assertEquals(1000, a2.getContent().length());
    }

    @Test(expected = IllegalArgumentException.class)
    public void createAnswer_Throws_EmptyContent() {
        Question q = service.createQuestion(10L, 1L, "Kết phim con quay có dừng lại không?");
        q.setStatus(Question.STATUS_APPROVED);
        questionDAO.save(q);

        service.createAnswer(20L, q.getId(), 1L, "   ");
    }

    @Test(expected = IllegalArgumentException.class)
    public void createAnswer_Throws_Exceeding1000Chars() {
        Question q = service.createQuestion(10L, 1L, "Kết phim con quay có dừng lại không?");
        q.setStatus(Question.STATUS_APPROVED);
        questionDAO.save(q);

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 1001; i++) sb.append("x");
        service.createAnswer(20L, q.getId(), 1L, sb.toString());
    }

    @Test(expected = NotFoundException.class)
    public void createAnswer_Throws_PendingParentQuestion() {
        Question q = service.createQuestion(10L, 1L, "Kết phim con quay có dừng lại không?");
        // Remains PENDING
        service.createAnswer(20L, q.getId(), 1L, "Không thể trả lời câu hỏi chưa duyệt.");
    }

    @Test(expected = NotFoundException.class)
    public void createAnswer_Throws_RejectedParentQuestion() {
        Question q = service.createQuestion(10L, 1L, "Kết phim con quay có dừng lại không?");
        q.setStatus(Question.STATUS_REJECTED);
        questionDAO.save(q);

        service.createAnswer(20L, q.getId(), 1L, "Không thể trả lời câu hỏi bị từ chối.");
    }

    @Test(expected = IllegalArgumentException.class)
    public void createAnswer_Throws_MismatchedMovieId() {
        Question q = service.createQuestion(10L, 1L, "Kết phim con quay có dừng lại không?");
        q.setStatus(Question.STATUS_APPROVED);
        questionDAO.save(q);

        // MovieId 999 does not match question.movieId 1
        service.createAnswer(20L, q.getId(), 999L, "Sai movieId");
    }

    // ==========================================
    // QA-US-03: CASCADE VISIBILITY & PUBLIC VIEWS
    // ==========================================

    @Test
    public void publicQuestions_OnlyReturnsApprovedQuestionsOnPublishedMovie() {
        Question q1 = service.createQuestion(10L, 1L, "Câu hỏi 1 đã duyệt?");
        q1.setStatus(Question.STATUS_APPROVED);
        questionDAO.save(q1);

        Question q2 = service.createQuestion(10L, 1L, "Câu hỏi 2 đang chờ duyệt?");
        // remains PENDING

        Question q3 = service.createQuestion(10L, 1L, "Câu hỏi 3 bị từ chối?");
        q3.setStatus(Question.STATUS_REJECTED);
        questionDAO.save(q3);

        QuestionPage page = service.getPublicQuestions(1L, 1, 10);
        assertEquals(1, page.getTotalCount());
        assertEquals(1, page.getItems().size());
        assertEquals("Câu hỏi 1 đã duyệt?", page.getItems().get(0).getContent());
    }

    @Test
    public void publicAnswers_CascadeVisibility_ParentRejectedHidesAnswers() {
        // Create question and approve
        Question q = service.createQuestion(10L, 1L, "Đoạn cuối phim giải thích thế nào?");
        q.setStatus(Question.STATUS_APPROVED);
        questionDAO.save(q);

        // Create answer and approve
        Answer a = service.createAnswer(20L, q.getId(), 1L, "Đoạn cuối là thực tế vì con quay rung rinh.");
        a.setStatus(Answer.STATUS_APPROVED);
        answerDAO.save(a);

        // Verify public answer visible
        AnswerPage pageBefore = service.getPublicAnswers(q.getId(), 1, 10);
        assertEquals(1, pageBefore.getTotalCount());
        assertEquals("Đoạn cuối là thực tế vì con quay rung rinh.", pageBefore.getItems().get(0).getContent());

        // Admin REJECTS parent question (QA-US-03, QA-AC-06)
        q.setStatus(Question.STATUS_REJECTED);
        questionDAO.save(q);

        // Now public answers for this question must be 0, thread is hidden!
        AnswerPage pageAfterReject = service.getPublicAnswers(q.getId(), 1, 10);
        assertEquals(0, pageAfterReject.getTotalCount());
        assertTrue(pageAfterReject.getItems().isEmpty());

        // Question also hidden from public questions list
        QuestionPage qPage = service.getPublicQuestions(1L, 1, 10);
        assertEquals(0, qPage.getTotalCount());

        // Admin RE-APPROVES parent question (QA-AC-07)
        q.setStatus(Question.STATUS_APPROVED);
        questionDAO.save(q);

        // Approved answer reappears!
        AnswerPage pageAfterRestore = service.getPublicAnswers(q.getId(), 1, 10);
        assertEquals(1, pageAfterRestore.getTotalCount());
        assertEquals("Đoạn cuối là thực tế vì con quay rung rinh.", pageAfterRestore.getItems().get(0).getContent());
    }

    // ==========================================
    // PRIVATE SUBMISSIONS & ISOLATION
    // ==========================================

    @Test
    public void userSubmissions_PrivateIsolation_DoesNotLeakOtherUserParentQuestion() {
        // User 20 asks question q (still PENDING)
        Question q = service.createQuestion(20L, 1L, "Bí mật tuyệt mật của kịch bản phim?");
        // It is PENDING and not public!

        // Simulate User 10 answered it (for example via earlier approved state, then q became unapproved)
        Answer a = new Answer(q.getId(), 10L, "Đây là câu trả lời của user 10");
        a.setStatus(Answer.STATUS_PENDING);
        answerDAO.save(a);

        // User 10 views "Nội dung tôi gửi"
        MyQaPage myPage = service.getUserSubmissions(10L, 1L, 1, 10);
        assertEquals(1, myPage.getTotalCount());
        MyQaItem item = myPage.getItems().get(0);
        assertEquals("ANSWER", item.getType());
        assertEquals("Đây là câu trả lời của user 10", item.getContent());
        assertFalse(item.isParentPublic());
        // Parent question text MUST NOT be leaked to User 10 (QA-AC-11)
        assertEquals("Câu hỏi hiện không công khai", item.getQuestionTitle());
    }

    @Test
    public void userSubmissions_ShowsParentText_IfUserIsAuthorOrParentIsPublic() {
        // User 10 asks question q1
        Question q1 = service.createQuestion(10L, 1L, "Câu hỏi do chính User 10 viết");
        // User 10 answers own question
        Answer a1 = new Answer(q1.getId(), 10L, "User 10 tự trả lời câu hỏi của mình");
        answerDAO.save(a1);

        MyQaPage myPage = service.getUserSubmissions(10L, 1L, 1, 10);
        assertEquals(2, myPage.getTotalCount());
        // Even if PENDING, User 10 is the author of q1, so title is displayed
        MyQaItem answerItem = myPage.getItems().stream().filter(MyQaItem::isAnswer).findFirst().get();
        assertEquals("Câu hỏi do chính User 10 viết", answerItem.getQuestionTitle());
    }

    // ==========================================
    // STUB IMPLEMENTATIONS
    // ==========================================

    static class StubQuestionDAO extends QuestionDAO {
        private final Map<Long, Question> store = new HashMap<>();
        private long seq = 1L;

        @Override
        public Optional<Question> findById(Long id) {
            return Optional.ofNullable(store.get(id));
        }

        @Override
        public Question save(Question q) {
            if (q.getId() == null) {
                q.setId(seq++);
            }
            store.put(q.getId(), q);
            return q;
        }

        @Override
        public List<QuestionItem> findPublicQuestions(Long movieId, int page, int pageSize) {
            List<QuestionItem> list = new ArrayList<>();
            for (Question q : store.values()) {
                if (Objects.equals(q.getMovieId(), movieId) && Question.STATUS_APPROVED.equals(q.getStatus())) {
                    list.add(new QuestionItem(q.getId(), q.getMovieId(), q.getUserId(), "User " + q.getUserId(),
                            null, q.getContent(), q.getStatus(), q.getCreatedAt(), 0L));
                }
            }
            list.sort((o1, o2) -> o2.getCreatedAt().compareTo(o1.getCreatedAt()));
            return list;
        }

        @Override
        public long countPublicQuestions(Long movieId) {
            return findPublicQuestions(movieId, 1, 100).size();
        }

        @Override
        public List<Question> findByUserIdAndMovieId(Long userId, Long movieId) {
            List<Question> list = new ArrayList<>();
            for (Question q : store.values()) {
                if (Objects.equals(q.getUserId(), userId) && Objects.equals(q.getMovieId(), movieId)) {
                    list.add(q);
                }
            }
            return list;
        }
    }

    static class StubAnswerDAO extends AnswerDAO {
        private final Map<Long, Answer> store = new HashMap<>();
        private long seq = 1L;

        private StubQuestionDAO questionDAO;
        private StubMovieDAO movieDAO;

        public void setDependencies(StubQuestionDAO qdao, StubMovieDAO mdao) {
            this.questionDAO = qdao;
            this.movieDAO = mdao;
        }

        @Override
        public Optional<Answer> findById(Long id) {
            return Optional.ofNullable(store.get(id));
        }

        @Override
        public Answer save(Answer a) {
            if (a.getId() == null) {
                a.setId(seq++);
            }
            store.put(a.getId(), a);
            return a;
        }

        @Override
        public List<AnswerItem> findPublicAnswers(Long questionId, int page, int pageSize) {
            List<AnswerItem> list = new ArrayList<>();
            for (Answer a : store.values()) {
                if (Objects.equals(a.getQuestionId(), questionId) && Answer.STATUS_APPROVED.equals(a.getStatus())) {
                    list.add(new AnswerItem(a.getId(), a.getQuestionId(), a.getUserId(), "User " + a.getUserId(),
                            null, a.getContent(), a.getStatus(), a.getCreatedAt()));
                }
            }
            list.sort((o1, o2) -> o1.getCreatedAt().compareTo(o2.getCreatedAt()));
            return list;
        }

        @Override
        public long countPublicAnswers(Long questionId) {
            return findPublicAnswers(questionId, 1, 100).size();
        }

        @Override
        public List<Object[]> findUserAnswersWithQuestion(Long userId, Long movieId) {
            List<Object[]> list = new ArrayList<>();
            for (Answer a : store.values()) {
                if (Objects.equals(a.getUserId(), userId)) {
                    // find parent question
                    Question q = questionDAO != null ? questionDAO.findById(a.getQuestionId()).orElse(null) : null;
                    if (q != null && Objects.equals(q.getMovieId(), movieId)) {
                        list.add(new Object[]{a, q});
                    }
                }
            }
            return list;
        }
    }

    static class StubMovieDAO extends MovieDAO {
        private final Map<Long, Movie> store = new HashMap<>();

        public void save(Movie m) {
            store.put(m.getId(), m);
        }

        @Override
        public Movie findById(Long id) {
            return store.get(id);
        }

        @Override
        public Movie findPublishedById(Long id) {
            Movie m = findById(id);
            if (m != null && Movie.STATUS_PUBLISHED.equals(m.getStatus())) {
                return m;
            }
            return null;
        }
    }

    static class StubUserDAO extends UserDAO {
        private final Map<Long, User> store = new HashMap<>();

        @Override
        public User save(User u) {
            store.put(u.getId(), u);
            return u;
        }

        @Override
        public Optional<User> findById(Long id) {
            return Optional.ofNullable(store.get(id));
        }
    }
}
