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
 * POST /favorites/add : Adds movie to user's favorites list (FAV-AC-03).
 * Redirects 303 to /movies/detail?id={movieId}.
 */
public class FavoriteAddServlet extends HttpServlet {

    private FavoriteService favoriteService;

    @Override
    public void init() throws ServletException {
        this.favoriteService = new FavoriteService();
    }

    FavoriteAddServlet(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    public FavoriteAddServlet() {
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
            favoriteService.addFavorite(userId, movieId);
        } catch (NotFoundException ex) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, ex.getMessage());
            return;
        }

        // 303 See Other redirect to canonical detail page per SYS-04 / FAV-AC-03
        response.setStatus(HttpServletResponse.SC_SEE_OTHER);
        response.setHeader("Location", request.getContextPath() + "/movies/detail?id=" + movieId);
    }
}
