package com.moviehub.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Read model for a movie card (Home, list, similar). Rating is null when the movie has no public review.
 */
public class MovieCard implements Serializable {

    private static final long serialVersionUID = 1L;

    private final Long id;
    private final String title;
    private final Integer releaseYear;
    private final String posterUrl;
    private final Long viewCount;
    private final Double averageRating;
    private final long reviewCount;

    public MovieCard(Long id, String title, Integer releaseYear, String posterUrl,
                     Long viewCount, Double averageRating, long reviewCount) {
        this.id = id;
        this.title = title;
        this.releaseYear = releaseYear;
        this.posterUrl = posterUrl;
        this.viewCount = viewCount;
        this.averageRating = reviewCount > 0 ? averageRating : null;
        this.reviewCount = reviewCount;
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public Integer getReleaseYear() {
        return releaseYear;
    }

    public String getPosterUrl() {
        return posterUrl;
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

    /** One decimal place, HALF_UP; empty string when unrated. */
    public String getRatingText() {
        return formatRating(averageRating);
    }

    public static String formatRating(Double value) {
        if (value == null) {
            return "";
        }
        return BigDecimal.valueOf(value).setScale(1, RoundingMode.HALF_UP).toPlainString();
    }
}
