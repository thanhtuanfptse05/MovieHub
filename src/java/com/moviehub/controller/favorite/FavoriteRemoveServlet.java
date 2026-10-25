package com.moviehub.controller.favorite;

import com.moviehub.exception.NotFoundException;
import com.moviehub.service.FavoriteService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * POST /favorites/remove : Soft-removes movie from user's favorites list (FAV-AC-05).
 * Redirects 303 to returnTo (if detail) or /favorites?page={page}.
 */
public class FavoriteRemoveServlet extends HttpServlet {

    private FavoriteService favoriteService;

    @Override
    public void init() throws ServletException {
        this.favoriteService = new FavoriteService();
    }

    FavoriteRemoveServlet(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    public FavoriteRemoveServlet() {
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String movieIdStr = request.getParameter("movieId");
        Long movieId = null;
        try {
            if (movieIdStr != null && !movieIdStr.trim().isEmpty()) {
                movieId = Long.parseLong(movieIdStr.trim());
            }
        } catch (NumberFormatException ex) {
            movieId = null;
        }

        if (movieId == null || movieId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID phim không hợp lệ");
            return;
        }

        try {
            favoriteService.removeFavorite(userId, movieId);
        } catch (NotFoundException ex) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, ex.getMessage());
            return;
        }

        String returnTo = request.getParameter("returnTo");
        String redirectTarget;
        if (returnTo != null && returnTo.startsWith("/movies/detail")) {
            redirectTarget = request.getContextPath() + returnTo;
        } else {
            String pageStr = request.getParameter("page");
            int page = 1;
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr.trim());
                } catch (NumberFormatException ignored) {
                    page = 1;
                }
            }
            redirectTarget = request.getContextPath() + "/favorites" + (page > 1 ? "?page=" + page : "");
        }

        // 303 See Other redirect per SYS-04 / FAV-AC-05
        response.setStatus(HttpServletResponse.SC_SEE_OTHER);
        response.setHeader("Location", redirectTarget);
    }
}
