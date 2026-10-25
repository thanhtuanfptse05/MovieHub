package com.moviehub.dto;

import java.io.Serializable;
import java.util.Collections;
import java.util.List;

/**
 * Paginated container for user's personal Q&A submissions.
 */
public class MyQaPage implements Serializable {

    private static final long serialVersionUID = 1L;

    private List<MyQaItem> items;
    private int page;
    private int pageSize;
    private int totalPages;
    private long totalCount;

    public MyQaPage() {
        this.items = Collections.emptyList();
        this.page = 1;
        this.pageSize = 10;
        this.totalPages = 0;
        this.totalCount = 0;
    }

    public MyQaPage(List<MyQaItem> items, int page, int pageSize, long totalCount) {
        this.items = items != null ? items : Collections.emptyList();
        this.page = page;
        this.pageSize = pageSize;
        this.totalCount = totalCount;
        this.totalPages = pageSize > 0 ? (int) Math.ceil((double) totalCount / pageSize) : 0;
    }

    public List<MyQaItem> getItems() {
        return items;
    }

    public void setItems(List<MyQaItem> items) {
        this.items = items != null ? items : Collections.emptyList();
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }

    public long getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(long totalCount) {
        this.totalCount = totalCount;
    }

    public boolean hasPrevious() {
        return page > 1;
    }

    public boolean isHasPrevious() {
        return page > 1;
    }

    public boolean hasNext() {
        return page < totalPages;
    }

    public boolean isHasNext() {
        return page < totalPages;
    }

    public boolean isHasItems() {
        return items != null && !items.isEmpty();
    }
}
