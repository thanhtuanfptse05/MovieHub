package com.moviehub.dto;

import java.io.Serializable;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

/**
 * DTO for displaying user's own submitted questions and answers (private view).
 */
public class MyQaItem implements Serializable {

    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")
            .withZone(ZoneId.of("Asia/Ho_Chi_Minh"));

    public static final String TYPE_QUESTION = "QUESTION";
    public static final String TYPE_ANSWER = "ANSWER";

    private Long id;
    private String type; // "QUESTION" or "ANSWER"
    private Long targetId; // movieId for Question, questionId for Answer
    private String questionTitle; // parent question content or notice if non-public
    private String content;
    private String status;
    private Instant createdAt;
    private boolean isParentPublic;

    public MyQaItem() {
    }

    public MyQaItem(Long id, String type, Long targetId, String questionTitle, String content,
                    String status, Instant createdAt, boolean isParentPublic) {
        this.id = id;
        this.type = type;
        this.targetId = targetId;
        this.questionTitle = questionTitle;
        this.content = content;
        this.status = status;
        this.createdAt = createdAt;
        this.isParentPublic = isParentPublic;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Long getTargetId() {
        return targetId;
    }

    public void setTargetId(Long targetId) {
        this.targetId = targetId;
    }

    public String getQuestionTitle() {
        return questionTitle;
    }

    public void setQuestionTitle(String questionTitle) {
        this.questionTitle = questionTitle;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isParentPublic() {
        return isParentPublic;
    }

    public void setParentPublic(boolean parentPublic) {
        isParentPublic = parentPublic;
    }

    public boolean isQuestion() {
        return TYPE_QUESTION.equals(type);
    }

    public boolean isAnswer() {
        return TYPE_ANSWER.equals(type);
    }

    public String getTypeLabel() {
        return isQuestion() ? "Câu hỏi" : "Câu trả lời";
    }

    public String getFormattedDate() {
        if (createdAt == null) {
            return "";
        }
        return DATE_FORMATTER.format(createdAt);
    }

    public String getStatusBadge() {
        if ("APPROVED".equals(status)) {
            return "Đã duyệt";
        } else if ("REJECTED".equals(status)) {
            return "Bị từ chối";
        }
        return "Chờ duyệt";
    }
}
