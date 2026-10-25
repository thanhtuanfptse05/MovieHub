package com.moviehub.service;

import com.moviehub.dao.UserDAO;
import com.moviehub.entity.User;
import com.moviehub.util.PasswordUtil;
import com.moviehub.util.ValidationUtil;
import java.util.Optional;

/**
 * Service encapsulating User Authentication, Registration, and Password Recovery.
 * Complies with spec.md v1.1.0, R-01 direct password reset flow, and Layer 1 Security rules.
 */
public class AuthService {

    private final UserDAO userDAO;

    public AuthService() {
        this(new UserDAO());
    }

    public AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    /**
     * Registers a new user.
     * Enforces unique canonical email, BCrypt password hashing, role USER, status ACTIVE.
     *
     * @param fullName candidate full name (1-100 chars)
     * @param email candidate email
     * @param password plaintext password (8-72 bytes UTF-8)
     * @param confirmPassword confirmation password matching password
     * @return persisted User entity
     */
    public User register(String fullName, String email, String password, String confirmPassword) {
        if (!ValidationUtil.isValidFullName(fullName)) {
            throw new IllegalArgumentException("Họ và tên không hợp lệ (từ 1 đến 100 ký tự)");
        }
        if (!ValidationUtil.isValidEmail(email)) {
            throw new IllegalArgumentException("Định dạng email không hợp lệ");
        }
        if (!ValidationUtil.isValidPassword(password)) {
            throw new IllegalArgumentException("Mật khẩu phải từ 8 đến 72 ký tự UTF-8");
        }
        if (confirmPassword == null || !password.equals(confirmPassword)) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp");
        }

        String canonicalEmail = ValidationUtil.canonicalizeEmail(email);
        if (userDAO.existsByEmail(canonicalEmail)) {
            throw new IllegalArgumentException("Email đã được sử dụng");
        }

        String passwordHash = PasswordUtil.hashPassword(password);
        User user = new User(
            ValidationUtil.normalizeFullName(fullName),
            canonicalEmail,
            passwordHash,
            User.ROLE_USER,
            User.STATUS_ACTIVE
        );

        return userDAO.save(user);
    }

    /**
     * Authenticates a user by email and password.
     * Uses uniform generic error message for security (prevents user enumeration).
     *
     * @param email user email
     * @param password user password
     * @return authenticated User if valid and ACTIVE
     */
    public User login(String email, String password) {
        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Email hoặc mật khẩu không hợp lệ");
        }

        String canonicalEmail = ValidationUtil.canonicalizeEmail(email);
        Optional<User> userOpt = userDAO.findByEmail(canonicalEmail);

        if (userOpt.isEmpty()) {
            throw new IllegalArgumentException("Email hoặc mật khẩu không hợp lệ");
        }

        User user = userOpt.get();
        if (!user.isActive()) {
            throw new IllegalArgumentException("Email hoặc mật khẩu không hợp lệ");
        }

        if (!PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            throw new IllegalArgumentException("Email hoặc mật khẩu không hợp lệ");
        }

        return user;
    }

    /**
     * Initiates direct password reset (R-01).
     * Checks that the email belongs to an ACTIVE account and creates a transient session ResetContext.
     * Does NOT send email, OTP, or generate reset tokens.
     *
     * @param email target email
     * @param currentFlowVersion current flowVersion from session (or 0)
     * @return initialized ResetContext
     */
    public ResetContext initiatePasswordReset(String email, int currentFlowVersion) {
        if (!ValidationUtil.isValidEmail(email)) {
            throw new IllegalArgumentException("Email không tồn tại hoặc tài khoản không khả dụng");
        }

        String canonicalEmail = ValidationUtil.canonicalizeEmail(email);
        Optional<User> userOpt = userDAO.findByEmail(canonicalEmail);

        if (userOpt.isEmpty() || !userOpt.get().isActive()) {
            throw new IllegalArgumentException("Email không tồn tại hoặc tài khoản không khả dụng");
        }

        User user = userOpt.get();
        int newFlowVersion = currentFlowVersion + 1;
        return new ResetContext(user.getId(), user.getEmail(), user.getCredentialsVersion(), newFlowVersion);
    }

    /**
     * Completes direct password reset (R-01).
     * Validates context, flowVersion, and updates password hash and increments credentialsVersion.
     *
     * @param context transient ResetContext from session
     * @param formFlowVersion flowVersion submitted by the form
     * @param newPassword candidate new password
     * @param confirmPassword confirmation password
     */
    public void completePasswordReset(ResetContext context, int formFlowVersion, String newPassword, String confirmPassword) {
        if (context == null) {
            throw new IllegalStateException("Context đặt lại mật khẩu không tồn tại hoặc đã hết hạn");
        }
        if (formFlowVersion != context.getFlowVersion()) {
            throw new IllegalStateException("Phiên bản form không khớp");
        }
        if (!ValidationUtil.isValidPassword(newPassword)) {
            throw new IllegalArgumentException("Mật khẩu mới phải từ 8 đến 72 ký tự UTF-8");
        }
        if (confirmPassword == null || !newPassword.equals(confirmPassword)) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp");
        }

        String newHash = PasswordUtil.hashPassword(newPassword);
        boolean success = userDAO.updatePasswordAndIncrementCredentials(
            context.getTargetUserId(),
            newHash,
            context.getExpectedCredentialsVersion()
        );

        if (!success) {
            throw new IllegalStateException("Yêu cầu đặt lại mật khẩu đã bị xung đột hoặc tài khoản đã thay đổi");
        }
    }

    /**
     * Validates that a user session's credentialsVersion matches current database state and user is ACTIVE.
     *
     * @param userId user ID
     * @param sessionCredentialsVersion credentialsVersion stored in session
     * @return true if valid, false if session must be invalidated
     */
    public boolean validateSessionCredentials(Long userId, int sessionCredentialsVersion) {
        if (userId == null) {
            return false;
        }
        Optional<User> userOpt = userDAO.findById(userId);
        if (userOpt.isEmpty() || !userOpt.get().isActive()) {
            return false;
        }
        return userOpt.get().getCredentialsVersion() != null &&
               userOpt.get().getCredentialsVersion().intValue() == sessionCredentialsVersion;
    }
}
