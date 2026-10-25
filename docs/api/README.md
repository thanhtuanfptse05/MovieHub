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
| `/admin/dashboard` | GET | `AdminDashboardServlet` | ADMIN | Executive KPI dashboard & analytics |
| `/admin/movies/*` | GET, POST | `AdminMovieServlet` | ADMIN | CRUD management for movies |
| `/admin/categories/*`| GET, POST| `AdminCategoryServlet` | ADMIN | CRUD management for categories |
| `/admin/users/*` | GET, POST | `AdminUserServlet` | ADMIN | Manage user roles & ban status |
| `/admin/reviews/*` | GET, POST | `AdminReviewServlet` | ADMIN | Moderate flagged reviews |
