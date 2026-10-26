package com.moviehub.dto;

import java.io.Serializable;
import java.time.Instant;
import java.util.Date;

/** Plain content and context only; no author credentials or managed entities. */
public final class AdminModerationItem implements Serializable {
    private static final long serialVersionUID = 1L;
    private final String type, authorName, movieTitle, movieStatus;
    private final String questionContent, questionStatus, content, status;
    private final Long id, movieId, questionId;
    private final Integer rating, version, contentRevision;
    private final Instant createdAt;

    public AdminModerationItem(String type, Long id, String authorName, Long movieId,
            String movieTitle, String movieStatus, Long questionId, String questionContent,
            String questionStatus, String content, Integer rating, String status,
            Instant createdAt, Integer version, Integer contentRevision) {
        this.type = type; this.id = id; this.authorName = authorName; this.movieId = movieId;
        this.movieTitle = movieTitle; this.movieStatus = movieStatus; this.questionId = questionId;
        this.questionContent = questionContent; this.questionStatus = questionStatus;
        this.content = content; this.rating = rating; this.status = status;
        this.createdAt = createdAt; this.version = version; this.contentRevision = contentRevision;
    }
    public String getType() { return type; }
    public Long getId() { return id; }
    public String getAuthorName() { return authorName; }
    public Long getMovieId() { return movieId; }
    public String getMovieTitle() { return movieTitle; }
    public String getMovieStatus() { return movieStatus; }
    public Long getQuestionId() { return questionId; }
    public String getQuestionContent() { return questionContent; }
    public String getQuestionStatus() { return questionStatus; }
    public String getContent() { return content; }
    public Integer getRating() { return rating; }
    public String getStatus() { return status; }
    public Date getCreatedAt() { return createdAt == null ? null : Date.from(createdAt); }
    public Instant getCreatedAtInstant() { return createdAt; }
    public Integer getVersion() { return version; }
    public Integer getContentRevision() { return contentRevision; }
    public boolean isApproveAllowed() {
        return "PUBLISHED".equals(movieStatus) && (!"answer".equals(type) || "APPROVED".equals(questionStatus));
    }
    public String getApproveBlockedReason() {
        if (!"PUBLISHED".equals(movieStatus)) return "Phim chưa được xuất bản.";
        if ("answer".equals(type) && !"APPROVED".equals(questionStatus)) return "Câu hỏi chưa được duyệt.";
        return "";
    }
}
