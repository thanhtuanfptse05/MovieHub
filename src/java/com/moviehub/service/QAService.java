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
import java.util.List;
import java.util.Objects;
import java.util.Optional;

/**
 * Service orchestrating movie Q&A discussions (006-qa).
 * Handles boundary validation, parent cascade visibility, and private submission isolation.
 */
public class QAService {

    public static final int QUESTION_MIN_LENGTH = 10;
    public static final int QUESTION_MAX_LENGTH = 500;
    public static final int ANSWER_MIN_LENGTH = 1;
    public static final int ANSWER_MAX_LENGTH = 1000;
    public static final int DEFAULT_PAGE_SIZE = 10;

    private final QuestionDAO questionDAO;
    private final AnswerDAO answerDAO;
    private final MovieDAO movieDAO;
    private final UserDAO userDAO;

    public QAService() {
        this(new QuestionDAO(), new AnswerDAO(), new MovieDAO(), new UserDAO());
    }

    public QAService(QuestionDAO questionDAO, AnswerDAO answerDAO, MovieDAO movieDAO, UserDAO userDAO) {
        this.questionDAO = questionDAO;
        this.answerDAO = answerDAO;
        this.movieDAO = movieDAO;
        this.userDAO = userDAO;
    }

    /**
     * Creates a new question for a published movie (QA-US-01, QA-AC-02).
     */
    public Question createQuestion(Long userId, Long movieId, String content) {
        if (userId == null) {
            throw new ForbiddenException("Vui lòng đăng nhập để đặt câu hỏi.");
        }
        if (movieId == null) {
            throw new NotFoundException("Phim không tồn tại.");
        }

        // Validate actor status
        User user = userDAO.findById(userId).orElseThrow(
                () -> new ForbiddenException("Tài khoản không tồn tại."));
        if (!user.isActive()) {
            throw new ForbiddenException("Tài khoản không có quyền đặt câu hỏi.");
        }

        // Validate movie is published
        Movie movie = movieDAO.findById(movieId);
        if (movie == null || !Movie.STATUS_PUBLISHED.equals(movie.getStatus())) {
            throw new NotFoundException("Phim không tồn tại hoặc chưa phát hành.");
        }

        // Validate content boundary
        if (content == null) {
            throw new IllegalArgumentException("Nội dung câu hỏi không được để trống.");
        }
        String trimmed = content.trim();
        if (trimmed.isEmpty()) {
            throw new IllegalArgumentException("Nội dung câu hỏi không được để trống.");
        }
        if (trimmed.length() < QUESTION_MIN_LENGTH || trimmed.length() > QUESTION_MAX_LENGTH) {
            throw new IllegalArgumentException("Nội dung câu hỏi phải từ " + QUESTION_MIN_LENGTH + " đến " + QUESTION_MAX_LENGTH + " ký tự.");
        }

        Question question = new Question();
        question.setMovieId(movieId);
        question.setUserId(userId);
        question.setContent(trimmed);
        question.setStatus(Question.STATUS_PENDING);
        question.setCreatedAt(Instant.now());
        question.setVersion(1);

        return questionDAO.save(question);
    }

    /**
     * Creates an answer for an approved question (QA-US-02, QA-AC-03).
     */
    public Answer createAnswer(Long userId, Long questionId, Long movieId, String content) {
        if (userId == null) {
            throw new ForbiddenException("Vui lòng đăng nhập để trả lời câu hỏi.");
        }
        if (questionId == null) {
            throw new NotFoundException("Câu hỏi không tồn tại.");
        }

        // Validate actor status
        User user = userDAO.findById(userId).orElseThrow(
                () -> new ForbiddenException("Tài khoản không tồn tại."));
        if (!user.isActive()) {
            throw new ForbiddenException("Tài khoản không có quyền trả lời.");
        }

        // Validate parent question exists and is APPROVED
        Question question = questionDAO.findById(questionId).orElseThrow(
                () -> new NotFoundException("Câu hỏi không tồn tại hoặc chưa được duyệt."));
        if (!Question.STATUS_APPROVED.equals(question.getStatus())) {
            throw new NotFoundException("Câu hỏi không tồn tại hoặc chưa được duyệt.");
        }

        // Validate movie matches and is PUBLISHED
        if (movieId != null && !Objects.equals(question.getMovieId(), movieId)) {
            throw new IllegalArgumentException("Câu hỏi không thuộc phim được chỉ định.");
        }
        Movie movie = movieDAO.findById(question.getMovieId());
        if (movie == null || !Movie.STATUS_PUBLISHED.equals(movie.getStatus())) {
            throw new NotFoundException("Phim không tồn tại hoặc chưa phát hành.");
        }

        // Validate content boundary
        if (content == null) {
            throw new IllegalArgumentException("Nội dung câu trả lời không được để trống.");
        }
        String trimmed = content.trim();
        if (trimmed.isEmpty()) {
            throw new IllegalArgumentException("Nội dung câu trả lời không được để trống.");
        }
        if (trimmed.length() < ANSWER_MIN_LENGTH || trimmed.length() > ANSWER_MAX_LENGTH) {
            throw new IllegalArgumentException("Nội dung câu trả lời phải từ " + ANSWER_MIN_LENGTH + " đến " + ANSWER_MAX_LENGTH + " ký tự.");
        }

        Answer answer = new Answer();
        answer.setQuestionId(questionId);
        answer.setUserId(userId);
        answer.setContent(trimmed);
        answer.setStatus(Answer.STATUS_PENDING);
        answer.setCreatedAt(Instant.now());
        answer.setVersion(1);

        return answerDAO.save(answer);
    }

    /**
     * Retrieves public questions for a movie (QA-US-03, QA-AC-05, QA-AC-08).
     */
    public QuestionPage getPublicQuestions(Long movieId, int page, int pageSize) {
        if (movieId == null) {
            return new QuestionPage();
        }
        if (pageSize <= 0) {
            pageSize = DEFAULT_PAGE_SIZE;
        }

        Movie movie = movieDAO.findById(movieId);
        if (movie == null || !Movie.STATUS_PUBLISHED.equals(movie.getStatus())) {
            return new QuestionPage();
        }

        long totalCount = questionDAO.countPublicQuestions(movieId);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int clampedPage = totalPages <= 0 ? 1 : Math.min(Math.max(page, 1), totalPages);

        List<QuestionItem> items = (totalCount > 0)
                ? questionDAO.findPublicQuestions(movieId, clampedPage, pageSize)
                : Collections.emptyList();

        return new QuestionPage(items, clampedPage, pageSize, totalCount);
    }

    /**
     * Retrieves public answers for a specific question (QA-US-03, QA-AC-05, QA-AC-06).
     * If parent question is not approved or movie is not published, returns empty page.
     */
    public AnswerPage getPublicAnswers(Long questionId, int page, int pageSize) {
        if (questionId == null) {
            return new AnswerPage();
        }
        if (pageSize <= 0) {
            pageSize = DEFAULT_PAGE_SIZE;
        }

        // Verify parent question is approved and movie is published
        Optional<Question> qOpt = questionDAO.findById(questionId);
        if (!qOpt.isPresent() || !Question.STATUS_APPROVED.equals(qOpt.get().getStatus())) {
            return new AnswerPage();
        }
        Movie movie = movieDAO.findById(qOpt.get().getMovieId());
        if (movie == null || !Movie.STATUS_PUBLISHED.equals(movie.getStatus())) {
            return new AnswerPage();
        }

        long totalCount = answerDAO.countPublicAnswers(questionId);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int clampedPage = totalPages <= 0 ? 1 : Math.min(Math.max(page, 1), totalPages);

        List<AnswerItem> items = (totalCount > 0)
                ? answerDAO.findPublicAnswers(questionId, clampedPage, pageSize)
                : Collections.emptyList();

        return new AnswerPage(items, clampedPage, pageSize, totalCount);
    }

    /**
     * Retrieves a single public question detail if approved and movie published.
     */
    public Optional<QuestionItem> getPublicQuestionDetail(Long questionId) {
        if (questionId == null) {
            return Optional.empty();
        }
        Optional<Question> qOpt = questionDAO.findById(questionId);
        if (!qOpt.isPresent() || !Question.STATUS_APPROVED.equals(qOpt.get().getStatus())) {
            return Optional.empty();
        }
        Question q = qOpt.get();
        Movie movie = movieDAO.findById(q.getMovieId());
        if (movie == null || !Movie.STATUS_PUBLISHED.equals(movie.getStatus())) {
            return Optional.empty();
        }

        long answerCount = answerDAO.countPublicAnswers(questionId);
        String authorName = "Thành viên";
        String avatarUrl = null;
        Optional<User> uOpt = userDAO.findById(q.getUserId());
        if (uOpt.isPresent()) {
            authorName = uOpt.get().getFullName();
            avatarUrl = uOpt.get().getAvatarUrl();
        }

        return Optional.of(new QuestionItem(
                q.getId(), q.getMovieId(), q.getUserId(), authorName, avatarUrl,
                q.getContent(), q.getStatus(), q.getCreatedAt(), answerCount
        ));
    }

    /**
     * Retrieves user's own submissions (both questions and answers) for a movie (QA-AC-11).
     * Strictly isolates private parent question text from other users.
     */
    public MyQaPage getUserSubmissions(Long userId, Long movieId, int page, int pageSize) {
        if (userId == null || movieId == null) {
            return new MyQaPage();
        }
        if (pageSize <= 0) {
            pageSize = DEFAULT_PAGE_SIZE;
        }

        Movie movie = movieDAO.findById(movieId);
        if (movie == null || !Movie.STATUS_PUBLISHED.equals(movie.getStatus())) {
            return new MyQaPage();
        }

        List<MyQaItem> allItems = new ArrayList<>();

        // 1. User questions
        List<Question> userQuestions = questionDAO.findByUserIdAndMovieId(userId, movieId);
        for (Question q : userQuestions) {
            allItems.add(new MyQaItem(
                    q.getId(),
                    MyQaItem.TYPE_QUESTION,
                    q.getMovieId(),
                    q.getContent(),
                    q.getContent(),
                    q.getStatus(),
                    q.getCreatedAt(),
                    true
            ));
        }

        // 2. User answers
        List<Object[]> userAnswers = answerDAO.findUserAnswersWithQuestion(userId, movieId);
        for (Object[] row : userAnswers) {
            Answer a = (Answer) row[0];
            Question parentQ = (Question) row[1];

            boolean isParentPublic = parentQ != null && Question.STATUS_APPROVED.equals(parentQ.getStatus());
            boolean isParentOwner = parentQ != null && Objects.equals(parentQ.getUserId(), userId);

            // Safe parent title: reveal only if user is the question author OR question is public
            String questionTitle;
            if (isParentOwner || isParentPublic) {
                questionTitle = parentQ != null ? parentQ.getContent() : "Câu hỏi";
            } else {
                questionTitle = "Câu hỏi hiện không công khai";
            }

            allItems.add(new MyQaItem(
                    a.getId(),
                    MyQaItem.TYPE_ANSWER,
                    a.getQuestionId(),
                    questionTitle,
                    a.getContent(),
                    a.getStatus(),
                    a.getCreatedAt(),
                    isParentPublic
            ));
        }

        // Sort: createdAt desc, question before answer when equal, id desc
        allItems.sort((o1, o2) -> {
            int cmp = o2.getCreatedAt().compareTo(o1.getCreatedAt());
            if (cmp != 0) {
                return cmp;
            }
            if (o1.isQuestion() && o2.isAnswer()) {
                return -1;
            }
            if (o1.isAnswer() && o2.isQuestion()) {
                return 1;
            }
            return o2.getId().compareTo(o1.getId());
        });

        long totalCount = allItems.size();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int clampedPage = totalPages <= 0 ? 1 : Math.min(Math.max(page, 1), totalPages);

        int fromIndex = (clampedPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, allItems.size());
        List<MyQaItem> pagedItems = (fromIndex < allItems.size())
                ? allItems.subList(fromIndex, toIndex)
                : Collections.emptyList();

        return new MyQaPage(pagedItems, clampedPage, pageSize, totalCount);
    }
}
