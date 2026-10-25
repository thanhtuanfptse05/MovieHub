package com.moviehub.util;

import com.moviehub.exception.ConflictException;
import jakarta.servlet.http.HttpSession;
import java.io.Serializable;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

/**
 * In-session submission nonce manager for idempotent forms (006-qa, SYS-05).
 * Prevents double-clicks and replay attacks within user session.
 */
public final class SubmissionNonceUtil {

    private static final String SESSION_NONCE_MAP = "MOVIEHUB_SUBMISSION_NONCES";
    private static final int MAX_NONCES_PER_SESSION = 50;

    public static final String TYPE_QUESTION = "QUESTION";
    public static final String TYPE_ANSWER = "ANSWER";

    private SubmissionNonceUtil() {
    }

    public static class NonceRecord implements Serializable {
        private static final long serialVersionUID = 1L;

        private final String submissionId;
        private final Long userId;
        private final String type;
        private final Long targetId;
        private volatile boolean committed = false;
        private volatile String redirectUrl;
        private volatile Long createdEntityId;

        public NonceRecord(String submissionId, Long userId, String type, Long targetId) {
            this.submissionId = submissionId;
            this.userId = userId;
            this.type = type;
            this.targetId = targetId;
        }

        public String getSubmissionId() {
            return submissionId;
        }

        public Long getUserId() {
            return userId;
        }

        public String getType() {
            return type;
        }

        public Long getTargetId() {
            return targetId;
        }

        public boolean isCommitted() {
            return committed;
        }

        public String getRedirectUrl() {
            return redirectUrl;
        }

        public Long getCreatedEntityId() {
            return createdEntityId;
        }

        public synchronized void markCommitted(String redirectUrl, Long createdEntityId) {
            this.committed = true;
            this.redirectUrl = redirectUrl;
            this.createdEntityId = createdEntityId;
        }
    }

    @SuppressWarnings("unchecked")
    private static Map<String, NonceRecord> getNonceMap(HttpSession session) {
        if (session == null) {
            return null;
        }
        synchronized (session) {
            Map<String, NonceRecord> map = (Map<String, NonceRecord>) session.getAttribute(SESSION_NONCE_MAP);
            if (map == null) {
                map = Collections.synchronizedMap(new LinkedHashMap<String, NonceRecord>(16, 0.75f, true) {
                    private static final long serialVersionUID = 1L;
                    @Override
                    protected boolean removeEldestEntry(Map.Entry<String, NonceRecord> eldest) {
                        return size() > MAX_NONCES_PER_SESSION;
                    }
                });
                session.setAttribute(SESSION_NONCE_MAP, map);
            }
            return map;
        }
    }

    /**
     * Generates a new nonce for an actor, type and target ID.
     */
    public static String generateNonce(HttpSession session, Long userId, String type, Long targetId) {
        if (session == null || userId == null || type == null || targetId == null) {
            return "";
        }
        Map<String, NonceRecord> map = getNonceMap(session);
        String submissionId = UUID.randomUUID().toString();
        NonceRecord record = new NonceRecord(submissionId, userId, type, targetId);
        map.put(submissionId, record);
        return submissionId;
    }

    /**
     * Validates that the nonce exists, matches the user, type, and target ID.
     * Throws ConflictException (409) if invalid or expired.
     */
    public static NonceRecord validateNonce(HttpSession session, String submissionId, Long userId, String type, Long targetId) {
        if (session == null || submissionId == null || submissionId.trim().isEmpty()) {
            throw new ConflictException("Phiên gửi không hợp lệ hoặc đã hết hạn. Vui lòng tải lại trang.");
        }
        Map<String, NonceRecord> map = getNonceMap(session);
        NonceRecord record = map.get(submissionId.trim());
        if (record == null) {
            throw new ConflictException("Phiên gửi không hợp lệ hoặc đã hết hạn. Vui lòng tải lại trang.");
        }
        if (!Objects.equals(record.getUserId(), userId)
                || !Objects.equals(record.getType(), type)
                || !Objects.equals(record.getTargetId(), targetId)) {
            throw new ConflictException("Yêu cầu gửi không khớp với phiên làm việc. Vui lòng tải lại trang.");
        }
        return record;
    }
}
