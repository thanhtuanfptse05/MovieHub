package com.moviehub.controller.review;

import com.moviehub.exception.ConflictException;
import com.moviehub.exception.ForbiddenException;
import com.moviehub.exception.NotFoundException;
import com.moviehub.service.ReviewService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * POST /reviews/delete : Soft-deletes a review (REV-AC-05, REV-AC-06).
 * Enforces 303 See Other redirect to /movies/detail?id={movieId}#reviews.
 */
public class ReviewDeleteServlet extends HttpServlet {

    private ReviewService reviewService;

    @Override
    public void init() throws ServletException {
        this.reviewService = new ReviewService();
    }

    public ReviewDeleteServlet() {
    }

    public ReviewDeleteServlet(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;

        String movieIdStr = request.getParameter("movieId");
        Long movieId = parseLong(movieIdStr);

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long reviewId = parseLong(request.getParameter("reviewId"));
        Integer version = parseInt(request.getParameter("version"));

        if (reviewId == null || reviewId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã đánh giá không hợp lệ.");
            return;
        }
        if (version == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Phiên bản dữ liệu không hợp lệ.");
            return;
        }

        try {
            reviewService.deleteReview(userId, reviewId, version);

            response.setStatus(HttpServletResponse.SC_SEE_OTHER);
            String redirectUrl = request.getContextPath() + "/movies/detail?id=" + (movieId != null ? movieId : "") + "#reviews";
            response.setHeader("Location", redirectUrl);

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

    private static Integer parseInt(String val) {
        if (val == null || val.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
