package com.moviehub.util;

import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import java.util.regex.Pattern;

/**
 * Validation utilities enforcing MovieHub shared data contract and security rules.
 */
public final class ValidationUtil {

    private static final Pattern LOCAL_PART_PATTERN = Pattern.compile("^[a-zA-Z0-9_%+-]+(?:\\.[a-zA-Z0-9_%+-]+)*$");
    private static final Pattern DOMAIN_LABEL_PATTERN = Pattern.compile("^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$");

    private ValidationUtil() {
        // Utility class
    }

    /**
     * Canonicalizes email: trims and converts to lowercase.
     */
    public static String canonicalizeEmail(String email) {
        if (email == null) {
            return null;
        }
        return email.trim().toLowerCase();
    }

    /**
     * Validates email according to MovieHub data-contract.
     * Max 255 ASCII, exactly one '@', valid local part and domain.
     */
    public static boolean isValidEmail(String email) {
        if (email == null) {
            return false;
        }
        String trimmed = email.trim();
        if (trimmed.isEmpty() || trimmed.length() > 255) {
            return false;
        }
        // Must be ASCII
        for (int i = 0; i < trimmed.length(); i++) {
            if (trimmed.charAt(i) > 127) {
                return false;
            }
        }
        int atIndex = trimmed.indexOf('@');
        if (atIndex <= 0 || atIndex != trimmed.lastIndexOf('@') || atIndex == trimmed.length() - 1) {
            return false;
        }

        String localPart = trimmed.substring(0, atIndex);
        String domainPart = trimmed.substring(atIndex + 1);

        if (localPart.length() < 1 || localPart.length() > 64) {
            return false;
        }
        if (!LOCAL_PART_PATTERN.matcher(localPart).matches()) {
            return false;
        }

        String[] labels = domainPart.split("\\.", -1);
        if (labels.length < 2) {
            return false;
        }
        for (String label : labels) {
            if (label.isEmpty() || label.length() > 63) {
                return false;
            }
            if (!DOMAIN_LABEL_PATTERN.matcher(label).matches()) {
                return false;
            }
        }
        return true;
    }

    /**
     * Validates password according to data contract:
     * - Do NOT trim
     * - UTF-8 length: 8 to 72 bytes
     * - Minimum 8 code points
     * - No NUL character
     */
    public static boolean isValidPassword(String password) {
        if (password == null) {
            return false;
        }
        if (password.indexOf('\0') >= 0) {
            return false;
        }
        int codePointCount = password.codePointCount(0, password.length());
        if (codePointCount < 8) {
            return false;
        }
        byte[] utf8Bytes = password.getBytes(StandardCharsets.UTF_8);
        return utf8Bytes.length >= 8 && utf8Bytes.length <= 72;
    }

    /**
     * Validates full name:
     * - Trimmed, NFC normalized
     * - Length between 1 and 100 characters
     */
    public static boolean isValidFullName(String fullName) {
        if (fullName == null) {
            return false;
        }
        String normalized = Normalizer.normalize(fullName.trim(), Normalizer.Form.NFC);
        return !normalized.isEmpty() && normalized.length() <= 100;
    }

    /**
     * Normalizes full name with NFC and trim.
     */
    public static String normalizeFullName(String fullName) {
        if (fullName == null) {
            return "";
        }
        return Normalizer.normalize(fullName.trim(), Normalizer.Form.NFC);
    }

    /**
     * Validates avatar URL:
     * - Optional (null or empty is valid; will be stored as null)
     * - Maximum 500 characters
     * - Must be absolute HTTPS (or HTTP localhost/127.0.0.1 for local dev)
     * - No userinfo, control characters, javascript:, data:, file:
     */
    public static boolean isValidAvatarUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            return true;
        }
        String trimmed = url.trim();
        if (trimmed.length() > 500) {
            return false;
        }
        try {
            java.net.URI uri = new java.net.URI(trimmed);
            if (!uri.isAbsolute()) {
                return false;
            }
            String scheme = uri.getScheme();
            if (scheme == null) {
                return false;
            }
            scheme = scheme.toLowerCase();
            if ("https".equals(scheme)) {
                return uri.getUserInfo() == null;
            } else if ("http".equals(scheme)) {
                String host = uri.getHost();
                return ("localhost".equalsIgnoreCase(host) || "127.0.0.1".equals(host)) && uri.getUserInfo() == null;
            } else {
                return false;
            }
        } catch (Exception ex) {
            return false;
        }
    }

    /**
     * Normalizes avatar URL: returns null if empty/whitespace, otherwise trimmed.
     */
    public static String normalizeAvatarUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            return null;
        }
        return url.trim();
    }
}
