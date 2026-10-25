package com.moviehub.controller.auth;

import com.moviehub.service.AuthService;
import com.moviehub.service.ResetContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller handling Step 1 of direct password recovery (R-01 / AUTH-US-03).
 * Accepts registered active email and binds target to server session context without email/SMTP/OTP.
 */
public class ForgotPasswordServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);

        // Server clears any existing reset context immediately upon receiving a valid forgot POST (R-01 Item 2)
        session.removeAttribute(ResetContext.SESSION_KEY);

        String email = request.getParameter("email");
        Integer currentFlowVersion = (Integer) session.getAttribute("flowVersion");
        if (currentFlowVersion == null) {
            currentFlowVersion = 0;
        }

        try {
            ResetContext resetContext = authService.initiatePasswordReset(email, currentFlowVersion);

            // Store transient reset context and update flowVersion in session
            session.setAttribute(ResetContext.SESSION_KEY, resetContext);
            session.setAttribute("flowVersion", resetContext.getFlowVersion());

            // 303 Redirect to reset-password step within the same session
            response.setStatus(HttpServletResponse.SC_SEE_OTHER);
            response.sendRedirect(request.getContextPath() + "/reset-password");
        } catch (IllegalArgumentException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
        }
    }
}
