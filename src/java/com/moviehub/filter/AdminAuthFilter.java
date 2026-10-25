package com.moviehub.filter;

import com.moviehub.entity.User;
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
 * Filter guarding administrative routes (/admin/*).
 * Enforces AUTH-AC-08: Guest -> 303 /login; Non-Admin User -> 403 Forbidden.
 */
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No init config needed
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

        HttpSession session = httpRequest.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        String contextPath = httpRequest.getContextPath();
        String requestURI = httpRequest.getRequestURI();
        String path = requestURI.substring(contextPath.length());

        if (userId == null) {
            // Guest -> 303 /login with returnTo
            String returnTo = path;
            if (httpRequest.getQueryString() != null) {
                returnTo += "?" + httpRequest.getQueryString();
            }
            httpResponse.sendRedirect(contextPath + "/login?returnTo=" +
                java.net.URLEncoder.encode(returnTo, java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        if (!User.ROLE_ADMIN.equalsIgnoreCase(userRole)) {
            // Authenticated non-admin user -> 403 Forbidden
            httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
            httpRequest.setAttribute("errorMessage", "Bạn không có quyền truy cập khu vực quản trị.");
            httpRequest.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(httpRequest, httpResponse);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
