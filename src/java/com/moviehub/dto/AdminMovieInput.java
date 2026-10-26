package com.moviehub.dto;

/** Safe administration form/view data; no persistence entities. */
public class AdminMovieInput {
    private String title = null;
    private String slug = null;
    private String description = null;
    private String releaseYear = null;
    private String durationMinutes = null;
    private String posterUrl = null;
    private String videoUrl = null;
    private String trailerUrl = null;
    private String status = "DRAFT";
    private boolean featured = false;
    private String[] categoryIds = new String[0];
    public String getTitle() { return title; }
    public void setTitle(String value) { this.title = value; }
    public String getSlug() { return slug; }
    public void setSlug(String value) { this.slug = value; }
    public String getDescription() { return description; }
    public void setDescription(String value) { this.description = value; }
    public String getReleaseYear() { return releaseYear; }
    public void setReleaseYear(String value) { this.releaseYear = value; }
    public String getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(String value) { this.durationMinutes = value; }
    public String getPosterUrl() { return posterUrl; }
    public void setPosterUrl(String value) { this.posterUrl = value; }
    public String getVideoUrl() { return videoUrl; }
    public void setVideoUrl(String value) { this.videoUrl = value; }
    public String getTrailerUrl() { return trailerUrl; }
    public void setTrailerUrl(String value) { this.trailerUrl = value; }
    public String getStatus() { return status; }
    public void setStatus(String value) { this.status = value; }
    public boolean isFeatured() { return featured; }
    public void setFeatured(boolean value) { this.featured = value; }
    public String[] getCategoryIds() { return categoryIds; }
    public void setCategoryIds(String[] value) { this.categoryIds = value; }
}
