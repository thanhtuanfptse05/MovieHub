# Implementation Plan: 002-user-profile
<!-- Architecture & Engineering Plan -->

## 1. Architectural Layers & File Map
- **Entities**: `com.moviehub.entity.User`
- **DAOs**: `com.moviehub.dao.UserDAO` (`findById`, `updateProfile`, `updatePassword`)
- **Services**: `com.moviehub.service.UserService`
- **Controllers (Servlets)**:
  - `com.moviehub.controller.user.ProfileServlet` (`/profile`)
  - `com.moviehub.controller.user.ChangePasswordServlet` (`/change-password`)
- **Views (JSP + JSTL)**:
  - `web/WEB-INF/views/user/profile.jsp`
  - `web/WEB-INF/views/user/change-password.jsp`

## 2. Verification Strategy
- Unit test: `test/com/moviehub/service/UserServiceTest.java` (Password change validation, profile bounds).
- Web test: Session guard check, update profile and verify reflected in UI.
