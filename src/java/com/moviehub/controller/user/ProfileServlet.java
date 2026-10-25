package com.moviehub.controller.user;

import com.moviehub.entity.User;
import com.moviehub.service.UserService;
import com.moviehub.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller handling user profile viewing and updating (002-user-profile).
 * Enforces session identity, optimistic concurrency, and PRG flash messaging.
 */
public class ProfileServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProfileServlet.class.getName());
    private UserService userService;

    @Override
    public void init() throws ServletException {
        this.userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;

        if (userId == null) {
            String returnTo = URLEncoder.encode("/profile", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/login?returnTo=" + returnTo);
            return;
        }

        try {
            User user = userService.getProfile(userId);
            request.setAttribute("user", user);

            // Pop flash message if available
            if (session != null) {
                String flashSuccess = (String) session.getAttribute("flashSuccess");
                if (flashSuccess != null) {
                    request.setAttribute("flashSuccess", flashSuccess);
                    session.removeAttribute("flashSuccess");
                }
            }

            request.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(request, response);
        } catch (IllegalStateException ex) {
            // User inactive or not found
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login?error=account_unavailable");
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Failed loading profile for user ID " + userId + ": " + ex.getMessage(), ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;

        if (userId == null) {
            String returnTo = URLEncoder.encode("/profile", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/login?returnTo=" + returnTo);
            return;
        }

        String fullName = request.getParameter("fullName");
        String avatarUrl = request.getParameter("avatarUrl");
        String versionStr = request.getParameter("version");

        Integer version = null;
        try {
            if (versionStr != null && !versionStr.trim().isEmpty()) {
                version = Integer.parseInt(versionStr.trim());
            }
        } catch (NumberFormatException ignored) {
            // Handled by service validation
        }

        try {
            userService.updateProfile(userId, fullName, avatarUrl, version);

            // Refresh display data in current session
            session.setAttribute("userFullName", ValidationUtil.normalizeFullName(fullName));
            session.setAttribute("userAvatarUrl", ValidationUtil.normalizeAvatarUrl(avatarUrl));

            // Set PRG flash message
            session.setAttribute("flashSuccess", "Đã cập nhật hồ sơ cá nhân thành công.");
            response.setStatus(HttpServletResponse.SC_SEE_OTHER);
            response.sendRedirect(request.getContextPath() + "/profile");

        } catch (IllegalArgumentException ex) {
            // Validation error: 400 Bad Request
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            prepareFormOnError(request, userId, fullName, avatarUrl, ex.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(request, response);

        } catch (IllegalStateException ex) {
            // Optimistic lock conflict: 409 Conflict
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            prepareFormOnError(request, userId, fullName, avatarUrl, ex.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(request, response);

        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Unexpected error updating profile for user ID " + userId + ": " + ex.getMessage(), ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            prepareFormOnError(request, userId, fullName, avatarUrl, "Đã xảy ra lỗi hệ thống khi lưu hồ sơ. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(request, response);
        }
    }

    private void prepareFormOnError(HttpServletRequest request, Long userId, String enteredFullName, String enteredAvatarUrl, String errorMessage) {
        request.setAttribute("errorMessage", errorMessage);
        try {
            User latest = userService.getProfile(userId);
            // Retain form inputs user entered while keeping server-authoritative email, createdAt, and version
            User formUser = new User();
            formUser.setId(latest.getId());
            formUser.setEmail(latest.getEmail());
            formUser.setCreatedAt(latest.getCreatedAt());
            formUser.setUpdatedAt(latest.getUpdatedAt());
            formUser.setVersion(latest.getVersion());
            formUser.setFullName(enteredFullName != null ? enteredFullName : latest.getFullName());
            formUser.setAvatarUrl(enteredAvatarUrl != null ? enteredAvatarUrl : latest.getAvatarUrl());
            request.setAttribute("user", formUser);
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Failed reloading fresh user on error: " + ex.getMessage());
        }
    }
}
