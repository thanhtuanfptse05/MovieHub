# CLAUDE.md — MovieHub Project Memory & Conventions
<!-- Read AGENTS.md for full constitution and skill guidelines -->

## MANUAL MEMORY (Project Directives)

### Architecture & Constraints
- **Stack**: Java 17 LTS + Apache Tomcat 10.1 + Microsoft SQL Server + Apache Ant (NetBeans project).
- **Libraries**: ONLY use the 4 JARs in `allowedlib/` (`jakarta.servlet.jsp.jstl-2.0.0.jar`, `jakarta.servlet.jsp.jstl-api-2.0.0.jar`, `jaxb-api-2.1.jar`, `sqljdbc42.jar`). DO NOT add external dependencies.
- **JSP/JSTL**: 100% pure JSTL/EL. ZERO scriptlets (`<% ... %>`). Dynamic outputs must use `<c:out value="${...}" escapeXml="true" />`.
- **Database**: JPA 3.0 / Hibernate `EntityManager` only. Zero raw SQL concatenation.
- **Security**: Passwords hashed using BCrypt (cost >= 12). Protect `/admin/*` via `AdminAuthFilter`.

### Workflow Directives
- **Spec-First, Code-Second**: No implementation without approved `spec.md`, `plan.md`, `tasks.md` in `specs/`.
- **Skills Priority**:
  1. Use `codegraph_explore` / `codegraph explore` BEFORE reading files or ripgrep.
  2. Consult `graphify` architecture graphs for dependency overview.
  3. Use `/speckit-*` commands for spec generation, analysis, and task execution.
  4. Follow Superpowers TDD (`/test-driven-development`) and evidence verification (`/verification-before-completion`).
  5. Clean documentation and comments using `/humanizer`.
  6. Frontend Art Direction: Use `design-taste-frontend` (`taste-skill v2.1.5`) via `scripts/draw.mjs` for distinctive cinema aesthetics (public) and `draw.mjs --app` (admin/analytics), verified by `inspect.mjs`.
- **Git Delivery**: After passing the 15-item validation checklist in `checklists.md`, commit with Conventional Commits and push branch to GitHub.

### Build Commands
- Ant Compile: `& "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" compile`
- Ant Test: `& "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" test`
- Ant Package: `& "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" dist`

## PATTERNS TO FOLLOW
- Controller: `com.moviehub.controller.[module].[Feature]Servlet.java`
- Service: `com.moviehub.service.[Feature]Service.java`
- DAO: `com.moviehub.dao.[Entity]DAO.java`
- Entity: `com.moviehub.entity.[Entity].java`
- View: `web/WEB-INF/views/[module]/[feature].jsp`
- Test: `test/com/moviehub/service/[Feature]ServiceTest.java`
