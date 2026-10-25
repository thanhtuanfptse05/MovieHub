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
│  8 Active Tables: Users, Movies, Categories, etc.      │
└────────────────────────────────────────────────────────┘
```

## 2. Database Tables Summary

See the [SQL Server schema and ERD](database.md) and [setup scripts](../../database/README.md).

1. `Users`: Profiles, BCrypt hashes, USER/ADMIN roles, ACTIVE/INACTIVE status, version and credentials_version.
2. `Movies`: Metadata, media URLs, DRAFT/PUBLISHED/HIDDEN status, BIGINT view counter; ratings are calculated from reviews.
3. `Categories`: Genre names and slugs, with soft deletion.
4. `MovieCategories`: Many-to-many junction with a composite primary key.
5. `Favorites`: Unique user/movie pair, with soft deletion and restoration.
6. `Reviews`: Ratings 1–5, plain text, PENDING/APPROVED/REJECTED status, moderation audit, version/content_revision and soft deletion.
7. `Questions`: Movie discussion questions and moderation audit.
8. `Answers`: Question replies and moderation audit; no accepted-answer feature in MVP.

PasswordResetTokens belongs to the historical nine-table design. R-01 no longer uses it; setup preserves it if present and does not create it on a new database.
