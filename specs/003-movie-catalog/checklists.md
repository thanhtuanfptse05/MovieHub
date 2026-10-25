> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Validation Gate Checklist: 003-movie-catalog
<!-- 15-Item SDD Pre-Commit Verification Checklist -->

| # | Category | Criterion | Status | Notes |
|:---|:---|:---|:---|:---|
| 01 | **CODE** | Code compiles cleanly locally (`ant compile`) with zero syntax errors | [x] | Run `ant compile` |
| 02 | **CODE** | Zero debug statements; proper logging in place | [x] | Grep check |
| 03 | **CODE** | Zero TODO / FIXME comments left in code | [x] | Cleaned |
| 04 | **CODE** | Follows naming conventions in `AGENTS.md` | [x] | Verified |
| 05 | **CODE** | 100% Pure JSTL / EL in JSP views; ZERO scriptlets (`<% ... %>`) | [x] | Mandatory |
| 06 | **TEST** | All existing tests pass without regression | [x] | `ant test` |
| 07 | **TEST** | Unit tests written for `MovieService` covering pagination & filtering | [x] | TDD verified |
| 08 | **TEST** | Test coverage meets >= 80% for service layer | [x] | Verified |
| 09 | **SEC** | SQL injection protection via parameterized queries | [x] | Verified |
| 10 | **SEC** | HTML / XSS escaping on movie titles, synopses via `<c:out>` | [x] | Validated |
| 11 | **SPEC** | Soft-deleted movies excluded from public listing (BR-09) | [x] | Inspected |
| 12 | **SPEC** | Code satisfies all Acceptance Criteria (AC-01 to AC-05) in `spec.md` | [x] | Traced |
| 13 | **SPEC** | No feature creep beyond approved spec scope | [x] | Diff checked |
| 14 | **DOC** | Documentation & servlet routes documented in `docs/api/` | [x] | Documented |
| 15 | **DELIVERY** | Git commit with Conventional Commits and branch pushed to GitHub | [x] | Push rule |

