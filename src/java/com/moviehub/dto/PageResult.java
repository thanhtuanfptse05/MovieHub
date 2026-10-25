package com.moviehub.dto;

import java.io.Serializable;
import java.util.Collections;
import java.util.List;

/**
 * One page of results with SYS-03 pagination metadata.
 */
public class PageResult<T> implements Serializable {

    private static final long serialVersionUID = 1L;
    public static final int PAGE_SIZE = 10;

    private final List<T> items;
    private final long total;
    private final int page;
    private final int totalPages;

    public PageResult(List<T> items, long total, int page, int totalPages) {
        this.items = items == null ? Collections.<T>emptyList() : items;
        this.total = total;
        this.page = page;
        this.totalPages = totalPages;
    }

    public static int totalPagesFor(long total) {
        return (int) ((total + PAGE_SIZE - 1) / PAGE_SIZE);
    }

    /** SYS-03: page beyond the last page resolves to the last; empty set resolves to page 1. */
    public static int clampPage(int requested, int totalPages) {
        if (totalPages <= 0) {
            return 1;
        }
        return Math.min(Math.max(requested, 1), totalPages);
    }

    public List<T> getItems() {
        return items;
    }

    public long getTotal() {
        return total;
    }

    public int getPage() {
        return page;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public boolean isHasPrevious() {
        return totalPages > 0 && page > 1;
    }

    public boolean isHasNext() {
        return totalPages > 0 && page < totalPages;
    }
}
