package com.moviehub.controller.admin;

import com.moviehub.dto.AdminDashboardDTO;
import com.moviehub.service.AnalyticsService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Controller rendering the Executive Admin Analytics Dashboard (/admin/dashboard).
 * Enforces UC-16 / 008-admin-analytics.
 */
public class AdminDashboardServlet extends HttpServlet {

    private AnalyticsService analyticsService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.analyticsService = new AnalyticsService();
    }

    public AdminDashboardServlet(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    public AdminDashboardServlet() {
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();

        // /admin or /admin/ -> redirect 303 See Other to /admin/dashboard
        if ("/admin".equals(servletPath) || "/admin/".equals(servletPath)) {
            response.setStatus(HttpServletResponse.SC_SEE_OTHER);
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        // Fetch consistent snapshot of dashboard metrics (ANA-AC-02, ANA-AC-09)
        AdminDashboardDTO dashboard = analyticsService.getDashboardData();
        request.setAttribute("dashboard", dashboard);

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }
}
