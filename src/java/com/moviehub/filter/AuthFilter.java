package com.moviehub.filter;

import com.moviehub.entity.User;
import com.moviehub.service.AuthService;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter that validates active session, credentialsVersion validity, and guest vs authenticated page access.
 */
public class AuthFilter implements Filter {

    private AuthService authService;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        this.authService = new AuthService();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (!(request instanceof HttpServletRequest) || !(response instanceof HttpServletResponse)) {
            chain.doFilter(request, response);
            return;
        }

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String contextPath = httpRequest.getContextPath();
        String requestURI = httpRequest.getRequestURI();
        String path = requestURI.substring(contextPath.length());

        HttpSession session = httpRequest.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        Integer sessionCredentialsVersion = (session != null) ? (Integer) session.getAttribute("credentialsVersion") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        // If user is logged in, verify session validity against DB
        if (userId != null && sessionCredentialsVersion != null) {
            boolean isValid = authService.validateSessionCredentials(userId, sessionCredentialsVersion);
            if (!isValid) {
                // Session credentials revoked or user became INACTIVE
                session.invalidate();
                session = null;
                userId = null;

                if (isProtectedUserPath(path)) {
                    httpResponse.sendRedirect(contextPath + "/login?error=stale_session");
                    return;
                }
            }
        }

        boolean isLoggedIn = (userId != null);

        // WHILE authenticated: GET to auth forms redirects away, POST returns 409 (AUTH-AC-14)
        if (isLoggedIn && isAuthFormPath(path)) {
            if ("GET".equalsIgnoreCase(httpRequest.getMethod())) {
                if (User.ROLE_ADMIN.equalsIgnoreCase(userRole)) {
                    httpResponse.sendRedirect(contextPath + "/admin/dashboard");
                } else {
                    httpResponse.sendRedirect(contextPath + "/");
                }
                return;
            } else {
                httpResponse.setStatus(HttpServletResponse.SC_CONFLICT);
                httpRequest.setAttribute("errorMessage", "Bạn đã đăng nhập. Vui lòng đăng xuất trước khi thực hiện thao tác này.");
                httpRequest.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(httpRequest, httpResponse);
                return;
            }
        }

        // WHILE guest: protected user routes redirect to login
        if (!isLoggedIn && isProtectedUserPath(path)) {
            String returnTo = path;
            if (httpRequest.getQueryString() != null) {
                returnTo += "?" + httpRequest.getQueryString();
            }
            httpResponse.sendRedirect(contextPath + "/login?returnTo=" + java.net.URLEncoder.encode(returnTo, java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isAuthFormPath(String path) {
        return "/login".equals(path) || "/register".equals(path) ||
               "/forgot-password".equals(path) || "/reset-password".equals(path);
    }

    private boolean isProtectedUserPath(String path) {
        return path.startsWith("/profile") || path.startsWith("/favorites") || path.startsWith("/reviews");
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
