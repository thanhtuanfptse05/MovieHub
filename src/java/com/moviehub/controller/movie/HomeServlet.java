package com.moviehub.controller.movie;

import com.moviehub.dto.HomeData;
import com.moviehub.service.MovieService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET / : Home with featured, newest, most viewed and top rated groups (PUBLISHED movies only).
 */
public class HomeServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(HomeServlet.class.getName());
    private MovieService movieService;

    @Override
    public void init() throws ServletException {
        this.movieService = new MovieService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HomeData home = movieService.getHome();
            request.setAttribute("home", home);
            request.getRequestDispatcher("/WEB-INF/views/movie/home.jsp").forward(request, response);
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Failed loading home: " + ex.getMessage(), ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
