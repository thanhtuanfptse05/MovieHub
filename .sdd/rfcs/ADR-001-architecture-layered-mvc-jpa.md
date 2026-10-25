# ADR-001: 3-Tier Layered MVC Architecture with JPA EntityManager
<!-- Architecture Decision Record -->
Status: ACCEPTED | Date: 2026-10-25 | Deciders: Team MovieHub

## Context
MovieHub is an enterprise Java Web application developed as an Ant project targeting Tomcat 10.1 (Jakarta EE 10) and SQL Server.
We need an architectural pattern that enforces separation of concerns, testability, maintainability, and alignment with academic PRJ301 standards.

## Decision
We adopt a classic 3-Tier Web MVC architecture:
1. **Controller Layer**: Jakarta Servlets (`jakarta.servlet.http.HttpServlet`) mapped in `web.xml` or via `@WebServlet`. Controllers are solely responsible for request/response handling, input binding, session management, and view dispatching.
2. **Service Layer**: Dedicated Java service classes containing transactional domain logic and business rule enforcement.
3. **Data Access Layer**: Generic and specific DAO pattern utilizing JPA 3.0 / Hibernate `EntityManager` with parameterized `TypedQuery`.
4. **View Layer**: Server-side JSP templates located in `/WEB-INF/views/`, utilizing pure JSTL and Expression Language.

## Consequences
- **Positive**: Clear separation of responsibilities; business logic decoupled from HTTP objects; persistence layer abstracted by JPA; easier unit testing.
- **Negative**: Requires boilerplates for DTOs and Servlets; team members and agents must strictly follow layer boundaries.
