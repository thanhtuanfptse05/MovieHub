package com.moviehub.controller.movie;

import com.moviehub.dto.MovieDetail;
import com.moviehub.service.MovieService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /movies/detail?id= : public movie detail with media, similar movies and per-session view counting.
 * Non-public or malformed ids give 404 and never count a view.
 */
public class MovieDetailServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MovieDetailServlet.class.getName());
    static final String SESSION_VIEWS = "movieViews";
    private static final Object VIEWS_INIT_LOCK = new Object();

    private MovieService movieService;
    private com.moviehub.service.FavoriteService favoriteService;
    private com.moviehub.service.ReviewService reviewService;
    private com.moviehub.service.QAService qaService;

    @Override
    public void init() throws ServletException {
        this.movieService = new MovieService();
        this.favoriteService = new com.moviehub.service.FavoriteService();
        this.reviewService = new com.moviehub.service.ReviewService();
        this.qaService = new com.moviehub.service.QAService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Long id = parseId(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        try {
            // Count first (only succeeds for PUBLISHED), so the page shows the up-to-date number.
            try {
                movieService.recordViewIfDue(id, sessionViews(request));
            } catch (RuntimeException ex) {
                LOGGER.log(Level.WARNING, "View count failed for movie " + id + ": " + ex.getMessage());
            }

            MovieDetail detail = movieService.getPublicDetail(id);
            if (detail == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            HttpSession session = request.getSession(false);
            Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
            boolean isFavorited = false;
            com.moviehub.dto.ReviewItem userReview = null;

            if (userId != null) {
                try {
                    isFavorited = favoriteService.isFavorited(userId, id);
                } catch (RuntimeException ex) {
                    LOGGER.log(Level.WARNING, "Favorite check failed for user " + userId + ", movie " + id + ": " + ex.getMessage());
                }
                try {
                    userReview = reviewService.getUserReview(userId, id).orElse(null);
                } catch (RuntimeException ex) {
                    LOGGER.log(Level.WARNING, "User review check failed for user " + userId + ", movie " + id + ": " + ex.getMessage());
                }
            }

            int reviewPage = 1;
            String reviewPageStr = request.getParameter("reviewPage");
            if (reviewPageStr != null && reviewPageStr.trim().matches("[0-9]{1,9}")) {
                try {
                    reviewPage = Math.max(1, Integer.parseInt(reviewPageStr.trim()));
                } catch (NumberFormatException ignored) {
                }
            }

            com.moviehub.dto.ReviewPage reviewsPage = reviewService.getPublicReviews(id, reviewPage);

            // 006-qa: Load Q&A data
            int qPage = parseInt(request.getParameter("questionPage"), 1);
            int aPage = parseInt(request.getParameter("answerPage"), 1);
            int myPage = parseInt(request.getParameter("myQaPage"), 1);
            Long selectedQId = parseId(request.getParameter("questionId"));

            com.moviehub.dto.QuestionPage questionsPage = qaService.getPublicQuestions(id, qPage, 10);
            com.moviehub.dto.QuestionItem selectedQuestion = null;
            com.moviehub.dto.AnswerPage answersPage = null;

            if (selectedQId != null) {
                selectedQuestion = qaService.getPublicQuestionDetail(selectedQId).orElse(null);
                if (selectedQuestion != null && selectedQuestion.getMovieId().equals(id)) {
                    answersPage = qaService.getPublicAnswers(selectedQId, aPage, 10);
                } else {
                    selectedQuestion = null;
                }
            }

            com.moviehub.dto.MyQaPage myQaPageData = null;
            if (userId != null && session != null) {
                myQaPageData = qaService.getUserSubmissions(userId, id, myPage, 10);
                String questionNonce = com.moviehub.util.SubmissionNonceUtil.generateNonce(
                        session, userId, com.moviehub.util.SubmissionNonceUtil.TYPE_QUESTION, id);
                request.setAttribute("questionNonce", questionNonce);

                if (selectedQuestion != null) {
                    String answerNonce = com.moviehub.util.SubmissionNonceUtil.generateNonce(
                            session, userId, com.moviehub.util.SubmissionNonceUtil.TYPE_ANSWER, selectedQuestion.getId());
                    request.setAttribute("answerNonce", answerNonce);
                }
            }

            request.setAttribute("movie", detail);
            request.setAttribute("isFavorited", isFavorited);
            request.setAttribute("similar", movieService.getSimilar(id));
            request.setAttribute("reviewsPage", reviewsPage);
            request.setAttribute("userReview", userReview);
            request.setAttribute("questionsPage", questionsPage);
            request.setAttribute("selectedQuestion", selectedQuestion);
            request.setAttribute("answersPage", answersPage);
            request.setAttribute("myQaPageData", myQaPageData);
            request.getRequestDispatcher("/WEB-INF/views/movie/movie-detail.jsp").forward(request, response);
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Failed loading movie " + id + ": " + ex.getMessage(), ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @SuppressWarnings("unchecked")
    private static Map<Long, Instant> sessionViews(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        Object existing = session.getAttribute(SESSION_VIEWS);
        if (existing == null) {
            synchronized (VIEWS_INIT_LOCK) {
                existing = session.getAttribute(SESSION_VIEWS);
                if (existing == null) {
                    existing = new ConcurrentHashMap<Long, Instant>();
                    session.setAttribute(SESSION_VIEWS, existing);
                }
            }
        }
        return (Map<Long, Instant>) existing;
    }

    static Long parseId(String raw) {
        if (raw == null || !raw.trim().matches("[0-9]{1,18}")) {
            return null;
        }
        long value = Long.parseLong(raw.trim());
        return value > 0 ? value : null;
    }

    static int parseInt(String raw, int defaultVal) {
        if (raw == null || !raw.trim().matches("[0-9]{1,9}")) {
            return defaultVal;
        }
        try {
            int val = Integer.parseInt(raw.trim());
            return val > 0 ? val : defaultVal;
        } catch (NumberFormatException ex) {
            return defaultVal;
        }
    }
}
