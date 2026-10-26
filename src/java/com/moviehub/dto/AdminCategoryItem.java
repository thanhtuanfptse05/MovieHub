package com.moviehub.dto;

/** Safe administration form/view data; no persistence entities. */
public class AdminCategoryItem {
    private Long id = null;
    private String name = null;
    private String slug = null;
    private Integer version = null;
    private java.util.Date createdAt = null;
    public Long getId() { return id; }
    public void setId(Long value) { this.id = value; }
    public String getName() { return name; }
    public void setName(String value) { this.name = value; }
    public String getSlug() { return slug; }
    public void setSlug(String value) { this.slug = value; }
    public Integer getVersion() { return version; }
    public void setVersion(Integer value) { this.version = value; }
    public java.util.Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.util.Date value) { this.createdAt = value; }
}
