package com.moviehub.filter;

import com.moviehub.util.CSRFUtil;
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
import java.util.logging.Logger;

/**
 * Filter that establishes anti-CSRF token per session and verifies token on mutating HTTP requests.
 */
public class CSRFFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(CSRFFilter.class.getName());

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

        HttpSession session = httpRequest.getSession(true);
        String sessionToken = (String) session.getAttribute(CSRFUtil.CSRF_SESSION_ATTRIBUTE);

        if (sessionToken == null || sessionToken.trim().isEmpty()) {
            sessionToken = CSRFUtil.generateToken();
            session.setAttribute(CSRFUtil.CSRF_SESSION_ATTRIBUTE, sessionToken);
        }

        // Expose token to request scope for JSP form rendering: ${csrfToken}
        httpRequest.setAttribute(CSRFUtil.CSRF_PARAM_NAME, sessionToken);
        httpResponse.setHeader("X-CSRF-TOKEN", sessionToken);

        String method = httpRequest.getMethod();
        if ("POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method) || "DELETE".equalsIgnoreCase(method)) {
            String requestToken = httpRequest.getParameter(CSRFUtil.CSRF_PARAM_NAME);

            if (!CSRFUtil.isValidToken(sessionToken, requestToken)) {
                LOGGER.warning("CSRF token validation failed for URI: " + httpRequest.getRequestURI());
                httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
                httpRequest.setAttribute("errorMessage", "Yêu cầu không hợp lệ hoặc token bảo mật đã hết hạn (CSRF).");
                httpRequest.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(httpRequest, httpResponse);
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
