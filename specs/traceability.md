# Ma trận truy vết MovieHub

Ngày 2026-10-25 | Truy vết tài liệu, không phải kết quả chạy test.
FR/BR/UC không có prefix module dưới đây là mã trong kế hoạch nguồn. Các AC có prefix là mã duy nhất trong bộ spec mới.

## 1. Use case → chủ sở hữu → tiêu chí

| UC | Chủ sở hữu | Tiêu chí chính |
|---|---|---|
| UC-01 đăng ký | 001 | AUTH-AC-01,02,03,15 |
| UC-02 login/logout | 001 | AUTH-AC-04…08,14,15 |
| UC-03 forgot/reset | 001 | AUTH-AC-09…13,15 |
| UC-04 profile | 002 | PROFILE-AC-01…10 |
| UC-05 Home | 003 | CAT-AC-01,02,13 |
| UC-06 tìm/lọc/sort/page | 003 | CAT-AC-03…07 |
| UC-07 detail/video | 003 | CAT-AC-08…10,12,13 |
| UC-08 favorites | 004 | FAV-AC-01…09 |
| UC-09 review | 005 | REV-AC-01…11 |
| UC-10 question | 006 | QA-AC-01,02,04,05,08…12 |
| UC-11 answer | 006 | QA-AC-01,03…12 |
| UC-12 movie CRUD | 007 | ADM-AC-01…04,15 |
| UC-13 category CRUD | 007 | ADM-AC-05,06,15 |
| UC-14 user management | 007 | ADM-AC-07,08,15 |
| UC-15 moderation | 007; hiệu lực 005/006 | ADM-AC-09…14; REV-AC-08; QA-AC-05…07 |
| UC-16 analytics | 008 | ANA-AC-01…10 |
| UC-17 similar | 003 | CAT-AC-11 |

## 2. Functional requirements nguồn (26/26)

| FR | Đặc tả và phạm vi | Liên kết |
|---|---|---|
| FR-01 | Đăng ký P0 | [001](001-auth/spec.md), AUTH-AC-01…03 |
| FR-02 | Login P0 | [001](001-auth/spec.md), AUTH-AC-04…06 |
| FR-03 | Logout P0 | [001](001-auth/spec.md), AUTH-AC-07 |
| FR-04 | Forgot/reset P0 | [001](001-auth/spec.md), AUTH-AC-09…13 |
| FR-05 | Profile P0 | [002](002-user-profile/spec.md), PROFILE-AC-01…10 |
| FR-06 | Phân quyền P0 | [001](001-auth/spec.md), AUTH-AC-08; SYS-01 |
| FR-07 | Home P0 | [003](003-movie-catalog/spec.md), CAT-AC-01,02 |
| FR-08 | Search/filter/sort P0 | [003](003-movie-catalog/spec.md), CAT-AC-03…07 |
| FR-09 | Pagination P0 | [003](003-movie-catalog/spec.md), CAT-AC-06 |
| FR-10 | Detail P0 | [003](003-movie-catalog/spec.md), CAT-AC-08,09 |
| FR-11 | Demo player P0 | [003](003-movie-catalog/spec.md), CAT-AC-10 |
| FR-12 | Favorites P0 | [004](004-favorites/spec.md), FAV-AC-01…09 |
| FR-13 | Review/rating P0 | [005](005-reviews-rating/spec.md), REV-AC-01…11 |
| FR-14 | Question P0 | [006](006-qa/spec.md), QA-AC-02 |
| FR-15 | Answer P0 | [006](006-qa/spec.md), QA-AC-03 |
| FR-16 | Public Q&A qua duyệt P0 | [006](006-qa/spec.md), QA-AC-05…07 |
| FR-17 | Movie CRUD P0 | [007](007-admin-crud/spec.md), ADM-AC-02…04 |
| FR-18 | Category CRUD P0 | [007](007-admin-crud/spec.md), ADM-AC-05,06 |
| FR-19 | User/role/status P0 | [007](007-admin-crud/spec.md), ADM-AC-07,08 |
| FR-20 | Duyệt P0 | [007](007-admin-crud/spec.md), ADM-AC-09…14 |
| FR-21 | COUNT/SUM/AVG/MAX/MIN P0 | [008](008-admin-analytics/spec.md), ANA-AC-02…09 |
| FR-22 | Similar P0 | [003](003-movie-catalog/spec.md), CAT-AC-11 |
| FR-23 | Error/empty/loading P0 | [SYS-04,06](shared/system-rules.md); từng module Edge Cases |
| FR-24 | Validation client/server P0 | [data-contract](shared/data-contract.md); tiêu chí lỗi form mọi module |
| FR-25 | Breadcrumb/navbar search P1 | [003 Out of Scope/P1](003-movie-catalog/spec.md) |
| FR-26 | Category chart P1 | [008 P1](008-admin-analytics/spec.md), ANA-AC-10 |

## 3. Business rules nguồn (24/24)

| BR | Nơi định nghĩa chính |
|---|---|
| BR-01 email unique | data-contract mục 2,3; AUTH-AC-03 |
| BR-02 password ≥8/hash | data-contract mục 3; D-02; AUTH-AC-01 |
| BR-03 default USER/ACTIVE | AUTH-AC-02 |
| BR-04 chỉ ACTIVE | SYS-01; AUTH-AC-05,06 |
| BR-05 quyền Admin | SYS-01; ADM-AC-01 |
| BR-06 phim public | SYS-02; CAT-AC-01 |
| BR-07 unique slug | data-contract; ADM-AC-03,05 |
| BR-08 không hard-delete phim | ADM-AC-04 |
| BR-09 view 30 phút/session/movie | SYS-07; CAT-AC-08,12 |
| BR-10 favorite unique | FAV-AC-02,03 |
| BR-11 review unique/rating | REV-AC-01,03 |
| BR-12 PENDING mới, APPROVED public | REV-AC-02; QA-AC-02,03,05 |
| BR-13 question/movie, answer/approved question | QA-AC-02,03 |
| BR-14 content lengths | data-contract; REV-AC-01; QA-AC-04 |
| BR-15 ownership/edit lại duyệt | REV-AC-04,05 |
| BR-16 Admin cuối/self lock | ADM-AC-08 |
| BR-17 nguồn đã được thay bởi R-01: email khớp để đặt mật khẩu trực tiếp, không mail/token | AUTH-AC-09…13; decisions R-01 |
| BR-18 whitelist/page | CAT-AC-05…07; SYS-03 |
| BR-19 approved average | REV-AC-07 |
| BR-20 similar | CAT-AC-11 |
| BR-21 year/duration | data-contract; ADM-AC-02,03 |
| BR-22 URL | data-contract mục 3; CAT-AC-10,13 |
| BR-23 moderator/time | ADM-AC-10,12 |
| BR-24 aggregate thật | ANA-AC-03 |

## 4. NFR và quality

| NFR | Nơi đặc tả | Bằng chứng phải có khi triển khai |
|---|---|---|
| NFR-01 compatibility | SYS-06; GOV-01 | Ant compile/test/dist + deploy Tomcat |
| NFR-02 JPA | SYS-05,06 | EntityManager smoke test, rollback |
| NFR-03 security | SYS-06; data-contract; AUTH/REV/ADM; ngoại lệ R-01 không xác minh chủ email | CSRF/XSS/hash/context reset/parameter binding |
| NFR-04 authorization | SYS-01; AUTH-AC-08 | Direct URL/POST, revoke session/role |
| NFR-05 performance | SYS-06 | 20 lần catalog/detail có máy/mốc thời gian |
| NFR-06 usability | SYS-06 | 375/768/1366px, empty/error |
| NFR-07 reliability | SYS-04,07 | Missing ID/page/DB/media failure |
| NFR-08 layering | SYS-06; handoff | Review plan/code theo MVC |
| NFR-09 logging | SYS-06; ADM audit | Log lỗi/admin an toàn |
| NFR-10 integrity | SYS-05; data-contract | UNIQUE/FK/concurrency/rollback |
| NFR-11 accessibility | SYS-06 | Label/alt/keyboard/contrast |
| NFR-12 deployment | data-contract seed; GOV/ENV; acceptance | README/schema/seed/config mẫu không secret |

FR-24: server validation là nguồn quyết định; form client có required/length/type hoặc thông báo tương ứng nhưng không được dựa vào JavaScript để bảo vệ dữ liệu. Tắt/bypass client validation vẫn bị server từ chối theo cùng quy tắc.
