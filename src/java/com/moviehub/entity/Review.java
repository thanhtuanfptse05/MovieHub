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
 * Review entity representing a user review and rating for a movie.
 * Enforces unique constraint (user_id, movie_id) with soft-deletion support.
 */
@Entity
@Table(name = "Reviews")
public class Review implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_APPROVED = "APPROVED";
    public static final String STATUS_REJECTED = "REJECTED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "movie_id", nullable = false)
    private Long movieId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "movie_id", insertable = false, updatable = false)
    private Movie movie;

    @Column(name = "rating", nullable = false)
    private Integer rating;

    @Column(name = "content", nullable = false, length = 1000)
    private String content;

    @Column(name = "status", nullable = false, length = 10)
    private String status = STATUS_PENDING;

    @Column(name = "moderated_by")
    private Long moderatedBy;

    @Column(name = "moderated_at")
    private Instant moderatedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "deleted_at")
    private Instant deletedAt;

    @Version
    @Column(name = "version", nullable = false)
    private Integer version = 1;

    @Column(name = "content_revision", nullable = false)
    private Integer contentRevision = 1;

    public Review() {
    }

    public Review(Long userId, Long movieId, Integer rating, String content) {
        this.userId = userId;
        this.movieId = movieId;
        this.rating = rating;
        this.content = content;
        this.status = STATUS_PENDING;
        this.createdAt = Instant.now();
        this.updatedAt = this.createdAt;
        this.version = 1;
        this.contentRevision = 1;
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

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Instant getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(Instant deletedAt) {
        this.deletedAt = deletedAt;
    }

    public Integer getVersion() {
        return version;
    }

    public void setVersion(Integer version) {
        this.version = version;
    }

    public Integer getContentRevision() {
        return contentRevision;
    }

    public void setContentRevision(Integer contentRevision) {
        this.contentRevision = contentRevision;
    }

    public boolean isActive() {
        return deletedAt == null;
    }

    public boolean isApproved() {
        return STATUS_APPROVED.equals(status) && isActive();
    }

    public boolean isPending() {
        return STATUS_PENDING.equals(status) && isActive();
    }

    public boolean isRejected() {
        return STATUS_REJECTED.equals(status) && isActive();
    }
}
