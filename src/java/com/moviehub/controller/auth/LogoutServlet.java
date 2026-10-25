package com.moviehub.controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller handling user logout (UC-02 / AUTH-US-02).
 * Enforces POST method with CSRF token; GET returns 405 Method Not Allowed.
 */
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // SYS-04: GET logout is strictly prohibited to prevent CSRF logout attacks
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        request.setAttribute("errorMessage", "Phương thức GET không được hỗ trợ để đăng xuất.");
        request.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        // 303 Redirect to Home
        response.setStatus(HttpServletResponse.SC_SEE_OTHER);
        response.sendRedirect(request.getContextPath() + "/");
    }
}
