package com.moviehub.service;

import java.io.Serializable;

/**
 * Value object holding transient password reset context in the HTTP session (R-01).
 * Binds selected active account to subsequent reset step within the same session.
 */
public class ResetContext implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String SESSION_KEY = "moviehub_reset_context";

    private final Long targetUserId;
    private final String targetEmail;
    private final int expectedCredentialsVersion;
    private final int flowVersion;
    private final long createdAtMillis;

    public ResetContext(Long targetUserId, String targetEmail, int expectedCredentialsVersion, int flowVersion) {
        this.targetUserId = targetUserId;
        this.targetEmail = targetEmail;
        this.expectedCredentialsVersion = expectedCredentialsVersion;
        this.flowVersion = flowVersion;
        this.createdAtMillis = System.currentTimeMillis();
    }

    public Long getTargetUserId() {
        return targetUserId;
    }

    public String getTargetEmail() {
        return targetEmail;
    }

    public int getExpectedCredentialsVersion() {
        return expectedCredentialsVersion;
    }

    public int getFlowVersion() {
        return flowVersion;
    }

    public long getCreatedAtMillis() {
        return createdAtMillis;
    }
}
