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

    @Override
    public void init() throws ServletException {
        this.movieService = new MovieService();
        this.favoriteService = new com.moviehub.service.FavoriteService();
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
            if (userId != null) {
                try {
                    isFavorited = favoriteService.isFavorited(userId, id);
                } catch (RuntimeException ex) {
                    LOGGER.log(Level.WARNING, "Favorite check failed for user " + userId + ", movie " + id + ": " + ex.getMessage());
                }
            }

            request.setAttribute("movie", detail);
            request.setAttribute("isFavorited", isFavorited);
            request.setAttribute("similar", movieService.getSimilar(id));
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
}
