package com.moviehub.dto;

import com.moviehub.entity.User;
import java.io.Serializable;
import java.util.Date;

/** Account fields permitted in the administrative view. */
public final class AdminUserItem implements Serializable {
    private static final long serialVersionUID = 1L;
    private final Long id;
    private final String fullName, email, role, status;
    private final Date createdAt, updatedAt;
    private final Integer version;

    public AdminUserItem(User user) {
        id = user.getId(); fullName = user.getFullName(); email = user.getEmail();
        role = user.getRole(); status = user.getStatus(); version = user.getVersion();
        createdAt = user.getCreatedAt() == null ? null : Date.from(user.getCreatedAt());
        updatedAt = user.getUpdatedAt() == null ? null : Date.from(user.getUpdatedAt());
    }
    public Long getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getRole() { return role; }
    public String getStatus() { return status; }
    public Date getCreatedAt() { return createdAt == null ? null : new Date(createdAt.getTime()); }
    public Date getUpdatedAt() { return updatedAt == null ? null : new Date(updatedAt.getTime()); }
    public Integer getVersion() { return version; }
}
