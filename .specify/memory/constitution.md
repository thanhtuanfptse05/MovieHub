# PROJECT CONSTITUTION — MovieHub
<!-- Synced with .sdd/constitution.md -->
Version: 1.0.0 | Status: LOCKED | Ratified: 2026-10-25 | Project: MovieHub (PRJ301)

## Core Principles

### I. Spec-First, Code-Second (NON-NEGOTIABLE)
- NO code shall be written without an approved `spec.md`, `plan.md`, and `tasks.md`.
- Implementation must strictly satisfy Acceptance Criteria defined in EARS syntax.

### II. Strict Library Restrictions (allowedlib Only)
- The application SHALL ONLY use the 4 JAR libraries located in `allowedlib/`:
  1. `jakarta.servlet.jsp.jstl-2.0.0.jar`
  2. `jakarta.servlet.jsp.jstl-api-2.0.0.jar`
  3. `jaxb-api-2.1.jar`
  4. `sqljdbc42.jar`
- Adding external Maven packages, new JARs, or unauthorized dependencies is strictly prohibited.

### III. Zero Scriptlet Policy in JSP & Pure JSTL/EL
- Java Scriptlets (`<% ... %>`, `<%= ... %>`, `<%! ... %>`) in JSP files are 100% prohibited.
- Views must use pure JSTL tag library (`jakarta.servlet.jsp.jstl`) and Expression Language (`${...}`).
- All dynamic output rendered from user input MUST be escaped via `<c:out value="${...}" escapeXml="true" />` to prevent XSS.

### IV. Layered MVC Boundaries & JPA Persistence
- Controller (Jakarta Servlet) -> Service (Business logic) -> Data Access (JPA EntityManager) -> View (JSP in `/WEB-INF/views/`).
- Servlets only parse requests, validate input, invoke services, and forward to JSP.
- No direct database queries in Servlets. All DB queries via JPA EntityManager with parameterized queries.

### V. Security & Cryptography
- Passwords must be hashed using BCrypt (cost >= 12). Plaintext passwords never stored or logged.
- Role-based authorization for `/admin/*` routes via filters.
- Password reset tokens must be cryptographically secure with 15-minute expiration.

### VI. Tooling & Skills Maximization
- Always invoke `codegraph_explore` / `codegraph` before grepping or reading files.
- Consult `graphify` architecture graphs for dependency analysis.
- Use `speckit-*` commands for spec lifecycle, and Superpowers TDD for implementation.
- Filter prose and documentation through `humanizer`.

### VII. Git Discipline & GitHub Delivery
- Feature work occurs on `feat/{feature-name}` branches.
- Once a feature is completed and verified against the checklist, code must be committed with Conventional Commits and pushed to GitHub.
