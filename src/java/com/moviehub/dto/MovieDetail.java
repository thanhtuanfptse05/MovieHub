package com.moviehub.dto;

import com.moviehub.util.MediaUrlUtil;
import java.io.Serializable;
import java.util.Collections;
import java.util.List;

/**
 * Read model for the public movie detail page, supporting direct playback,
 * YouTube embeds, and multi-episode series.
 */
public class MovieDetail implements Serializable {

    private static final long serialVersionUID = 2L;

    private final Long id;
    private final String title;
    private final String description;
    private final Integer releaseYear;
    private final Integer durationMinutes;
    private final String posterUrl;
    private final String videoUrl;
    private final String trailerUrl;
    private final Long viewCount;
    private final Double averageRating;
    private final long reviewCount;
    private final List<String> categoryNames;
    private final List<CategoryOption> categories;
    private final List<EpisodeItem> episodes;
    private final String trailerPlayUrl;
    private final boolean trailerYouTube;

    public MovieDetail(Long id, String title, String description, Integer releaseYear, Integer durationMinutes,
                       String posterUrl, String videoUrl, String trailerUrl, Long viewCount,
                       Double averageRating, long reviewCount, List<CategoryOption> categories) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.releaseYear = releaseYear;
        this.durationMinutes = durationMinutes;
        this.posterUrl = posterUrl;
        this.videoUrl = videoUrl;
        this.trailerUrl = trailerUrl;
        this.viewCount = viewCount;
        this.averageRating = reviewCount > 0 ? averageRating : null;
        this.reviewCount = reviewCount;
        this.categories = categories != null ? categories : Collections.emptyList();
        this.categoryNames = new java.util.ArrayList<>();
        for (CategoryOption c : this.categories) {
            categoryNames.add(c.getName());
        }

        this.episodes = MediaUrlUtil.parseEpisodes(videoUrl);
        this.trailerPlayUrl = MediaUrlUtil.safePlayUrl(trailerUrl);
        this.trailerYouTube = MediaUrlUtil.isYouTubeUrl(trailerUrl);
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public Integer getReleaseYear() {
        return releaseYear;
    }

    public Integer getDurationMinutes() {
        return durationMinutes;
    }

    public String getPosterUrl() {
        return posterUrl;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public String getTrailerUrl() {
        return trailerUrl;
    }

    public Long getViewCount() {
        return viewCount;
    }

    public Double getAverageRating() {
        return averageRating;
    }

    public long getReviewCount() {
        return reviewCount;
    }

    public boolean isRated() {
        return averageRating != null;
    }

    public String getRatingText() {
        return MovieCard.formatRating(averageRating);
    }

    public List<CategoryOption> getCategories() {
        return categories;
    }

    public List<String> getCategoryNames() {
        return categoryNames;
    }

    public List<EpisodeItem> getEpisodes() {
        return episodes;
    }

    public boolean isMultiEpisode() {
        return episodes.size() > 1;
    }

    public int getEpisodeCount() {
        return episodes.size();
    }

    public EpisodeItem getDefaultEpisode() {
        return episodes.isEmpty() ? null : episodes.get(0);
    }

    public EpisodeItem getEpisodeByNumber(Integer epNumber) {
        if (episodes.isEmpty()) {
            return null;
        }
        if (epNumber == null || epNumber <= 0 || epNumber > episodes.size()) {
            return episodes.get(0);
        }
        return episodes.get(epNumber - 1);
    }

    public String getTrailerPlayUrl() {
        return trailerPlayUrl;
    }

    public boolean isTrailerYouTube() {
        return trailerYouTube;
    }

    public boolean getTrailerYouTube() {
        return trailerYouTube;
    }

    public boolean isHasTrailer() {
        return trailerPlayUrl != null && !trailerPlayUrl.isEmpty();
    }

    public boolean getHasTrailer() {
        return isHasTrailer();
    }

    /** Main source: default episode play URL, else trailer play URL. */
    public String getPrimaryMediaUrl() {
        EpisodeItem def = getDefaultEpisode();
        if (def != null) {
            return def.getPlayUrl();
        }
        return trailerPlayUrl;
    }

    /** Fallback source: trailer play URL if different from primary. */
    public String getFallbackMediaUrl() {
        EpisodeItem def = getDefaultEpisode();
        if (def != null && isHasTrailer()) {
            return trailerPlayUrl;
        }
        return null;
    }

    public boolean isHasMedia() {
        return !episodes.isEmpty() || isHasTrailer();
    }
}
