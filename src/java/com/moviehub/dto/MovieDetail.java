package com.moviehub.dto;

import java.io.Serializable;
import java.util.List;

/**
 * Read model for the public movie detail page.
 */
public class MovieDetail implements Serializable {

    private static final long serialVersionUID = 1L;

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
        this.categories = categories;
        this.categoryNames = new java.util.ArrayList<>();
        for (CategoryOption c : categories) {
            categoryNames.add(c.getName());
        }
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

    /** MP4 URL for the main video, or null when absent/not MP4. */
    public String getVideoUrl() {
        return videoUrl;
    }

    /** MP4 URL for the trailer, or null when absent/not MP4. */
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

    /** Main source: video, else trailer. */
    public String getPrimaryMediaUrl() {
        return videoUrl != null ? videoUrl : trailerUrl;
    }

    /** Fallback source offered only when the primary is the video and a trailer also exists. */
    public String getFallbackMediaUrl() {
        return videoUrl != null ? trailerUrl : null;
    }

    public boolean isHasMedia() {
        return getPrimaryMediaUrl() != null;
    }
}
