package com.moviehub.dto;

import java.io.Serializable;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

/**
 * DTO for displaying a review in public or author views.
 */
public class ReviewItem implements Serializable {

    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")
            .withZone(ZoneId.of("Asia/Ho_Chi_Minh"));

    private Long id;
    private Long userId;
    private Long movieId;
    private String authorName;
    private String authorAvatarUrl;
    private Integer rating;
    private String content;
    private String status;
    private Instant createdAt;
    private Instant updatedAt;
    private Integer version;

    public ReviewItem() {
    }

    public ReviewItem(Long id, Long userId, Long movieId, String authorName, String authorAvatarUrl,
                      Integer rating, String content, String status, Instant createdAt, Instant updatedAt,
                      Integer version) {
        this.id = id;
        this.userId = userId;
        this.movieId = movieId;
        this.authorName = authorName;
        this.authorAvatarUrl = authorAvatarUrl;
        this.rating = rating;
        this.content = content;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.version = version;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getMovieId() {
        return movieId;
    }

    public void setMovieId(Long movieId) {
        this.movieId = movieId;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public String getAuthorAvatarUrl() {
        return authorAvatarUrl;
    }

    public void setAuthorAvatarUrl(String authorAvatarUrl) {
        this.authorAvatarUrl = authorAvatarUrl;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getVersion() {
        return version;
    }

    public void setVersion(Integer version) {
        this.version = version;
    }

    public String getFormattedDate() {
        if (createdAt == null) {
            return "";
        }
        return DATE_FORMATTER.format(createdAt);
    }

    public String getStatusBadge() {
        if ("APPROVED".equals(status)) {
            return "Đã duyệt";
        } else if ("REJECTED".equals(status)) {
            return "Bị từ chối";
        }
        return "Chờ duyệt";
    }
}
