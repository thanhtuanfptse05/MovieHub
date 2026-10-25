package com.moviehub.dto;

import java.io.Serializable;

/**
 * Simple id/name pair for dropdowns and category chips.
 */
public class CategoryOption implements Serializable {

    private static final long serialVersionUID = 1L;

    private final Long id;
    private final String name;

    public CategoryOption(Long id, String name) {
        this.id = id;
        this.name = name;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}
