> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

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
