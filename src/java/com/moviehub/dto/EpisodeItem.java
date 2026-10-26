package com.moviehub.dto;

import java.io.Serializable;

/**
 * Represents a single playable episode or video part of a movie.
 */
public class EpisodeItem implements Serializable {

    private static final long serialVersionUID = 1L;

    private final int number;
    private final String title;
    private final String rawUrl;
    private final String playUrl;
    private final boolean youtube;
    private final String youTubeId;

    public EpisodeItem(int number, String title, String rawUrl, String playUrl, boolean youtube, String youTubeId) {
        this.number = number;
        this.title = title != null && !title.trim().isEmpty() ? title.trim() : ("Tập " + number);
        this.rawUrl = rawUrl != null ? rawUrl.trim() : "";
        this.playUrl = playUrl != null ? playUrl.trim() : "";
        this.youtube = youtube;
        this.youTubeId = youTubeId;
    }

    public int getNumber() {
        return number;
    }

    public String getTitle() {
        return title;
    }

    public String getRawUrl() {
        return rawUrl;
    }

    public String getPlayUrl() {
        return playUrl;
    }

    public boolean isYoutube() {
        return youtube;
    }

    public String getYouTubeId() {
        return youTubeId;
    }

    @Override
    public String toString() {
        return "EpisodeItem{number=" + number + ", title='" + title + "', youtube=" + youtube + "}";
    }
}
