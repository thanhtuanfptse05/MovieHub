# MovieHub — Servlet & API Routes Specification
<!-- Endpoint & Route Inventory -->

> API scaffold: đối chiếu spec module hiện hành trước code. Riêng UC-03 đã cập nhật theo [auth v1.1.0/R-01](../../specs/001-auth/spec.md): email ACTIVE khớp được đặt password mới trực tiếp, không xác thực email/token/OTP/SMTP. Những route scaffold khác chưa đồng bộ toàn bộ bộ spec.

All requests are handled by Jakarta Servlets mapped via `@WebServlet` or `web.xml`.

| Route | Method | Controller | Access Role | Description |
|:---|:---|:---|:---|:---|
| `/register` | GET, POST | `RegisterServlet` | Public | Account registration |
| `/login` | GET, POST | `LoginServlet` | Public | Authentication & session creation |
| `/logout` | GET, POST | `LogoutServlet` | Authenticated | Terminate session |
| `/forgot-password` | GET, POST | `ForgotPasswordServlet` | Guest | POST email + CSRF; ACTIVE khớp tạo context server rồi303 reset form, không gửi mail |
| `/reset-password` | GET, POST | `ResetPasswordServlet` | Guest + context server | GET form; POST password/confirmPassword/flowVersion/CSRF, đổi hash và thu hồi phiên cũ |
| `/profile` | GET, POST | `ProfileServlet` | Authenticated | View and edit personal profile |
| `/change-password` | GET, POST | `ChangePasswordServlet` | Authenticated | Update account password |
| `/` | GET | `HomeServlet` | Public | Home: featured, newest, most viewed, top rated |
| `/movies` | GET | `MovieListServlet` | Public | Search (q), category, year, sort, page; 400 on invalid filter |
| `/movies/detail` | GET | `MovieDetailServlet` | Public | Movie detail by `id`; 404 if not PUBLISHED; counts one view per session per 30 min |
| `/favorites` | GET | `FavoriteListServlet` | Authenticated | View personal watchlist with pagination (10/page) |
| `/favorites/add` | POST | `FavoriteAddServlet` | Authenticated | Add movie to favorites (303 redirect) |
| `/favorites/remove` | POST | `FavoriteRemoveServlet` | Authenticated | Remove movie from favorites (303 redirect) |
| `/reviews/save` | POST | `ReviewSaveServlet` | Authenticated | Create (mode=create) or update (mode=update) movie review (303 redirect) |
| `/reviews/delete` | POST | `ReviewDeleteServlet` | Authenticated | Soft-delete own review (303 redirect) |
| `/qa/questions/create`| POST | `QAServlet` | Authenticated | Post question on movie |
| `/qa/answers/create` | POST | `QAServlet` | Authenticated | Post answer to question |
| `/qa/answers/accept` | POST | `QAServlet` | Authenticated | Accept answer |
| `/admin`, `/admin/` | GET | `AdminHomeServlet` | ACTIVE ADMIN | 303 to `/admin/dashboard` |
| `/admin/dashboard` | GET | `AdminHomeServlet` | ACTIVE ADMIN | Navigation to administration modules; analytics belongs to 008 |
| `/admin/movies` | GET | `AdminMovieServlet` | ACTIVE ADMIN | q/status/page; updatedAt DESC,id DESC; 10 rows |
| `/admin/movies/create` | GET, POST | `AdminMovieServlet` | ACTIVE ADMIN | Movie fields, categoryIds, session submissionId and CSRF; retry does not insert twice |
| `/admin/movies/edit` | GET, POST | `AdminMovieServlet` | ACTIVE ADMIN | id/version and allowlisted movie fields; atomic category replacement |
| `/admin/movies/hide` | POST | `AdminMovieServlet` | ACTIVE ADMIN | id/version/CSRF; HIDDEN, preserving interactions |
| `/admin/categories` | GET | `AdminCategoryServlet` | ACTIVE ADMIN | q/page; active categories and creation form |
| `/admin/categories/edit` | GET | `AdminCategoryServlet` | ACTIVE ADMIN | id; category edit form |
| `/admin/categories/save` | POST | `AdminCategoryServlet` | ACTIVE ADMIN | name/slug; optional id and edit version; CSRF |
| `/admin/categories/delete` | POST | `AdminCategoryServlet` | ACTIVE ADMIN | id/version/CSRF; soft delete only when no movie links |
| `/admin/users` | GET | `AdminUserServlet` | ACTIVE ADMIN | q(email)/role/status/page; safe DTOs exclude credentials |
| `/admin/users/edit` | GET | `AdminUserServlet` | ACTIVE ADMIN | id; role/status form |
| `/admin/users/update` | POST | `AdminUserServlet` | ACTIVE ADMIN | id/version/role/status/CSRF; self-revocation and last-active-admin protection |
| `/admin/moderation` | GET | `AdminModerationServlet` | ACTIVE ADMIN | type(all/review/question/answer),status,page; oldest first |
| `/admin/moderation/decide` | POST | `AdminModerationServlet` | ACTIVE ADMIN | type/id/action(APPROVE/REJECT)/version/contentRevision/CSRF; preserves audit on safe retry |

Admin methods are checked before authentication and CSRF. Guest requests to supported protected methods receive 303 login; authenticated USER receives 403. Invalid fields/filters return 400; missing resources 404; stale state/invariant conflicts 409; unsupported methods 405. Successful writes use 303 and a one-use flash. POST returnQ/returnStatus/returnRole/returnType/returnPage retain list context. No physical deletion endpoint or separate per-type moderation endpoint exists.
