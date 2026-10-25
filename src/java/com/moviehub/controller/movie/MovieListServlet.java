package com.moviehub.controller.movie;

import com.moviehub.dto.CatalogQuery;
import com.moviehub.dto.MovieCard;
import com.moviehub.dto.PageResult;
import com.moviehub.service.MovieService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /movies : search, filter, sort and paginate PUBLISHED movies.
 * Invalid q/category/year yields 400 with field errors (filters are never silently dropped).
 */
public class MovieListServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MovieListServlet.class.getName());
    private MovieService movieService;

    @Override
    public void init() throws ServletException {
        this.movieService = new MovieService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            CatalogQuery query = movieService.parseQuery(
                    request.getParameter("q"),
                    request.getParameter("category"),
                    request.getParameter("year"),
                    request.getParameter("sort"),
                    request.getParameter("page"));

            PageResult<MovieCard> result;
            if (query.isValid()) {
                result = movieService.search(query);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result = new PageResult<>(new ArrayList<MovieCard>(), 0, 1, 0);
            }

            request.setAttribute("query", query);
            request.setAttribute("result", result);
            request.setAttribute("categories", movieService.listCategories());
            request.setAttribute("years", movieService.listYears());
            request.getRequestDispatcher("/WEB-INF/views/movie/movie-list.jsp").forward(request, response);
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Failed loading movie list: " + ex.getMessage(), ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
