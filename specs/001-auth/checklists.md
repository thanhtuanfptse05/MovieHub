# Validation Gate Checklist: 001-auth
<!-- 15-Item SDD Pre-Commit Verification Checklist -->

| # | Category | Criterion | Status | Notes |
|:---|:---|:---|:---|:---|
| 01 | **CODE** | Code compiles cleanly locally (`ant compile`) with zero syntax errors | [ ] | Run `ant compile` |
| 02 | **CODE** | Zero `System.out.println` or debug logs remaining; use Logger | [ ] | Grep check |
| 03 | **CODE** | Zero TODO / FIXME comments left in code | [ ] | Cleaned |
| 04 | **CODE** | Follows naming conventions in `AGENTS.md` and clean architecture | [ ] | Verified |
| 05 | **CODE** | 100% Pure JSTL / EL in JSP views; ZERO scriptlets (`<% ... %>`) | [ ] | Mandatory |
| 06 | **TEST** | All existing tests pass without regression | [ ] | `ant test` |
| 07 | **TEST** | Unit tests written for `AuthService` covering happy + error paths | [ ] | TDD verified |
| 08 | **TEST** | Test coverage meets >= 80% for service layer | [ ] | Verified |
| 09 | **SEC** | No plaintext passwords stored, logged, or hardcoded (BCrypt cost >= 12) | [ ] | Verified |
| 10 | **SEC** | Input validation implemented on email, password complexity (BR-02) | [ ] | Validated |
| 11 | **SEC** | Zero SQL string concatenation; parameterized JPA queries only | [ ] | Inspected |
| 12 | **SPEC** | Code satisfies all Acceptance Criteria (AC-01 to AC-05) in `spec.md` | [ ] | Traced |
| 13 | **SPEC** | No feature creep beyond approved spec scope | [ ] | Diff checked |
| 14 | **DOC** | Documentation & servlet routes documented in `docs/api/` | [ ] | Documented |
| 15 | **DELIVERY** | Git commit with Conventional Commits and branch pushed to GitHub | [ ] | Push rule |
