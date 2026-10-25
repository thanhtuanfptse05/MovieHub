package com.moviehub.controller.auth;

import com.moviehub.entity.User;
import com.moviehub.service.AuthService;
import com.moviehub.util.CSRFUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller handling user authentication and session fixation prevention (UC-02 / AUTH-US-02).
 */
public class LoginServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            String flashSuccess = (String) session.getAttribute("flashSuccess");
            if (flashSuccess != null) {
                request.setAttribute("flashSuccess", flashSuccess);
                session.removeAttribute("flashSuccess");
            }
        }

        String returnTo = sanitizeReturnTo(request.getParameter("returnTo"), request.getContextPath());
        request.setAttribute("returnTo", returnTo);

        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String returnTo = sanitizeReturnTo(request.getParameter("returnTo"), request.getContextPath());

        try {
            User user = authService.login(email, password);

            // Session Fixation Defense: Invalidate old session and generate new ID (SEC-02 / Layer 1)
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession newSession = request.getSession(true);

            // Store minimal authoritative user identity and credentials version in session
            newSession.setAttribute("userId", user.getId());
            newSession.setAttribute("userEmail", user.getEmail());
            newSession.setAttribute("userName", user.getFullName());
            newSession.setAttribute("userRole", user.getRole());
            newSession.setAttribute("credentialsVersion", user.getCredentialsVersion());

            // Establish fresh CSRF token in new session
            newSession.setAttribute(CSRFUtil.CSRF_SESSION_ATTRIBUTE, CSRFUtil.generateToken());

            // Determine redirect target (303 See Other)
            response.setStatus(HttpServletResponse.SC_SEE_OTHER);
            if (returnTo != null && !returnTo.isEmpty()) {
                response.sendRedirect(request.getContextPath() + returnTo);
            } else if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/");
            }
        } catch (IllegalArgumentException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("email", email);
            request.setAttribute("returnTo", returnTo);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.");
            request.setAttribute("email", email);
            request.setAttribute("returnTo", returnTo);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }

    /**
     * Sanitizes returnTo parameter to prevent Open Redirect vulnerabilities (SYS-04 / SYS-06).
     * Must be an internal relative path starting with '/', containing no protocol or backslashes.
     */
    private String sanitizeReturnTo(String returnTo, String contextPath) {
        if (returnTo == null || returnTo.trim().isEmpty()) {
            return null;
        }
        String trimmed = returnTo.trim();
        if (trimmed.startsWith(contextPath)) {
            trimmed = trimmed.substring(contextPath.length());
        }
        if (!trimmed.startsWith("/") || trimmed.startsWith("//") || trimmed.contains("\\")) {
            return null;
        }
        // Exclude authentication and mutation routes from returnTo
        if (trimmed.startsWith("/login") || trimmed.startsWith("/register") ||
            trimmed.startsWith("/logout") || trimmed.startsWith("/forgot-password") ||
            trimmed.startsWith("/reset-password")) {
            return null;
        }
        return trimmed;
    }
}
