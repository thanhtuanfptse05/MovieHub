# Global Technical Constraints — MovieHub
<!-- SDD Constraint Layer 1: Technology & Engineering Standards -->

## 1. Technology Stack (Immutable)
- **Runtime & Language**: Java SE 17 (LTS).
- **Application Server**: Apache Tomcat 10.1 (Jakarta EE 10 Web Profile).
- **Build System**: Apache Ant (NetBeans project structure).
- **Database**: Microsoft SQL Server 2019/2022.
- **ORM / Persistence**: JPA 3.0 / Hibernate `EntityManager` (Dialect: `org.hibernate.dialect.SQLServerDialect`).
- **Web Tier**: Jakarta Servlets (`jakarta.servlet.*`), Jakarta JSP (`jakarta.servlet.jsp.*`), Jakarta JSTL (`jakarta.servlet.jsp.jstl`).

## 2. Library Policy: allowedlib Exclusivity
Under NO circumstances should any library outside [allowedlib](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/allowedlib) be added:
1. `jakarta.servlet.jsp.jstl-2.0.0.jar` (JSTL implementation)
2. `jakarta.servlet.jsp.jstl-api-2.0.0.jar` (JSTL API)
3. `jaxb-api-2.1.jar` (XML binding API)
4. `sqljdbc42.jar` (Microsoft SQL Server JDBC Driver)

All 4 JAR files are deployed to `web/WEB-INF/lib/` for runtime execution.

## 3. JSP & JSTL Coding Rules
- **ZERO SCRIPTLET RULE**: No `<% ... %>`, `<%= ... %>`, `<%! ... %>` anywhere in `.jsp` files.
- **Strict JSTL Prefix**:
  ```jsp
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
  <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
  <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
  ```
  *(Note: Tomcat 10.1 / Jakarta EE 10 uses URI `jakarta.tags.core`, `jakarta.tags.fmt`, `jakarta.tags.functions`).*
- **XSS Prevention**: Always wrap dynamic user output in `<c:out value="${...}" />`.
- **View Location**: All views must reside under `/WEB-INF/views/` to prevent direct browser URL access.

## 4. Architectural Boundaries
```
Browser Request 
   │
   ▼
[Servlet / Filter] (jakarta.servlet.http.HttpServlet)
   │  - Validate inputs & session
   │  - Call Service
   ▼
[Service Layer]
   │  - Enforce business rules
   │  - Manage transaction demarcation
   ▼
[DAO / Repository]
   │  - JPA EntityManager queries (Named Queries, TypedQuery)
   ▼
[Database: SQL Server]
```
Servlets MUST NOT contain database code. Services MUST NOT import `HttpServletRequest` or `HttpServletResponse`.

## 5. Naming Conventions
- Packages: `com.moviehub.controller`, `com.moviehub.service`, `com.moviehub.dao`, `com.moviehub.entity`, `com.moviehub.filter`, `com.moviehub.util`.
- Classes: PascalCase (e.g. `MovieServlet`, `MovieService`, `UserDAO`).
- Methods & Variables: camelCase (e.g. `findMoviesByCategoryId`, `currentUser`).
- Constants: UPPER_SNAKE_CASE (e.g. `DEFAULT_PAGE_SIZE`, `SESSION_USER`).
- JSP files: kebab-case or camelCase inside feature views (e.g. `movie-list.jsp`, `movie-detail.jsp`).
