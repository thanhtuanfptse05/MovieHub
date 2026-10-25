package com.moviehub.service;

import com.moviehub.dao.UserDAO;
import com.moviehub.entity.User;
import com.moviehub.util.PasswordUtil;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit test suite for AuthService implementing TDD verification.
 */
public class AuthServiceTest {

    private AuthService authService;
    private MockUserDAO mockUserDAO;

    // In-memory mock DAO for fast, deterministic unit testing
    private static class MockUserDAO extends UserDAO {
        private final Map<Long, User> usersById = new HashMap<>();
        private final Map<String, User> usersByEmail = new HashMap<>();
        private long idSequence = 1L;

        @Override
        public Optional<User> findById(Long id) {
            return Optional.ofNullable(usersById.get(id));
        }

        @Override
        public Optional<User> findByEmail(String canonicalEmail) {
            if (canonicalEmail == null) return Optional.empty();
            return Optional.ofNullable(usersByEmail.get(canonicalEmail.trim().toLowerCase()));
        }

        @Override
        public boolean existsByEmail(String canonicalEmail) {
            if (canonicalEmail == null) return false;
            return usersByEmail.containsKey(canonicalEmail.trim().toLowerCase());
        }

        @Override
        public User save(User user) {
            if (user.getId() == null) {
                user.setId(idSequence++);
            }
            usersById.put(user.getId(), user);
            usersByEmail.put(user.getEmail().trim().toLowerCase(), user);
            return user;
        }

        @Override
        public boolean updatePasswordAndIncrementCredentials(Long userId, String newPasswordHash, int expectedCredentialsVersion) {
            User user = usersById.get(userId);
            if (user == null || !user.isActive()) {
                return false;
            }
            if (user.getCredentialsVersion() != expectedCredentialsVersion) {
                return false;
            }
            user.setPasswordHash(newPasswordHash);
            user.setCredentialsVersion(user.getCredentialsVersion() + 1);
            return true;
        }
    }

    @Before
    public void setUp() {
        mockUserDAO = new MockUserDAO();
        authService = new AuthService(mockUserDAO);
    }

    @Test
    public void testRegisterSuccess() {
        User user = authService.register("Nguyễn Văn A", "nguyenvana@example.com", "Password123@", "Password123@");
        assertNotNull(user);
        assertNotNull(user.getId());
        assertEquals("nguyenvana@example.com", user.getEmail());
        assertEquals(User.ROLE_USER, user.getRole());
        assertEquals(User.STATUS_ACTIVE, user.getStatus());
        assertEquals(Integer.valueOf(1), user.getCredentialsVersion());
        assertTrue(PasswordUtil.verifyPassword("Password123@", user.getPasswordHash()));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRegisterPasswordMismatch() {
        authService.register("Nguyễn Văn A", "a@example.com", "Password123@", "DifferentPassword");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRegisterInvalidEmail() {
        authService.register("Nguyễn Văn A", "invalid-email@", "Password123@", "Password123@");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRegisterPasswordTooShort() {
        authService.register("Nguyễn Văn A", "a@example.com", "short", "short");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRegisterDuplicateEmailCaseInsensitive() {
        authService.register("User One", "user@example.com", "Password123@", "Password123@");
        // Same email in uppercase must fail
        authService.register("User Two", "USER@EXAMPLE.COM", "Password123@", "Password123@");
    }

    @Test
    public void testLoginSuccess() {
        authService.register("User Login", "login@example.com", "Password123@", "Password123@");
        User loggedIn = authService.login("LOGIN@EXAMPLE.COM", "Password123@");
        assertNotNull(loggedIn);
        assertEquals("login@example.com", loggedIn.getEmail());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testLoginWrongPassword() {
        authService.register("User Login", "login@example.com", "Password123@", "Password123@");
        authService.login("login@example.com", "WrongPassword123@");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testLoginInactiveUser() {
        User user = authService.register("User Inactive", "inactive@example.com", "Password123@", "Password123@");
        user.setStatus(User.STATUS_INACTIVE);
        mockUserDAO.save(user);

        authService.login("inactive@example.com", "Password123@");
    }

    @Test
    public void testDirectPasswordResetFlowR01Success() {
        User user = authService.register("Reset User", "reset@example.com", "OldPassword123@", "OldPassword123@");
        assertEquals(Integer.valueOf(1), user.getCredentialsVersion());

        // Step 1: Initiate reset with active registered email
        ResetContext context = authService.initiatePasswordReset("RESET@EXAMPLE.COM", 0);
        assertNotNull(context);
        assertEquals(user.getId(), context.getTargetUserId());
        assertEquals(1, context.getExpectedCredentialsVersion());
        assertEquals(1, context.getFlowVersion());

        // Step 2: Complete reset with matching flowVersion and valid new password
        authService.completePasswordReset(context, 1, "NewPassword456@", "NewPassword456@");

        // Old password must fail
        try {
            authService.login("reset@example.com", "OldPassword123@");
            fail("Old password should not work");
        } catch (IllegalArgumentException expected) {
            // Success
        }

        // New password must succeed
        User updated = authService.login("reset@example.com", "NewPassword456@");
        assertNotNull(updated);
        assertEquals(Integer.valueOf(2), updated.getCredentialsVersion());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInitiatePasswordResetNonExistentEmail() {
        authService.initiatePasswordReset("nonexistent@example.com", 0);
    }

    @Test(expected = IllegalStateException.class)
    public void testCompletePasswordResetFlowVersionMismatch() {
        User user = authService.register("Reset User", "mismatch@example.com", "OldPassword123@", "OldPassword123@");
        ResetContext context = authService.initiatePasswordReset("mismatch@example.com", 1);
        // Form from previous tab/flow (flowVersion 1 instead of 2)
        authService.completePasswordReset(context, 0, "NewPassword456@", "NewPassword456@");
    }

    @Test(expected = IllegalStateException.class)
    public void testCompletePasswordResetStaleCredentialsVersion() {
        User user = authService.register("Reset User", "stale@example.com", "OldPassword123@", "OldPassword123@");
        ResetContext context = authService.initiatePasswordReset("stale@example.com", 0);

        // Simulate concurrent reset that already incremented credentialsVersion
        user.setCredentialsVersion(2);
        mockUserDAO.save(user);

        // Attempting to complete with stale expected version 1 must fail with conflict
        authService.completePasswordReset(context, 1, "NewPassword456@", "NewPassword456@");
    }
}
