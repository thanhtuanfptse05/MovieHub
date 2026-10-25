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
 * Controller handling Step 2 of direct password recovery (R-01 / AUTH-US-03).
 * Operates purely on transient server session context; revokes prior sessions upon commit.
 */
public class ResetPasswordServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        ResetContext context = (session != null) ? (ResetContext) session.getAttribute(ResetContext.SESSION_KEY) : null;

        // Missing or expired context -> 303 to forgot-password (R-01 Item 4)
        if (context == null) {
            response.setStatus(HttpServletResponse.SC_SEE_OTHER);
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return;
        }

        // Verify account is still ACTIVE and credentialsVersion has not changed
        boolean isValid = authService.validateSessionCredentials(context.getTargetUserId(), context.getExpectedCredentialsVersion());
        if (!isValid) {
            session.removeAttribute(ResetContext.SESSION_KEY);
            response.setStatus(HttpServletResponse.SC_SEE_OTHER);
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return;
        }

        request.setAttribute("targetEmail", context.getTargetEmail());
        request.setAttribute("flowVersion", context.getFlowVersion());
        request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        ResetContext context = (session != null) ? (ResetContext) session.getAttribute(ResetContext.SESSION_KEY) : null;

        if (context == null) {
            // Context missing or session expired -> 409 Conflict (R-01 Item 8)
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            request.setAttribute("errorMessage", "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng nhập lại email.");
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        String formFlowVersionStr = request.getParameter("flowVersion");
        int formFlowVersion = -1;
        try {
            if (formFlowVersionStr != null) {
                formFlowVersion = Integer.parseInt(formFlowVersionStr.trim());
            }
        } catch (NumberFormatException ignored) {
        }

        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            authService.completePasswordReset(context, formFlowVersion, password, confirmPassword);

            // Step 7: Clear context, invalidate session, revoke prior sessions, 303 to login
            session.removeAttribute(ResetContext.SESSION_KEY);
            session.invalidate();

            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("flashSuccess", "Đã đặt lại mật khẩu. Vui lòng đăng nhập.");

            response.setStatus(HttpServletResponse.SC_SEE_OTHER);
            response.sendRedirect(request.getContextPath() + "/login");
        } catch (IllegalArgumentException ex) {
            // Password validation failure -> 400 Bad Request, keep context so user can fix
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("targetEmail", context.getTargetEmail());
            request.setAttribute("flowVersion", context.getFlowVersion());
            request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
        } catch (IllegalStateException ex) {
            // Flow version mismatch or stale credentials conflict -> 409 Conflict
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            session.removeAttribute(ResetContext.SESSION_KEY);
            request.setAttribute("errorMessage", ex.getMessage() + ". Vui lòng bắt đầu lại từ bước nhập email.");
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống khi cập nhật mật khẩu. Vui lòng thử lại.");
            request.setAttribute("targetEmail", context.getTargetEmail());
            request.setAttribute("flowVersion", context.getFlowVersion());
            request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
        }
    }
}
