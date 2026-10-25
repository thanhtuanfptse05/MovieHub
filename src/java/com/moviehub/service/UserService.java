package com.moviehub.service;

import com.moviehub.dao.UserDAO;
import com.moviehub.entity.User;
import com.moviehub.util.ValidationUtil;
import java.util.Objects;
import java.util.logging.Logger;

/**
 * Service managing user profile retrieval and updates (002-user-profile).
 * Enforces session ownership, data-contract validations, and optimistic locking.
 */
public class UserService {

    private static final Logger LOGGER = Logger.getLogger(UserService.class.getName());
    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    /**
     * Retrieves the profile of an active user.
     *
     * @param userId user id from session
     * @return User entity
     * @throws IllegalStateException if user is not found or not ACTIVE
     */
    public User getProfile(Long userId) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        User user = userDAO.findById(userId).orElse(null);
        if (user == null || !User.STATUS_ACTIVE.equals(user.getStatus())) {
            throw new IllegalStateException("Tài khoản không tồn tại hoặc đã bị khóa");
        }
        return user;
    }

    /**
     * Updates full name and avatar URL with optimistic locking.
     *
     * @param userId user id from session
     * @param fullName full name (1-100 characters)
     * @param avatarUrl avatar URL (optional HTTPS <=500 characters, or null/empty)
     * @param version entity version expected from client form
     * @return true if updated successfully
     * @throws IllegalArgumentException on validation failure
     * @throws IllegalStateException on version conflict (409) or user inactive
     */
    public boolean updateProfile(Long userId, String fullName, String avatarUrl, Integer version) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        if (version == null) {
            throw new IllegalArgumentException("Phiên bản hồ sơ là bắt buộc");
        }

        // Validate Full Name
        if (!ValidationUtil.isValidFullName(fullName)) {
            throw new IllegalArgumentException("Họ và tên không hợp lệ. Vui lòng nhập từ 1 đến 100 ký tự.");
        }

        // Validate Avatar URL
        if (!ValidationUtil.isValidAvatarUrl(avatarUrl)) {
            throw new IllegalArgumentException("URL ảnh đại diện không hợp lệ. Vui lòng sử dụng liên kết HTTPS an toàn (tối đa 500 ký tự).");
        }

        String normName = ValidationUtil.normalizeFullName(fullName);
        String normAvatar = ValidationUtil.normalizeAvatarUrl(avatarUrl);

        // Fetch current entity to check active status and detect no-op
        User current = getProfile(userId);

        // Check if nothing changed (no-op success per spec.md line 33)
        if (normName.equals(current.getFullName()) && Objects.equals(normAvatar, current.getAvatarUrl())) {
            LOGGER.fine("No-op profile update submitted for user ID " + userId);
            return true;
        }

        // Atomic update with optimistic lock check
        boolean success = userDAO.updateProfile(userId, normName, normAvatar, version);
        if (!success) {
            LOGGER.warning("Optimistic lock conflict updating profile for user ID " + userId + " (expected version " + version + ")");
            throw new IllegalStateException("Hồ sơ đã được thay đổi từ một cửa sổ hoặc phiên khác. Vui lòng tải lại trang.");
        }

        return true;
    }
}
