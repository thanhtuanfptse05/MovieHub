# 007-admin-crud Implementation Plan

Goal: Deliver the existing spec selected by the owner on 2026-10-26: movie/category management, account role/status changes and unified moderation.
Spec: spec.md; ../shared/data-contract.md; ../shared/system-rules.md.
Stack: Existing Java 17 / Ant / Servlet / JPA / JSTL; preserve dependencies, UTF-8 and existing local configuration.

## Architecture
Services validate and return safe DTOs. Dedicated DAOs use named JPA parameters and atomic transactions. AdminTransactions.write(actorId, work) locks the lowest-ID Users row with PESSIMISTIC_WRITE before rechecking the current ACTIVE ADMIN. The stable row cannot be deleted under the spec. All admin mutations share this lock, protecting last-admin and category-assignment invariants and ordering moderation against movie changes. Movie and Category gain version fields. Author review edits remain protected by their existing optimistic versions.

## Tasks
1. Baseline tests and feature branch in the existing checkout; shared transactional guard and entity versions.
2. TDD AdminMovieService/AdminCategoryService, DAO and DTOs: publish/media/text/slug validation, canonical uniqueness, atomic category replacement, hide, stale versions and soft deletion. Existing session nonce protects movie create retries.
3. TDD AdminUserService/AdminModerationService, DAO and DTOs: self/last-admin protection, current actor, queue filters/order, parent status, deleted review, contentRevision and no-op audit preservation.
4. Controllers and current-DB AdminAuthFilter: explicit GET/POST methods, CSRF, nonce, one-use flash, field errors, safe 500 and canonical filter-preserving redirects. /admin redirects to /admin/dashboard; dashboard is navigation only because 008 owns analytics.
5. Vietnamese JSP screens with DB-derived data, escaped JSTL, existing design tokens, responsive tables and accessible confirmations for hide/publish/lock/demotion. No engineering copy or hardcoded business records.
6. Compile/test/dist, SQL Server transaction/concurrency tests, DB-to-screen fixture change, Unicode scans, empty/error and responsive browser checks; independent code review.
7. Record evidence, routes and changelog; commit and push feature branch after gates pass.

## Review focus
- Concurrent administrators revoking each other cannot leave zero ACTIVE ADMIN accounts.
- Category deletion and assignment cannot commit a deleted linked category or partial movie save.
- Stale moderation cannot approve an author's revised review.
- Retried decisions preserve the first moderator/time/version.
- Invalid enums, crafted fields, unsafe URLs, stale versions and DB failures retain correct statuses and no partial writes.

## Constraints
10 rows/page; q <= 200; server-owned identity/count/timestamps; no user credentials in admin DTOs; no hard deletes; transaction rollback; current actor at writes; CSRF; safe audit logs; UTF-8; JSP under WEB-INF/views; existing libraries only.

## Execution rulings
The owner explicitly requested implementing the current 007 spec, so historical Draft markers do not require another approval round. Work in the clean current checkout on feat/007-admin-crud to retain existing local runtime setup. graphify report covers tooling only; use CodeGraph for current application boundaries.
