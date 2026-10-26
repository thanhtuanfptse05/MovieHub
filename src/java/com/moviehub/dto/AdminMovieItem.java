package com.moviehub.dto;

/** Safe administration form/view data; no persistence entities. */
public class AdminMovieItem {
    private Long id = null;
    private String title = null;
    private String slug = null;
    private String description = null;
    private Integer releaseYear = null;
    private Integer durationMinutes = null;
    private String posterUrl = null;
    private String videoUrl = null;
    private String trailerUrl = null;
    private String status = null;
    private boolean featured = false;
    private Integer version = null;
    private Long viewCount = null;
    private java.util.Date createdAt = null;
    private java.util.Date updatedAt = null;
    private java.util.List<Long> categoryIds = java.util.List.of();
    private java.util.List<String> categoryNames = java.util.List.of();
    public Long getId() { return id; }
    public void setId(Long value) { this.id = value; }
    public String getTitle() { return title; }
    public void setTitle(String value) { this.title = value; }
    public String getSlug() { return slug; }
    public void setSlug(String value) { this.slug = value; }
    public String getDescription() { return description; }
    public void setDescription(String value) { this.description = value; }
    public Integer getReleaseYear() { return releaseYear; }
    public void setReleaseYear(Integer value) { this.releaseYear = value; }
    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer value) { this.durationMinutes = value; }
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
    public Integer getVersion() { return version; }
    public void setVersion(Integer value) { this.version = value; }
    public Long getViewCount() { return viewCount; }
    public void setViewCount(Long value) { this.viewCount = value; }
    public java.util.Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.util.Date value) { this.createdAt = value; }
    public java.util.Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(java.util.Date value) { this.updatedAt = value; }
    public java.util.List<Long> getCategoryIds() { return categoryIds; }
    public void setCategoryIds(java.util.List<Long> value) { this.categoryIds = value; }
    public java.util.List<String> getCategoryNames() { return categoryNames; }
    public void setCategoryNames(java.util.List<String> value) { this.categoryNames = value; }
}
