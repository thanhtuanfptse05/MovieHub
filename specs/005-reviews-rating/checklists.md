# Validation Gate Checklist: 005-reviews-rating
<!-- 15-Item SDD Pre-Commit Verification Checklist -->

| # | Category | Criterion | Status | Notes |
|:---|:---|:---|:---|:---|
| 01 | **CODE** | Code compiles cleanly locally (`ant compile`) with zero syntax errors | [ ] | Run `ant compile` |
| 02 | **CODE** | Zero debug statements; proper logging in place | [ ] | Grep check |
| 03 | **CODE** | Zero TODO / FIXME comments left in code | [ ] | Cleaned |
| 04 | **CODE** | Follows naming conventions in `AGENTS.md` | [ ] | Verified |
| 05 | **CODE** | 100% Pure JSTL / EL in JSP views; ZERO scriptlets (`<% ... %>`) | [ ] | Mandatory |
| 06 | **TEST** | All existing tests pass without regression | [ ] | `ant test` |
| 07 | **TEST** | Unit tests written for `ReviewService` covering rating boundaries & math | [ ] | TDD verified |
| 08 | **TEST** | Test coverage meets >= 80% for service layer | [ ] | Verified |
| 09 | **SEC** | XSS defense: all review comments escaped using `<c:out>` | [ ] | Verified |
| 10 | **SEC** | Ownership verification: users cannot delete reviews of other users | [ ] | Validated |
| 11 | **SPEC** | Code satisfies all Acceptance Criteria (AC-01 to AC-04) in `spec.md` | [ ] | Traced |
| 12 | **SPEC** | No feature creep beyond approved spec scope | [ ] | Diff checked |
| 13 | **DOC** | Documentation & servlet routes documented in `docs/api/` | [ ] | Documented |
| 14 | **DELIVERY** | Git commit with Conventional Commits and branch pushed to GitHub | [ ] | Push rule |
