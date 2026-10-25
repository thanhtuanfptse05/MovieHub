package com.moviehub.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

/**
 * Filter that enforces UTF-8 character encoding on incoming dynamic HTTP requests and responses
 * to prevent character corruption (mojibake) of Vietnamese and Unicode text (SYS-03 / DATA-02).
 *
 * IMPORTANT (Anti-Mojibake Rule 5 & DATA-02):
 * Static assets (/assets/*, .js, .css, images, fonts, etc.) MUST NOT have response.setCharacterEncoding()
 * called on them, because Tomcat's DefaultServlet would switch to a character Writer using the
 * Windows host default encoding (Cp1252), causing double-encoded UTF-8 mojibake.
 */
public class CharacterEncodingFilter implements Filter {

    private static final String ENCODING = "UTF-8";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No special configuration needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest httpRequest) {
            String path = httpRequest.getServletPath();
            if (path == null || path.isEmpty()) {
                path = httpRequest.getRequestURI();
            }
            if (isStaticAsset(path)) {
                // Bypass filter for static assets so Tomcat serves raw binary bytes directly
                chain.doFilter(request, response);
                return;
            }
        }

        request.setCharacterEncoding(ENCODING);
        response.setCharacterEncoding(ENCODING);
        chain.doFilter(request, response);
    }

    private boolean isStaticAsset(String path) {
        if (path == null) {
            return false;
        }
        String lower = path.toLowerCase();
        return lower.startsWith("/assets/")
                || lower.endsWith(".js")
                || lower.endsWith(".css")
                || lower.endsWith(".png")
                || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg")
                || lower.endsWith(".gif")
                || lower.endsWith(".svg")
                || lower.endsWith(".ico")
                || lower.endsWith(".woff")
                || lower.endsWith(".woff2")
                || lower.endsWith(".ttf")
                || lower.endsWith(".eot")
                || lower.endsWith(".map")
                || lower.endsWith(".mp4")
                || lower.endsWith(".webm");
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }
}
