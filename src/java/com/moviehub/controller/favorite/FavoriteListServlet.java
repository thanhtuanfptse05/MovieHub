package com.moviehub.controller.favorite;

import com.moviehub.dto.FavoritePage;
import com.moviehub.service.FavoriteService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * GET /favorites : Personal watchlist page for authenticated user (FAV-AC-06).
 */
public class FavoriteListServlet extends HttpServlet {

    private FavoriteService favoriteService;

    @Override
    public void init() throws ServletException {
        this.favoriteService = new FavoriteService();
    }

    FavoriteListServlet(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    public FavoriteListServlet() {
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        if (userId == null) {
            // Guarded by AuthFilter, but double-check safely
            response.sendRedirect(request.getContextPath() + "/login?returnTo=" + request.getContextPath() + "/favorites");
            return;
        }

        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr.trim());
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        FavoritePage favoritePage = favoriteService.getFavorites(userId, page);

        request.setAttribute("favoritePage", favoritePage);
        request.setAttribute("items", favoritePage.getItems());
        request.setAttribute("page", favoritePage.getPage());
        request.setAttribute("totalPages", favoritePage.getTotalPages());
        request.setAttribute("totalCount", favoritePage.getTotalCount());
        request.setAttribute("hasItems", favoritePage.isHasItems());

        request.getRequestDispatcher("/WEB-INF/views/favorite/favorite-list.jsp").forward(request, response);
    }
}
