package com.moviehub.util;

import com.moviehub.dto.EpisodeItem;
import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Validation and parsing of externally hosted media URLs (images, MP4 videos, YouTube videos, and multi-episode series).
 */
public final class MediaUrlUtil {

    private static final int MAX_SINGLE_URL_LENGTH = 2000;

    private static final Pattern YOUTUBE_WATCH_PATTERN =
            Pattern.compile("(?:https?://)?(?:www\\.|m\\.)?youtube\\.com/watch\\?(?:.*&)?v=([a-zA-Z0-9_-]{11})", Pattern.CASE_INSENSITIVE);
    private static final Pattern YOUTUBE_SHORT_PATTERN =
            Pattern.compile("(?:https?://)?(?:www\\.)?youtu\\.be/([a-zA-Z0-9_-]{11})", Pattern.CASE_INSENSITIVE);
    private static final Pattern YOUTUBE_EMBED_PATTERN =
            Pattern.compile("(?:https?://)?(?:www\\.)?(?:youtube\\.com|youtube-nocookie\\.com)/embed/([a-zA-Z0-9_-]{11})", Pattern.CASE_INSENSITIVE);
    private static final Pattern YOUTUBE_SHORTS_PATTERN =
            Pattern.compile("(?:https?://)?(?:www\\.)?youtube\\.com/shorts/([a-zA-Z0-9_-]{11})", Pattern.CASE_INSENSITIVE);
    private static final Pattern YOUTUBE_LIVE_PATTERN =
            Pattern.compile("(?:https?://)?(?:www\\.|m\\.)?youtube\\.com/(?:v|live)/([a-zA-Z0-9_-]{11})", Pattern.CASE_INSENSITIVE);

    private static final Pattern EPISODE_LINE_PATTERN =
            Pattern.compile("^(.*?)\\s*[:|\\-]\\s*(https?://.+)$", Pattern.CASE_INSENSITIVE);

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

    /**
     * Extracts an 11-character YouTube video ID from various YouTube URL formats.
     * Returns null if the URL is not a recognized YouTube link.
     */
    public static String extractYouTubeId(String url) {
        if (url == null || url.trim().isEmpty()) {
            return null;
        }
        String trimmed = url.trim();
        Matcher m = YOUTUBE_WATCH_PATTERN.matcher(trimmed);
        if (m.find()) {
            return m.group(1);
        }
        m = YOUTUBE_SHORT_PATTERN.matcher(trimmed);
        if (m.find()) {
            return m.group(1);
        }
        m = YOUTUBE_EMBED_PATTERN.matcher(trimmed);
        if (m.find()) {
            return m.group(1);
        }
        m = YOUTUBE_SHORTS_PATTERN.matcher(trimmed);
        if (m.find()) {
            return m.group(1);
        }
        m = YOUTUBE_LIVE_PATTERN.matcher(trimmed);
        if (m.find()) {
            return m.group(1);
        }
        return null;
    }

    /** Returns true if the URL points to a YouTube video. */
    public static boolean isYouTubeUrl(String url) {
        return extractYouTubeId(url) != null;
    }

    /** Builds a clean, responsive YouTube embed URL from a video ID. */
    public static String toYouTubeEmbedUrl(String videoId) {
        if (videoId == null || videoId.trim().isEmpty()) {
            return null;
        }
        return "https://www.youtube.com/embed/" + videoId.trim() + "?autoplay=1&rel=0";
    }

    /**
     * Resolves a single video URL into a playable URL:
     * - If YouTube: returns the embed URL with autoplay.
     * - If MP4 or valid HTTP(S) stream: returns the safe URL.
     * Returns null if invalid or unsupported.
     */
    public static String safePlayUrl(String url) {
        if (url == null) {
            return null;
        }
        String ytId = extractYouTubeId(url);
        if (ytId != null) {
            return toYouTubeEmbedUrl(ytId);
        }
        String mp4 = safeMp4Url(url);
        if (mp4 != null) {
            return mp4;
        }
        URI uri = parseHttpUri(url);
        return uri != null ? url.trim() : null;
    }

    /**
     * Parses the raw video_url field into an ordered list of EpisodeItems.
     * Handles single URLs, newline-separated lists, and delimited episode formats (||, ;, newlines):
     * e.g. "Tập 1: Joker | https://..." or "Tập 2 - https://..." or "https://... || https://..."
     */
    public static List<EpisodeItem> parseEpisodes(String rawVideoUrl) {
        if (rawVideoUrl == null || rawVideoUrl.trim().isEmpty()) {
            return Collections.emptyList();
        }

        String[] chunks = rawVideoUrl.split("(?:\\r?\\n|\\|\\||;)+");
        List<EpisodeItem> episodes = new ArrayList<>();
        int count = 1;

        for (String chunk : chunks) {
            String trimmed = chunk.trim();
            if (trimmed.isEmpty()) {
                continue;
            }

            int httpIdx = trimmed.toLowerCase(Locale.ROOT).indexOf("http://");
            if (httpIdx < 0) {
                httpIdx = trimmed.toLowerCase(Locale.ROOT).indexOf("https://");
            }

            if (httpIdx < 0) {
                continue; // No valid http/https URL in this chunk
            }

            String title = null;
            if (httpIdx > 0) {
                String prefix = trimmed.substring(0, httpIdx).trim();
                prefix = prefix.replaceAll("[:|\\-\\s]+$", "").trim();
                if (!prefix.isEmpty()) {
                    title = prefix;
                }
            }

            String url = trimmed.substring(httpIdx).trim();
            String ytId = extractYouTubeId(url);
            String playUrl;
            boolean isYt = false;

            if (ytId != null) {
                playUrl = toYouTubeEmbedUrl(ytId);
                isYt = true;
            } else {
                playUrl = safePlayUrl(url);
            }

            if (playUrl != null) {
                if (title == null || title.isEmpty()) {
                    title = "Tập " + count;
                }
                episodes.add(new EpisodeItem(count, title, url, playUrl, isYt, ytId));
                count++;
            }
        }

        // If only 1 episode exists and the label was default "Tập 1", give it a friendly label "Bản đầy đủ"
        if (episodes.size() == 1 && "Tập 1".equals(episodes.get(0).getTitle()) && !rawVideoUrl.contains("Tập 1")) {
            EpisodeItem single = episodes.get(0);
            episodes.set(0, new EpisodeItem(1, "Bản đầy đủ", single.getRawUrl(), single.getPlayUrl(), single.isYoutube(), single.getYouTubeId()));
        }

        return Collections.unmodifiableList(episodes);
    }

    private static URI parseHttpUri(String url) {
        if (url == null) {
            return null;
        }
        String trimmed = url.trim();
        if (trimmed.isEmpty() || trimmed.length() > MAX_SINGLE_URL_LENGTH) {
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
