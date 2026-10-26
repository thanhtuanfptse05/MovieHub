package com.moviehub.filter;

import com.moviehub.entity.User;
import com.moviehub.dao.UserDAO;
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

    private static final java.util.Map<String,String> METHODS=java.util.Map.ofEntries(
            java.util.Map.entry("/admin","GET"),java.util.Map.entry("/admin/dashboard","GET"),
            java.util.Map.entry("/admin/movies","GET"),java.util.Map.entry("/admin/movies/create","GET, POST"),
            java.util.Map.entry("/admin/movies/edit","GET, POST"),java.util.Map.entry("/admin/movies/hide","POST"),
            java.util.Map.entry("/admin/categories","GET"),java.util.Map.entry("/admin/categories/edit","GET"),
            java.util.Map.entry("/admin/categories/save","POST"),java.util.Map.entry("/admin/categories/delete","POST"),
            java.util.Map.entry("/admin/users","GET"),java.util.Map.entry("/admin/users/edit","GET"),
            java.util.Map.entry("/admin/users/update","POST"),java.util.Map.entry("/admin/moderation","GET"),
            java.util.Map.entry("/admin/moderation/decide","POST"));

    private final UserDAO users;
    public AdminAuthFilter() { this(new UserDAO()); }
    public AdminAuthFilter(UserDAO users) { this.users = users; }

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

        String contextPath = httpRequest.getContextPath();
        String path = httpRequest.getRequestURI().substring(contextPath.length());
        if(path.endsWith("/"))path=path.substring(0,path.length()-1);
        String allowed=METHODS.getOrDefault(path,"GET, POST");
        String method=httpRequest.getMethod();
        if(!java.util.Arrays.asList(allowed.split(", ")).contains(method)) {
            httpResponse.setHeader("Cache-Control","no-store");
            httpResponse.setHeader("Allow",allowed);
            httpResponse.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            httpRequest.setAttribute("statusCode",405);
            httpRequest.setAttribute("errorMessage","Phương thức không được hỗ trợ.");
            httpRequest.getRequestDispatcher("/WEB-INF/views/admin/error.jsp").forward(httpRequest,httpResponse);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        httpResponse.setHeader("Cache-Control", "no-store");
        User current = userId == null ? null : users.findById(userId).orElse(null);
        Object credentials = session == null ? null : session.getAttribute("credentialsVersion");
        if (userId != null && (current == null || !User.STATUS_ACTIVE.equals(current.getStatus())
                || !java.util.Objects.equals(credentials, current.getCredentialsVersion()))) {
            session.invalidate();
            userId = null;
        }

        if (userId == null) {
            httpResponse.setStatus(HttpServletResponse.SC_SEE_OTHER);
            httpResponse.setHeader("Location", contextPath + "/login");
            return;
        }

        session.setAttribute("userRole", current.getRole());
        httpRequest.setAttribute("currentUserId", current.getId());
        if (!User.ROLE_ADMIN.equals(current.getRole())) {
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
