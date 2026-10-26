package com.moviehub.service;

import com.moviehub.dao.AdminUserDAO;
import com.moviehub.dto.AdminUserItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.User;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.ForbiddenException;
import jakarta.persistence.EntityManager;
import java.lang.reflect.Proxy;
import java.time.Instant;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.function.Function;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

public class AdminUserServiceTest {
    private MemoryDAO dao;
    private AdminUserService service;

    @Before public void setUp() {
        dao = new MemoryDAO();
        dao.users.put(1L, user(1L, "ADMIN", "ACTIVE"));
        dao.users.put(2L, user(2L, "USER", "ACTIVE"));
        service = new AdminUserService(dao);
    }

    @Test(expected = ConflictException.class) public void cannotLockOwnAccount() {
        service.update(1L, 1L, 1, "ADMIN", "INACTIVE");
    }
    @Test(expected = ConflictException.class) public void cannotDemoteOwnAccountEvenWithAnotherAdministrator() {
        dao.users.put(3L, user(3L, "ADMIN", "ACTIVE"));
        service.update(1L, 1L, 1, "USER", "ACTIVE");
    }
    @Test(expected = ForbiddenException.class) public void inactiveAdministratorCannotWrite() {
        dao.users.get(1L).setStatus("INACTIVE");
        service.update(1L, 2L, 1, "USER", "INACTIVE");
    }
    @Test(expected = ForbiddenException.class) public void demotedAdministratorCannotWrite() {
        dao.users.get(1L).setRole("USER");
        service.update(1L, 2L, 1, "USER", "INACTIVE");
    }
    @Test(expected = ConflictException.class) public void staleFormCannotOverwriteCurrentUser() {
        dao.users.get(2L).setVersion(2);
        service.update(1L, 2L, 1, "ADMIN", "ACTIVE");
    }
    @Test public void updatesOnlyRoleAndStatusAndReturnsSafeAccountDetails() {
        User original = dao.users.get(2L);
        original.setPasswordHash("private-hash");
        original.setCredentialsVersion(7);
        AdminUserItem result = service.update(1L, 2L, 1, "ADMIN", "INACTIVE");
        assertEquals("ADMIN", original.getRole());
        assertEquals("INACTIVE", original.getStatus());
        assertEquals("private-hash", original.getPasswordHash());
        assertEquals(Integer.valueOf(7), original.getCredentialsVersion());
        assertEquals("u2@example.com", result.getEmail());
        assertEquals("ADMIN", result.getRole());
        assertEquals(Instant.parse("2026-10-26T00:00:00Z"), result.getCreatedAt().toInstant());
    }
    @Test public void canRevokeAnotherAdministratorWhileActorRemainsActive() {
        dao.users.get(2L).setRole("ADMIN");
        service.update(1L, 2L, 1, "USER", "INACTIVE");
        assertEquals("ADMIN", dao.users.get(1L).getRole());
        assertEquals("ACTIVE", dao.users.get(1L).getStatus());
        assertEquals("USER", dao.users.get(2L).getRole());
    }
    @Test public void inactiveAdministratorsAreNotCountedByInvariant() {
        dao.users.put(3L, user(3L, "ADMIN", "INACTIVE"));
        assertEquals(1, dao.countActiveAdmins(null));
    }
    @Test public void emailSearchIsTrimmedAndCanonicalBeforeDAO() {
        service.list("  UPPER@EXAMPLE.COM  ", "ADMIN", "ACTIVE", 1);
        assertEquals("upper@example.com", dao.q);
        assertEquals("ADMIN", dao.role);
        assertEquals("ACTIVE", dao.status);
    }
    @Test(expected = IllegalArgumentException.class) public void rejectsLongSearch() {
        service.list("a".repeat(201), null, null, 1);
    }
    @Test public void searchLimitCountsUnicodeCodePoints() {
        String search = "\ud83c\udfac".repeat(200);
        service.list(search, null, null, 1);
        assertEquals(search, dao.q);
    }
    @Test(expected = IllegalArgumentException.class) public void rejectsInvalidRoleFilter() {
        service.list(null, "OWNER", null, 1);
    }
    @Test(expected = IllegalArgumentException.class) public void rejectsInvalidAccountStatus() {
        service.update(1L, 2L, 1, "USER", "BANNED");
    }
    @Test public void accountDTODoesNotExposeCredentials() {
        AdminUserItem item = service.get(2L);
        for (java.lang.reflect.Method method : item.getClass().getMethods()) {
            assertFalse(method.getName().toLowerCase().contains("password"));
            assertFalse(method.getName().toLowerCase().contains("credential"));
            assertFalse(method.getName().toLowerCase().contains("token"));
        }
    }

    @Test public void refreshesAndLocksTargetBeforeChangingRoleToPreservePasswordReset() {
        dao.concurrentHash = "rotated-credentials";
        service.update(1L, 2L, 1, "ADMIN", "ACTIVE");
        assertEquals("rotated-credentials", dao.users.get(2L).getPasswordHash());
        assertEquals(Integer.valueOf(8), dao.users.get(2L).getCredentialsVersion());
    }

    private static User user(long id, String role, String status) {
        User u = new User("User " + id, "u" + id + "@example.com", "private", role, status);
        u.setId(id);
        u.setCreatedAt(Instant.parse("2026-10-26T00:00:00Z"));
        u.setUpdatedAt(u.getCreatedAt());
        return u;
    }
    private static final class MemoryDAO extends AdminUserDAO {
        final Map<Long, User> users = new LinkedHashMap<>();
        String q, role, status, concurrentHash;
        private final EntityManager em = (EntityManager) Proxy.newProxyInstance(
                EntityManager.class.getClassLoader(), new Class<?>[]{EntityManager.class},
                (proxy, method, args) -> {
                    if (method.getName().equals("refresh") && args.length == 2 && concurrentHash != null) {
                        assertEquals(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE, args[1]);
                        User current=(User)args[0]; current.setPasswordHash(concurrentHash); current.setCredentialsVersion(8);
                    }
                    return null;
                });
        @Override public <T> T read(Function<EntityManager,T> work) { return work.apply(em); }
        @Override public <T> T write(Long actorId, Function<EntityManager,T> work) { return work.apply(em); }
        @Override public User findById(EntityManager em, Long id) { return users.get(id); }
        @Override public long countActiveAdmins(EntityManager em) {
            return users.values().stream().filter(u -> "ADMIN".equals(u.getRole()) && "ACTIVE".equals(u.getStatus())).count();
        }
        @Override public PageResult<AdminUserItem> list(EntityManager em, String q, String role, String status, int page) {
            this.q = q; this.role = role; this.status = status;
            return new PageResult<>(Collections.emptyList(), 0, 1, 0);
        }
    }
}
