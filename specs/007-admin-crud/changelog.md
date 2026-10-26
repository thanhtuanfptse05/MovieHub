# Changelog: 007-admin-crud
<!-- Spec & Implementation Evolution History -->

## [1.0.0 Implementation] - 2026-10-26

- Added versioned movie/category administration, account role/status management and a unified review/question/answer moderation queue.
- Added transactional current-admin checks and a shared row lock for cross-account and category-assignment invariants. Target row locks preserve concurrent movie views and password resets.
- Added safe DTOs, method/CSRF guards, movie submission nonces, filter-preserving redirects and Vietnamese responsive JSP screens.
- Added unit, SQL Server and HTTP verification, including stale reviews, no-op audit preservation, cross-admin revocation, category races, Unicode and existing-session role changes.
- Replaced historical plan/tasks/checklist scaffolds. See [verification](verification.md) for evidence and remaining environment limitations.

## [1.0.0 Draft] - 2026-10-25

- Viết lại spec từ kế hoạch nguồn: nghiệp vụ, EARS, contracts, validation, concurrency và success criteria; xem overview và tài liệu shared.
- Chưa triển khai, chưa duyệt baseline; plan/tasks/checklists cũ cần tạo lại. Có requirements checklist mới.

## [0.1.0] - 2026-10-25
### Initialized
- Scaffolded feature spec, architecture plan, tasks, and validation checklists.
- Linked to UC-12, UC-13, UC-14 and BR-06 through BR-10, BR-22, BR-23.
