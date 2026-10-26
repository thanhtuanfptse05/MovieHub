package com.moviehub.dto;

import java.io.Serializable;

/**
 * DTO representing movie count per category for analytics breakdown (P1 / FR-26).
 */
public class CategoryStatDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long categoryId;
    private String name;
    private long movieCount;

    public CategoryStatDTO() {
    }

    public CategoryStatDTO(Long categoryId, String name, long movieCount) {
        this.categoryId = categoryId;
        this.name = name;
        this.movieCount = movieCount;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public long getMovieCount() {
        return movieCount;
    }

    public void setMovieCount(long movieCount) {
        this.movieCount = movieCount;
    }
}
