# Implementation Plan: 002-user-profile (User Profile Management)
<!-- Aligned with spec.md v1.0.0 & SDD Playbook -->

## 1. Architectural Layers & File Map
- **Entities**: [User.java](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/src/java/com/moviehub/entity/User.java) (existing JPA Entity with optimistic `@Version` and `updatedAt`)
- **DAOs**: [UserDAO.java](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/src/java/com/moviehub/dao/UserDAO.java)
  - `findById(Long id)`: Fetch current User entity by ID.
  - `updateProfile(Long userId, String fullName, String avatarUrl, int expectedVersion)`: Execute atomic optimistic update verifying active status and version. Returns boolean indicating success or conflict.
- **Services**: [UserService.java](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/src/java/com/moviehub/service/UserService.java)
  - `getProfile(Long userId)`: Returns User or throws `IllegalStateException` if not found or inactive.
  - `updateProfile(Long userId, String fullName, String avatarUrl, int expectedVersion)`: Validates input according to data-contract; trims/canonicalizes; checks active status; triggers atomic DAO update; throws `IllegalArgumentException` on bad input or `IllegalStateException` on stale version (409).
- **Controllers (Servlets)**: [ProfileServlet.java](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/src/java/com/moviehub/controller/user/ProfileServlet.java)
  - `GET /profile`: Guarded by session (AuthFilter redirects guests to login). Retrieves user from session `userId`, forwards to `profile.jsp`.
  - `POST /profile`: Validates CSRF token; extracts `fullName`, `avatarUrl`, `version`; calls `UserService.updateProfile`; on success updates session attributes (`userFullName`, `userAvatarUrl`) and redirects 303 to `/profile` with flash message.
- **Views**: [profile.jsp](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/web/WEB-INF/views/user/profile.jsp)
  - Pure JSTL/EL (Zero scriptlets).
  - Displays user avatar with CSS fallback / initial placeholder on error.
  - Read-only email and joined date (formatted via `<fmt:formatDate>`).
  - Form fields for `fullName` and `avatarUrl` with hidden `version` and `csrfToken`.
  - Responsive cinema-dark styling matching [design.md](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/design.md).
- **Web Descriptor**: [web.xml](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/web/WEB-INF/web.xml) mapping `/profile` to `ProfileServlet`.

## 2. Verification Strategy
- **Unit Tests**: [UserServiceTest.java](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/test/com/moviehub/service/UserServiceTest.java) testing:
  - Reading valid profile.
  - FullName bounds validation (empty, whitespace, >100 characters).
  - Avatar URL validation (null, whitespace, https://, >500 characters, invalid protocol).
  - Optimistic locking version conflict (409 simulation).
  - No-op update preservation.
- **Integration & Browser Tests**:
  - GET `/profile` as guest -> 302 to `/login?returnTo=%2Fprofile`.
  - GET `/profile` as logged-in user -> 200 with user data.
  - POST `/profile` with valid update -> 303 to `/profile` with updated data reflected.
  - POST `/profile` with stale version -> 409 Conflict.
- **15-Item SDD Checklist**: Verify all criteria in [checklists.md](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs/002-user-profile/checklists.md).
