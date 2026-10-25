package com.moviehub.util;

import java.net.URI;
import java.util.Locale;

/**
 * Validation of externally hosted media URLs. Only absolute http(s) URLs are ever rendered;
 * playable video additionally has to point at an .mp4 resource.
 */
public final class MediaUrlUtil {

    private static final int MAX_LENGTH = 1000;

    private MediaUrlUtil() {
    }

    /** Returns the trimmed URL when it is an absolute http/https URL without user-info, else null. */
    public static String safeImageUrl(String url) {
        URI uri = parseHttpUri(url);
        return uri == null ? null : url.trim();
    }

    /** Returns the trimmed URL when it is an http/https URL whose path ends with .mp4, else null. */
    public static String safeMp4Url(String url) {
        URI uri = parseHttpUri(url);
        if (uri == null || uri.getPath() == null) {
            return null;
        }
        return uri.getPath().toLowerCase(Locale.ROOT).endsWith(".mp4") ? url.trim() : null;
    }

    private static URI parseHttpUri(String url) {
        if (url == null) {
            return null;
        }
        String trimmed = url.trim();
        if (trimmed.isEmpty() || trimmed.length() > MAX_LENGTH) {
            return null;
        }
        try {
            URI uri = new URI(trimmed);
            String scheme = uri.getScheme();
            if (scheme == null || !(scheme.equalsIgnoreCase("http") || scheme.equalsIgnoreCase("https"))) {
                return null;
            }
            if (uri.getHost() == null || uri.getUserInfo() != null) {
                return null;
            }
            return uri;
        } catch (Exception ex) {
            return null;
        }
    }
}
