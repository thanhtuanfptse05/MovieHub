package com.moviehub.dto;

/** Safe administration form/view data; no persistence entities. */
public class AdminCatalogQuery {
    private String q = "";
    private String status = null;
    private int page = 1;
    private final java.util.Map<String,String> errors = new java.util.LinkedHashMap<>();
    public java.util.Map<String,String> getErrors() { return errors; }
    public boolean isValid() { return errors.isEmpty(); }
    public String getQ() { return q; }
    public void setQ(String value) { this.q = value; }
    public String getStatus() { return status; }
    public void setStatus(String value) { this.status = value; }
    public int getPage() { return page; }
    public void setPage(int value) { this.page = value; }
}
