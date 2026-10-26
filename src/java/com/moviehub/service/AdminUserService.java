package com.moviehub.service;

import com.moviehub.dao.AdminUserDAO;
import com.moviehub.dto.AdminUserItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.User;
import com.moviehub.exception.AdminValidationException;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.ForbiddenException;
import com.moviehub.exception.NotFoundException;
import java.text.Normalizer;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

public class AdminUserService {
    private final AdminUserDAO dao;
    public AdminUserService() { this(new AdminUserDAO()); }
    public AdminUserService(AdminUserDAO dao) { this.dao = dao; }

    public PageResult<AdminUserItem> list(String rawQ, String rawRole, String rawStatus, int page) {
        String q = Normalizer.normalize(rawQ == null ? "" : rawQ.trim(), Normalizer.Form.NFC).toLowerCase(Locale.ROOT);
        if (q.codePointCount(0, q.length()) > 200) throw new IllegalArgumentException("Từ khóa tối đa 200 ký tự.");
        String role = optional(rawRole), status = optional(rawStatus);
        validateEnums(role, status, false);
        return dao.read(em -> dao.list(em, q, role, status, page));
    }
    public AdminUserItem get(Long id) {
        return dao.read(em -> new AdminUserItem(requireTarget(dao.findById(em, id))));
    }
    public AdminUserItem update(Long actorId, Long id, Integer version, String role, String status) {
        return dao.write(actorId, em -> {
            User actor = dao.findById(em, actorId);
            if (actor == null || !User.ROLE_ADMIN.equals(actor.getRole()) || !User.STATUS_ACTIVE.equals(actor.getStatus())) {
                throw new ForbiddenException("Bạn không có quyền thực hiện thao tác này.");
            }
            User target = requireTarget(dao.findForUpdate(em, id));
            validateEnums(role, status, true);
            if (version == null || version < 0) throw new IllegalArgumentException("Phiên bản không hợp lệ.");
            if (!Objects.equals(version, target.getVersion())) throw new ConflictException("Tài khoản đã thay đổi. Vui lòng tải lại trang.");
            if (Objects.equals(actorId, id) && (!User.ROLE_ADMIN.equals(role) || !User.STATUS_ACTIVE.equals(status))) {
                throw new ConflictException("Bạn không thể tự khóa hoặc hạ quyền tài khoản của mình.");
            }
            boolean removesActiveAdmin = User.ROLE_ADMIN.equals(target.getRole()) && User.STATUS_ACTIVE.equals(target.getStatus())
                    && (!User.ROLE_ADMIN.equals(role) || !User.STATUS_ACTIVE.equals(status));
            if (removesActiveAdmin && dao.countActiveAdmins(em) <= 1) {
                throw new ConflictException("Cần giữ ít nhất một quản trị viên đang hoạt động.");
            }
            if (!Objects.equals(role, target.getRole()) || !Objects.equals(status, target.getStatus())) {
                target.setRole(role); target.setStatus(status);
                em.flush();
            }
            return new AdminUserItem(target);
        });
    }
    private static String optional(String value) { return value == null || value.trim().isEmpty() ? null : value.trim(); }
    private static User requireTarget(User target) {
        if (target == null) throw new NotFoundException("Tài khoản không tồn tại.");
        return target;
    }
    private static void validateEnums(String role, String status, boolean required) {
        Map<String,String> errors = new LinkedHashMap<>();
        if ((required || role != null) && !User.ROLE_USER.equals(role) && !User.ROLE_ADMIN.equals(role)) errors.put("role", "Vai trò không hợp lệ.");
        if ((required || status != null) && !User.STATUS_ACTIVE.equals(status) && !User.STATUS_INACTIVE.equals(status)) errors.put("status", "Trạng thái không hợp lệ.");
        if (!errors.isEmpty()) throw new AdminValidationException(errors);
    }
}
