package com.moviehub.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Aggregated metrics DTO for the Executive Admin Analytics Dashboard (008-admin-analytics).
 * Enforces KPI-01 through KPI-09 and P1 category statistics.
 */
public class AdminDashboardDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    // KPI-01: Tổng phim (mọi trạng thái: DRAFT, PUBLISHED, HIDDEN)
    private long totalMovies;

    // KPI-02: Phim đang công khai (status = PUBLISHED)
    private long publishedMovies;

    // KPI-03: Người dùng (role USER, cả ACTIVE và INACTIVE, không tính ADMIN)
    private long totalUsers;

    // KPI-04: Tổng review chưa bỏ (deleted_at IS NULL, mọi status)
    private long totalReviews;

    // KPI-05: Tổng lượt mở chi tiết, mọi phim
    private long totalViews;

    // KPI-06: Lượt xem cao nhất / thấp nhất (null nếu không có phim -> "N/A")
    private Long maxViews;
    private Long minViews;

    // KPI-07: Điểm TB review đã duyệt, mọi phim (null nếu không có review approved -> "N/A")
    private Double averageRating;

    // KPI-08: Nội dung chờ duyệt (3 thành phần con và tổng cộng)
    private long pendingReviews;
    private long pendingQuestions;
    private long pendingAnswers;
    private long totalPending;

    // KPI-09: Top 5 phim theo lượt xem (mọi status, viewCount DESC, id DESC)
    private List<TopMovieDTO> topMovies = new ArrayList<>();

    // P1 FR-26: Phân bố số phim PUBLISHED theo từng thể loại chưa deleted
    private List<CategoryStatDTO> categoryStats = new ArrayList<>();

    public AdminDashboardDTO() {
    }

    public long getTotalMovies() {
        return totalMovies;
    }

    public void setTotalMovies(long totalMovies) {
        this.totalMovies = totalMovies;
    }

    public long getPublishedMovies() {
        return publishedMovies;
    }

    public void setPublishedMovies(long publishedMovies) {
        this.publishedMovies = publishedMovies;
    }

    public long getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(long totalUsers) {
        this.totalUsers = totalUsers;
    }

    public long getTotalReviews() {
        return totalReviews;
    }

    public void setTotalReviews(long totalReviews) {
        this.totalReviews = totalReviews;
    }

    public long getTotalViews() {
        return totalViews;
    }

    public void setTotalViews(long totalViews) {
        this.totalViews = totalViews;
    }

    public Long getMaxViews() {
        return maxViews;
    }

    public void setMaxViews(Long maxViews) {
        this.maxViews = maxViews;
    }

    public Long getMinViews() {
        return minViews;
    }

    public void setMinViews(Long minViews) {
        this.minViews = minViews;
    }

    public String getMaxViewsText() {
        return maxViews != null ? String.valueOf(maxViews) : "N/A";
    }

    public String getMinViewsText() {
        return minViews != null ? String.valueOf(minViews) : "N/A";
    }

    public Double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(Double averageRating) {
        this.averageRating = averageRating;
    }

    public String getAverageRatingText() {
        return averageRating != null ? String.format(Locale.US, "%.1f", averageRating) : "N/A";
    }

    public long getPendingReviews() {
        return pendingReviews;
    }

    public void setPendingReviews(long pendingReviews) {
        this.pendingReviews = pendingReviews;
    }

    public long getPendingQuestions() {
        return pendingQuestions;
    }

    public void setPendingQuestions(long pendingQuestions) {
        this.pendingQuestions = pendingQuestions;
    }

    public long getPendingAnswers() {
        return pendingAnswers;
    }

    public void setPendingAnswers(long pendingAnswers) {
        this.pendingAnswers = pendingAnswers;
    }

    public long getTotalPending() {
        return totalPending;
    }

    public void setTotalPending(long totalPending) {
        this.totalPending = totalPending;
    }

    public List<TopMovieDTO> getTopMovies() {
        return topMovies;
    }

    public void setTopMovies(List<TopMovieDTO> topMovies) {
        this.topMovies = topMovies != null ? topMovies : new ArrayList<>();
    }

    public List<CategoryStatDTO> getCategoryStats() {
        return categoryStats;
    }

    public void setCategoryStats(List<CategoryStatDTO> categoryStats) {
        this.categoryStats = categoryStats != null ? categoryStats : new ArrayList<>();
    }
}
