package com.moviehub.dto;

import java.io.Serializable;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Validated catalog filter. Built via {@link com.moviehub.service.MovieService#parseQuery}.
 */
public class CatalogQuery implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String SORT_NEWEST = "newest";
    public static final String SORT_VIEWS = "views";
    public static final String SORT_RATING = "rating";
    public static final String SORT_TITLE = "title";

    private String q = "";
    private Long categoryId;
    private Integer year;
    private String sort = SORT_NEWEST;
    private int page = 1;
    private final Map<String, String> errors = new LinkedHashMap<>();

    /** Raw values echoed back to the form (also when invalid). */
    private String rawCategory = "";
    private String rawYear = "";

    public String getQ() {
        return q;
    }

    public void setQ(String q) {
        this.q = q;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public String getSort() {
        return sort;
    }

    public void setSort(String sort) {
        this.sort = sort;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public String getRawCategory() {
        return rawCategory;
    }

    public void setRawCategory(String rawCategory) {
        this.rawCategory = rawCategory;
    }

    public String getRawYear() {
        return rawYear;
    }

    public void setRawYear(String rawYear) {
        this.rawYear = rawYear;
    }

    public Map<String, String> getErrors() {
        return Collections.unmodifiableMap(errors);
    }

    public void addError(String field, String message) {
        errors.putIfAbsent(field, message);
    }

    public boolean isValid() {
        return errors.isEmpty();
    }
}
