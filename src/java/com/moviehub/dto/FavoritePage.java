package com.moviehub.dto;

import java.io.Serializable;
import java.util.Collections;
import java.util.List;

/**
 * Paginated view model for user favorites (FAV-AC-06).
 */
public class FavoritePage implements Serializable {

    private static final long serialVersionUID = 1L;

    private final List<MovieCard> items;
    private final int page;
    private final int totalPages;
    private final long totalCount;

    public FavoritePage(List<MovieCard> items, int page, int totalPages, long totalCount) {
        this.items = (items != null) ? Collections.unmodifiableList(items) : Collections.emptyList();
        this.page = page;
        this.totalPages = totalPages;
        this.totalCount = totalCount;
    }

    public List<MovieCard> getItems() {
        return items;
    }

    public int getPage() {
        return page;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public long getTotalCount() {
        return totalCount;
    }

    public boolean isHasItems() {
        return !items.isEmpty();
    }

    public boolean isHasPrevious() {
        return page > 1;
    }

    public boolean isHasNext() {
        return page < totalPages;
    }
}
