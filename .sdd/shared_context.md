# MovieHub — Shared Agent Context & Synchronization
<!-- Shared state across agent sessions and subagents -->
Last Updated: 2026-10-25 | Sprint: Sprint 0 (Setup & Architecture Scaffolding)

## Current Project State
- **Stage**: Setup & Scaffolding complete; Ready for Feature Specification & Implementation.
- **Active Sprint Focus**: Folder structure setup, SDD artifacts initialization, rule enforcement.
- **Git State**: Local repository initialized on branch `main`.

## Module Map & Use Case Traceability
| Module ID | Directory | Use Cases | Risk Level | Spec Status |
|:---|:---|:---|:---|:---|
| `feat-001-auth` | [specs/001-auth](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs/001-auth) | UC-01 (Register), UC-02 (Login/Logout), UC-03 (Forgot Password) | High | Scaffolded |
| `feat-002-user-profile` | [specs/002-user-profile](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs/002-user-profile) | UC-04 (View/Update Profile), UC-14 (Change Password) | Medium | Scaffolded |
| `feat-003-movie-catalog` | [specs/003-movie-catalog](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs/003-movie-catalog) | UC-05 (Browse/Filter), UC-06 (Search), UC-07 (Details), UC-17 (History/Trailer) | Medium | Scaffolded |
| `feat-004-favorites` | [specs/004-favorites](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs/004-favorites) | UC-08 (Manage Favorites/Watchlist) | Low | Scaffolded |
| `feat-005-reviews-rating` | [specs/005-reviews-rating](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs/005-reviews-rating) | UC-09 (Post Review/Rating), UC-15 (Moderate Reviews) | Medium | Scaffolded |
| `feat-006-qa` | [specs/006-qa](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs/006-qa) | UC-10 (Post Question), UC-11 (Post Answer), UC-15 (Moderate Q&A) | Medium | Scaffolded |
| `feat-007-admin-crud` | [specs/007-admin-crud](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs/007-admin-crud) | UC-12 (Movies CRUD), UC-13 (Categories CRUD), UC-14 (Users CRUD) | High | Scaffolded |
| `feat-008-admin-analytics` | [specs/008-admin-analytics](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs/008-admin-analytics) | UC-16 (Admin Analytics & Reports) | Medium | Scaffolded |

## Active Constraints & Flags
- `allowedlib` strictly active: 4 JARs (`jakarta.servlet.jsp.jstl`, `jaxb-api`, `sqljdbc42`).
- 0% scriptlets in JSP. All rendering through JSTL `<c:out>` and EL.
- Tomcat 10.1 (`jakarta.*` namespace).
