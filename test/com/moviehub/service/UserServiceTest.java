package com.moviehub.service;

import com.moviehub.dao.UserDAO;
import com.moviehub.entity.User;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit test suite for UserService (002-user-profile).
 * Validates profile retrieval, input boundaries, optimistic locking, and no-op updates.
 */
public class UserServiceTest {

    private MockUserDAO mockUserDAO;
    private UserService userService;

    @Before
    public void setUp() {
        mockUserDAO = new MockUserDAO();
        userService = new UserService(mockUserDAO);
    }

    @Test
    public void testGetProfile_ValidUser_ReturnsUser() {
        User user = new User("Nguyễn Văn A", "user@moviehub.vn", "hashedpw", User.ROLE_USER, User.STATUS_ACTIVE);
        user.setId(10L);
        user.setAvatarUrl("https://example.com/avatar.jpg");
        mockUserDAO.userToReturn = user;

        User result = userService.getProfile(10L);
        assertNotNull(result);
        assertEquals("Nguyễn Văn A", result.getFullName());
        assertEquals("user@moviehub.vn", result.getEmail());
        assertEquals("https://example.com/avatar.jpg", result.getAvatarUrl());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testGetProfile_NullUserId_ThrowsIllegalArgumentException() {
        userService.getProfile(null);
    }

    @Test(expected = IllegalStateException.class)
    public void testGetProfile_UserNotFound_ThrowsIllegalStateException() {
        mockUserDAO.userToReturn = null;
        userService.getProfile(999L);
    }

    @Test(expected = IllegalStateException.class)
    public void testGetProfile_UserInactive_ThrowsIllegalStateException() {
        User inactive = new User("Bị Khóa", "banned@moviehub.vn", "hashedpw", User.ROLE_USER, User.STATUS_INACTIVE);
        inactive.setId(20L);
        mockUserDAO.userToReturn = inactive;

        userService.getProfile(20L);
    }

    @Test
    public void testUpdateProfile_ValidData_Success() {
        User user = new User("Cũ", "user@moviehub.vn", "hashedpw", User.ROLE_USER, User.STATUS_ACTIVE);
        user.setId(10L);
        user.setVersion(1);
        mockUserDAO.userToReturn = user;
        mockUserDAO.updateProfileSuccess = true;

        boolean result = userService.updateProfile(10L, "Nguyễn Văn Mới", "https://images.unsplash.com/photo-test", 1);
        assertTrue(result);
        assertEquals("Nguyễn Văn Mới", mockUserDAO.lastUpdatedFullName);
        assertEquals("https://images.unsplash.com/photo-test", mockUserDAO.lastUpdatedAvatarUrl);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testUpdateProfile_NullFullName_ThrowsIllegalArgumentException() {
        userService.updateProfile(10L, null, "https://example.com/avatar.jpg", 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testUpdateProfile_EmptyFullName_ThrowsIllegalArgumentException() {
        userService.updateProfile(10L, "   ", "https://example.com/avatar.jpg", 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testUpdateProfile_FullNameExceeds100_ThrowsIllegalArgumentException() {
        String longName = "a".repeat(101);
        userService.updateProfile(10L, longName, "https://example.com/avatar.jpg", 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testUpdateProfile_InvalidAvatarUrlProtocol_ThrowsIllegalArgumentException() {
        userService.updateProfile(10L, "Nguyễn Văn A", "ftp://example.com/avatar.jpg", 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testUpdateProfile_JavascriptAvatarUrl_ThrowsIllegalArgumentException() {
        userService.updateProfile(10L, "Nguyễn Văn A", "javascript:alert(1)", 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testUpdateProfile_AvatarUrlExceeds500_ThrowsIllegalArgumentException() {
        String longUrl = "https://example.com/" + "a".repeat(500);
        userService.updateProfile(10L, "Nguyễn Văn A", longUrl, 1);
    }

    @Test
    public void testUpdateProfile_EmptyAvatarUrl_NormalizedToNullAndSucceeds() {
        User user = new User("Tên", "user@moviehub.vn", "hashedpw", User.ROLE_USER, User.STATUS_ACTIVE);
        user.setId(10L);
        user.setAvatarUrl("https://example.com/old.jpg");
        user.setVersion(1);
        mockUserDAO.userToReturn = user;
        mockUserDAO.updateProfileSuccess = true;

        boolean result = userService.updateProfile(10L, "Tên Mới", "   ", 1);
        assertTrue(result);
        assertNull(mockUserDAO.lastUpdatedAvatarUrl);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testUpdateProfile_NullVersion_ThrowsIllegalArgumentException() {
        userService.updateProfile(10L, "Nguyễn Văn A", "https://example.com/avatar.jpg", null);
    }

    @Test(expected = IllegalStateException.class)
    public void testUpdateProfile_OptimisticLockConflict_ThrowsIllegalStateException() {
        User user = new User("Tên", "user@moviehub.vn", "hashedpw", User.ROLE_USER, User.STATUS_ACTIVE);
        user.setId(10L);
        user.setVersion(2);
        mockUserDAO.userToReturn = user;
        mockUserDAO.updateProfileSuccess = false; // Simulate stale version update failure

        userService.updateProfile(10L, "Tên Đổi", "https://example.com/avatar.jpg", 1);
    }

    @Test
    public void testUpdateProfile_NoOpUpdate_SucceedsWithoutTouchingDAO() {
        User user = new User("Tên Chuẩn", "user@moviehub.vn", "hashedpw", User.ROLE_USER, User.STATUS_ACTIVE);
        user.setId(10L);
        user.setAvatarUrl("https://example.com/avatar.jpg");
        user.setVersion(3);
        mockUserDAO.userToReturn = user;
        mockUserDAO.updateProfileSuccess = false; // Even if DAO would fail, no-op doesn't call updateProfile

        boolean result = userService.updateProfile(10L, "Tên Chuẩn", "https://example.com/avatar.jpg", 3);
        assertTrue(result);
        assertNull("DAO updateProfile should not have been called for no-op", mockUserDAO.lastUpdatedFullName);
    }

    // Mock DAO for isolated unit testing
    private static class MockUserDAO extends UserDAO {
        User userToReturn;
        boolean updateProfileSuccess = true;
        String lastUpdatedFullName;
        String lastUpdatedAvatarUrl;

        @Override
        public java.util.Optional<User> findById(Long id) {
            return java.util.Optional.ofNullable(userToReturn);
        }

        @Override
        public boolean updateProfile(Long userId, String fullName, String avatarUrl, int expectedVersion) {
            this.lastUpdatedFullName = fullName;
            this.lastUpdatedAvatarUrl = avatarUrl;
            return updateProfileSuccess;
        }
    }
}
