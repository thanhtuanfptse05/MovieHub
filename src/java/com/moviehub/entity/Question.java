package com.moviehub.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import java.io.Serializable;
import java.time.Instant;

/**
 * Question entity representing a user question on a specific movie.
 */
@Entity
@Table(name = "Questions")
public class Question implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_APPROVED = "APPROVED";
    public static final String STATUS_REJECTED = "REJECTED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "movie_id", nullable = false)
    private Long movieId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "movie_id", insertable = false, updatable = false)
    private Movie movie;

    @Column(name = "content", nullable = false, length = 500)
    private String content;

    @Column(name = "status", nullable = false, length = 10)
    private String status = STATUS_PENDING;

    @Column(name = "moderated_by")
    private Long moderatedBy;

    @Column(name = "moderated_at")
    private Instant moderatedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Version
    @Column(name = "version", nullable = false)
    private Integer version = 1;

    public Question() {
    }

    public Question(Long movieId, Long userId, String content) {
        this.movieId = movieId;
        this.userId = userId;
        this.content = content;
        this.status = STATUS_PENDING;
        this.createdAt = Instant.now();
        this.version = 1;
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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Movie getMovie() {
        return movie;
    }

    public void setMovie(Movie movie) {
        this.movie = movie;
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

    public Long getModeratedBy() {
        return moderatedBy;
    }

    public void setModeratedBy(Long moderatedBy) {
        this.moderatedBy = moderatedBy;
    }

    public Instant getModeratedAt() {
        return moderatedAt;
    }

    public void setModeratedAt(Instant moderatedAt) {
        this.moderatedAt = moderatedAt;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getVersion() {
        return version;
    }

    public void setVersion(Integer version) {
        this.version = version;
    }

    public boolean isApproved() {
        return STATUS_APPROVED.equals(status);
    }

    public boolean isPending() {
        return STATUS_PENDING.equals(status);
    }

    public boolean isRejected() {
        return STATUS_REJECTED.equals(status);
    }
}
