package com.moviehub.service;

import com.moviehub.dao.AdminModerationDAO;
import com.moviehub.dto.AdminModerationItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.Answer;
import com.moviehub.entity.Movie;
import com.moviehub.entity.Question;
import com.moviehub.entity.Review;
import com.moviehub.entity.User;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.ForbiddenException;
import com.moviehub.exception.NotFoundException;
import jakarta.persistence.EntityManager;
import java.time.Clock;
import java.time.Instant;
import java.util.Objects;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AdminModerationService {
    private static final Logger LOGGER = Logger.getLogger(AdminModerationService.class.getName());
    private final AdminModerationDAO dao;
    private final Clock clock;
    public AdminModerationService() { this(new AdminModerationDAO(), Clock.systemUTC()); }
    public AdminModerationService(AdminModerationDAO dao, Clock clock) { this.dao = dao; this.clock = clock; }

    public PageResult<AdminModerationItem> list(String rawType, String rawStatus, int page) {
        String type = rawType == null || rawType.trim().isEmpty() ? "all" : rawType.trim();
        String status = rawStatus == null || rawStatus.trim().isEmpty() ? "PENDING" : rawStatus.trim();
        validateType(type, true);
        if (!"PENDING".equals(status) && !"APPROVED".equals(status) && !"REJECTED".equals(status)) throw new IllegalArgumentException("Trạng thái duyệt không hợp lệ.");
        return dao.read(em -> dao.list(em, type, status, page));
    }

    /** Returns false only when the current content already has the requested decision. */
    public boolean decide(Long actorId, String type, Long id, String action, Integer version, Integer contentRevision) {
        Decision decision = dao.write(actorId, em -> {
            User actor = dao.findUser(em, actorId);
            if (actor == null || !User.ROLE_ADMIN.equals(actor.getRole()) || !User.STATUS_ACTIVE.equals(actor.getStatus())) {
                throw new ForbiddenException("Bạn không có quyền thực hiện thao tác này.");
            }
            validateType(type, false);
            if (!"APPROVE".equals(action) && !"REJECT".equals(action)) throw new IllegalArgumentException("Thao tác duyệt không hợp lệ.");
            if (version == null || version < 0 || contentRevision == null || contentRevision < 1) throw new IllegalArgumentException("Phiên bản nội dung không hợp lệ.");
            String target = "APPROVE".equals(action) ? "APPROVED" : "REJECTED";
            Instant now = clock.instant();
            if ("review".equals(type)) {
                Review review = dao.findReview(em, id);
                if (review == null) throw new NotFoundException("Đánh giá không tồn tại.");
                if (review.getDeletedAt() != null) throw conflict();
                requireMovie(em, review.getMovieId(), target);
                if (!needsChange(review.getStatus(), target, review.getVersion(), version, review.getContentRevision(), contentRevision)) return null;
                String previous = review.getStatus();
                review.setStatus(target); review.setModeratedBy(actorId); review.setModeratedAt(now); review.setUpdatedAt(now);
                em.flush();
                return new Decision(previous, target, now);
            }
            if ("question".equals(type)) {
                Question question = dao.findQuestion(em, id);
                if (question == null) throw new NotFoundException("Câu hỏi không tồn tại.");
                requireMovie(em, question.getMovieId(), target);
                if (!needsChange(question.getStatus(), target, question.getVersion(), version, 1, contentRevision)) return null;
                String previous = question.getStatus();
                question.setStatus(target); question.setModeratedBy(actorId); question.setModeratedAt(now);
                em.flush();
                return new Decision(previous, target, now);
            }
            Answer answer = dao.findAnswer(em, id);
            if (answer == null) throw new NotFoundException("Câu trả lời không tồn tại.");
            Question question = dao.findQuestion(em, answer.getQuestionId());
            if (question == null) throw conflict();
            requireMovie(em, question.getMovieId(), target);
            if ("APPROVED".equals(target) && !Question.STATUS_APPROVED.equals(question.getStatus())) throw conflict();
            if (!needsChange(answer.getStatus(), target, answer.getVersion(), version, 1, contentRevision)) return null;
            String previous = answer.getStatus();
            answer.setStatus(target); answer.setModeratedBy(actorId); answer.setModeratedAt(now);
            em.flush();
            return new Decision(previous, target, now);
        });
        // Log only after commit and never include request content or credentials.
        if (decision == null) return false;
        LOGGER.log(Level.INFO, "Moderation actor={0} action={1} type={2} id={3} previous={4} status={5} at={6}",
                new Object[]{actorId, action, type, id, decision.previous, decision.target, decision.at});
        return true;
    }
    private void requireMovie(EntityManager em, Long movieId, String target) {
        Movie movie = dao.findMovie(em, movieId);
        if (movie == null || ("APPROVED".equals(target) && !Movie.STATUS_PUBLISHED.equals(movie.getStatus()))) throw conflict();
    }
    private static boolean needsChange(String current, String target, Integer currentVersion,
            Integer version, Integer currentRevision, Integer contentRevision) {
        if (!Objects.equals(currentRevision, contentRevision)) throw conflict();
        if (Objects.equals(current, target)) return false;
        if (!Objects.equals(currentVersion, version)) throw conflict();
        return true;
    }
    private static void validateType(String type, boolean allowAll) {
        if (!"review".equals(type) && !"question".equals(type) && !"answer".equals(type) && !(allowAll && "all".equals(type))) {
            throw new IllegalArgumentException("Loại nội dung không hợp lệ.");
        }
    }
    private static ConflictException conflict() { return new ConflictException("Nội dung hoặc trạng thái liên quan đã thay đổi. Vui lòng tải lại trang."); }
    private static final class Decision {
        final String previous, target;
        final Instant at;
        Decision(String previous, String target, Instant at) { this.previous = previous; this.target = target; this.at = at; }
    }
}
