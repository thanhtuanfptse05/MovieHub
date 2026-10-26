package com.moviehub.dto;

/** Safe administration form/view data; no persistence entities. */
public class AdminCategoryInput {
    private String name = null;
    private String slug = null;
    public String getName() { return name; }
    public void setName(String value) { this.name = value; }
    public String getSlug() { return slug; }
    public void setSlug(String value) { this.slug = value; }
}
