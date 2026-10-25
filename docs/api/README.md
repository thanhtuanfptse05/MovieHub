# MovieHub — Servlet & API Routes Specification
<!-- Endpoint & Route Inventory -->

All requests are handled by Jakarta Servlets mapped via `@WebServlet` or `web.xml`.

| Route | Method | Controller | Access Role | Description |
|:---|:---|:---|:---|:---|
| `/register` | GET, POST | `RegisterServlet` | Public | Account registration |
| `/login` | GET, POST | `LoginServlet` | Public | Authentication & session creation |
| `/logout` | GET, POST | `LogoutServlet` | Authenticated | Terminate session |
| `/forgot-password` | GET, POST | `ForgotPasswordServlet` | Public | Request password recovery email |
| `/reset-password` | GET, POST | `ResetPasswordServlet` | Public | Set new password via token |
| `/profile` | GET, POST | `ProfileServlet` | Authenticated | View and edit personal profile |
| `/change-password` | GET, POST | `ChangePasswordServlet` | Authenticated | Update account password |
| `/movies` | GET | `MovieListServlet` | Public | Browse and filter movies catalog |
| `/movies/search` | GET | `MovieSearchServlet` | Public | Search movies by keyword |
| `/movies/detail` | GET | `MovieDetailServlet` | Public | View movie synopsis, trailer & reviews |
| `/favorites` | GET | `FavoriteServlet` | Authenticated | View personal watchlist |
| `/favorites/add` | POST | `FavoriteServlet` | Authenticated | Add movie to favorites |
| `/favorites/remove` | POST | `FavoriteServlet` | Authenticated | Remove movie from favorites |
| `/reviews/submit` | POST | `ReviewServlet` | Authenticated | Submit or edit movie review |
| `/reviews/delete` | POST | `ReviewServlet` | Authenticated | Delete own review |
| `/qa/questions/create`| POST | `QAServlet` | Authenticated | Post question on movie |
| `/qa/answers/create` | POST | `QAServlet` | Authenticated | Post answer to question |
| `/qa/answers/accept` | POST | `QAServlet` | Authenticated | Accept answer |
| `/admin/dashboard` | GET | `AdminDashboardServlet` | ADMIN | Executive KPI dashboard & analytics |
| `/admin/movies/*` | GET, POST | `AdminMovieServlet` | ADMIN | CRUD management for movies |
| `/admin/categories/*`| GET, POST| `AdminCategoryServlet` | ADMIN | CRUD management for categories |
| `/admin/users/*` | GET, POST | `AdminUserServlet` | ADMIN | Manage user roles & ban status |
| `/admin/reviews/*` | GET, POST | `AdminReviewServlet` | ADMIN | Moderate flagged reviews |
