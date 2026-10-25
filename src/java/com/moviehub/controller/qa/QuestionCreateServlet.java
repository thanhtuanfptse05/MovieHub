package com.moviehub.controller.qa;

import com.moviehub.entity.Question;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.ForbiddenException;
import com.moviehub.exception.NotFoundException;
import com.moviehub.service.QAService;
import com.moviehub.util.SubmissionNonceUtil;
import com.moviehub.util.SubmissionNonceUtil.NonceRecord;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * POST /questions/create : Submits a new question for moderation (QA-US-01, QA-AC-02).
 * Enforces in-session submission nonce for idempotent retry (QA-AC-10, QA-AC-12)
 * and 303 See Other redirect to /movies/detail?id={movieId}#qa.
 */
public class QuestionCreateServlet extends HttpServlet {

    private QAService qaService;

    @Override
    public void init() throws ServletException {
        this.qaService = new QAService();
    }

    public QuestionCreateServlet() {
    }

    public QuestionCreateServlet(QAService qaService) {
        this.qaService = qaService;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;

        String movieIdStr = request.getParameter("movieId");
        Long movieId = parseLong(movieIdStr);

        if (userId == null) {
            String returnTo = (movieId != null) ? "/movies/detail?id=" + movieId + "#qa" : "/";
            response.sendRedirect(request.getContextPath() + "/login?returnTo=" + URLEncoder.encode(returnTo, StandardCharsets.UTF_8));
            return;
        }

        if (movieId == null || movieId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID phim không hợp lệ.");
            return;
        }

        String submissionId = request.getParameter("submissionId");
        String content = request.getParameter("content");

        try {
            // Validate submission nonce against session
            NonceRecord record = SubmissionNonceUtil.validateNonce(
                    session, submissionId, userId, SubmissionNonceUtil.TYPE_QUESTION, movieId);

            synchronized (record) {
                // If already committed, return idempotent redirect without duplicate insert (QA-AC-10)
                if (record.isCommitted()) {
                    response.setStatus(HttpServletResponse.SC_SEE_OTHER);
                    response.setHeader("Location", request.getContextPath() + record.getRedirectUrl());
                    return;
                }

                Question q = qaService.createQuestion(userId, movieId, content);
                String redirectUrl = "/movies/detail?id=" + movieId + "#qa";
                record.markCommitted(redirectUrl, q.getId());

                session.setAttribute("flashMessage", "Đã gửi câu hỏi, đang chờ duyệt");
                response.setStatus(HttpServletResponse.SC_SEE_OTHER);
                response.setHeader("Location", request.getContextPath() + redirectUrl);
            }

        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        } catch (ForbiddenException ex) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, ex.getMessage());
        } catch (NotFoundException ex) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, ex.getMessage());
        } catch (ConflictException ex) {
            response.sendError(HttpServletResponse.SC_CONFLICT, ex.getMessage());
        }
    }

    private static Long parseLong(String val) {
        if (val == null || val.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(val.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
