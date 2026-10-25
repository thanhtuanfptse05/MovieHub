package com.moviehub.dto;

import java.io.Serializable;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

/**
 * DTO for displaying a question in community discussions.
 */
public class QuestionItem implements Serializable {

    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")
            .withZone(ZoneId.of("Asia/Ho_Chi_Minh"));

    private Long id;
    private Long movieId;
    private Long userId;
    private String authorName;
    private String authorAvatarUrl;
    private String content;
    private String status;
    private Instant createdAt;
    private long answerCount;

    public QuestionItem() {
    }

    public QuestionItem(Long id, Long movieId, Long userId, String authorName, String authorAvatarUrl,
                        String content, String status, Instant createdAt, long answerCount) {
        this.id = id;
        this.movieId = movieId;
        this.userId = userId;
        this.authorName = authorName;
        this.authorAvatarUrl = authorAvatarUrl;
        this.content = content;
        this.status = status;
        this.createdAt = createdAt;
        this.answerCount = answerCount;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getMovieId() {
        return movieId;
    }

    public void setMovieId(Long movieId) {
        this.movieId = movieId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
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

    public long getAnswerCount() {
        return answerCount;
    }

    public void setAnswerCount(long answerCount) {
        this.answerCount = answerCount;
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
