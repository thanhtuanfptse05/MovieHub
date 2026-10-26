package com.moviehub.dto;

import java.io.Serializable;

/**
 * DTO representing a top movie in the analytics dashboard (KPI-09).
 */
public class TopMovieDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private String title;
    private Integer releaseYear;
    private String status;
    private long viewCount;

    public TopMovieDTO() {
    }

    public TopMovieDTO(Long id, String title, Integer releaseYear, String status, long viewCount) {
        this.id = id;
        this.title = title;
        this.releaseYear = releaseYear;
        this.status = status;
        this.viewCount = viewCount;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Integer getReleaseYear() {
        return releaseYear;
    }

    public void setReleaseYear(Integer releaseYear) {
        this.releaseYear = releaseYear;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public long getViewCount() {
        return viewCount;
    }

    public void setViewCount(long viewCount) {
        this.viewCount = viewCount;
    }
}
