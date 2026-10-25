# MovieHub — System Architecture & Data Schema
<!-- System Architecture, Schema & Design Constraints -->

## 1. System High-Level Architecture
MovieHub follows a 3-tier MVC pattern implemented on Jakarta EE 10:
```
┌────────────────────────────────────────────────────────┐
│                      Client Tier                       │
│           Web Browser / Mobile Browser                 │
└──────────────────────────┬─────────────────────────────┘
                           │ HTTP / HTTPS
┌──────────────────────────▼─────────────────────────────┐
│                    Web Tier (Tomcat 10.1)              │
│  Controllers (Servlets): com.moviehub.controller.*     │
│  Filters: AdminAuthFilter, EncodingFilter              │
│  Views: /WEB-INF/views/*.jsp (Pure JSTL + CSS/JS)      │
└──────────────────────────┬─────────────────────────────┘
                           │ Java Method Invocations
┌──────────────────────────▼─────────────────────────────┐
│                   Service & Business Tier              │
│  Services: com.moviehub.service.*                      │
│  Business Rules: BR-01 to BR-24                        │
└──────────────────────────┬─────────────────────────────┘
                           │ Transactions / EntityManager
┌──────────────────────────▼─────────────────────────────┐
│                  Persistence & Data Tier               │
│  Entities: com.moviehub.entity.*                       │
│  DAOs: com.moviehub.dao.* (JPA 3.0 / Hibernate)        │
│  Driver: Microsoft SQL Server JDBC (sqljdbc42.jar)     │
└──────────────────────────┬─────────────────────────────┘
                           │ TCP / IP (Port 1433)
┌──────────────────────────▼─────────────────────────────┐
│              Database: Microsoft SQL Server            │
│  9 Core Tables: Users, Movies, Categories, etc.        │
└────────────────────────────────────────────────────────┘
```

## 2. Database Tables Summary (9 Entities)
1. `Users`: Account credentials, profile details, roles (`CUSTOMER`, `ADMIN`), failed login counters.
2. `Movies`: Title, synopsis, director, release year, duration, poster URL, trailer URL, view counter, average rating.
3. `Categories`: Genre taxonomy (Action, Drama, Sci-Fi, etc.).
4. `MovieCategories`: Many-to-Many junction between Movies and Categories.
5. `Favorites`: User bookmarked movies (`user_id`, `movie_id`, `created_at`).
6. `Reviews`: User star ratings (1-5), review comments, moderation status (`APPROVED`, `PENDING_REVIEW`, `FLAGGED`).
7. `Questions`: User community inquiries for movies.
8. `Answers`: Responses to questions, status (`ACCEPTED`, `PENDING`).
9. `PasswordResetTokens`: Temporary password recovery tokens (15-min TTL).
