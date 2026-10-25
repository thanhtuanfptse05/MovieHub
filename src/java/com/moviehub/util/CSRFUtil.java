package com.moviehub.util;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utility for Cross-Site Request Forgery (CSRF) token generation and validation.
 */
public final class CSRFUtil {

    public static final String CSRF_SESSION_ATTRIBUTE = "csrfToken";
    public static final String CSRF_PARAM_NAME = "csrfToken";

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final int TOKEN_BYTE_LENGTH = 32;

    private CSRFUtil() {
        // Utility class
    }

    /**
     * Generates a cryptographically strong, URL-safe Base64 CSRF token.
     */
    public static String generateToken() {
        byte[] randomBytes = new byte[TOKEN_BYTE_LENGTH];
        SECURE_RANDOM.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }

    /**
     * Constant-time comparison between session token and request parameter.
     */
    public static boolean isValidToken(String sessionToken, String requestToken) {
        if (sessionToken == null || requestToken == null) {
            return false;
        }
        if (sessionToken.isEmpty() || requestToken.isEmpty()) {
            return false;
        }
        return MessageDigest.isEqual(
            sessionToken.getBytes(java.nio.charset.StandardCharsets.UTF_8),
            requestToken.getBytes(java.nio.charset.StandardCharsets.UTF_8)
        );
    }
}
