<!-- Sync Impact Report: 2.0.0 -> 2.1.0; amended 2026-10-25.
Added Principle VIII: database-backed UI business data (owner R-02) and no business-rule/developer
documentation in product UI (owner R-03). Minor version adds enforceable UI policies.
Design baseline: design.md; detailed rules: ui_rule.md; persistent agent entrypoint: AGENTS.md.
R-01 and all unrelated principles preserved; no unresolved template placeholders.
-->
<!-- Previous Sync Impact Report: 1.0.0 -> 2.0.0; amended 2026-10-25.
Modified Principle V: replace verified email/reset-token recovery with direct email-match recovery,
per explicit owner request R-01. This is a backward-incompatible security-policy redefinition.
Added: Governance amendment note. Removed requirement: 15-minute password-reset token.
Preserved: BCrypt, CSRF, session revocation and all unrelated principles. No template placeholders deferred.
Canonical detailed project copy .sdd/constitution.md must reflect the same R-01/version.
-->
# PROJECT CONSTITUTION — MovieHub
<!-- Synced with .sdd/constitution.md -->
Version: 2.1.0 | Status: LOCKED; owner amendments R-01/R-02/R-03 | Ratified: 2026-10-25 | Last Amended: 2026-10-25 | Project: MovieHub (PRJ301)

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
- Owner decision R-01 (2026-10-25): a registered ACTIVE email opens the new-password form directly; no email verification, OTP, SMTP or reset tokens. Keep BCrypt, CSRF, server session context, atomic credentialsVersion update and old-session revocation. Email ownership is not verified; anyone knowing that email can reset the account. See specs/001-auth/spec.md v1.1.0.

### VI. Tooling & Skills Maximization
- Always invoke `codegraph_explore` / `codegraph` before grepping or reading files.
- Consult `graphify` architecture graphs for dependency analysis.
- Use `speckit-*` commands for spec lifecycle, and Superpowers TDD for implementation.
- Filter prose and documentation through `humanizer`.
- Frontend Art Direction: Mandate `design-taste-frontend` (`taste-skill v2.1.5`) via `scripts/draw.mjs` (culture/cinema for public, analytics for admin) and verify with `scripts/inspect.mjs`.

### VII. Git Discipline & GitHub Delivery
- Feature work occurs on `feat/{feature-name}` branches.
- Once a feature is completed and verified against the checklist, code must be committed with Conventional Commits and pushed to GitHub.

### VIII. UI Data Integrity and Product Copy (R-02/R-03)

- Agents MUST read design.md, ui_rule.md and the current feature spec before any UI work.
- Business records, entity media, statuses, counts, ratings and analytics MUST come from the database
  through JPA/Service/DTO/Servlet; fixed data in views, scripts, static payloads or UI-serving Java
  fixtures is prohibited. Seed demo records into a DB; missing/error data MUST use honest states.
- Product UI, including admin/tooltips/accessibility text, MUST NOT render Business Rules panels,
  BR/FR/UC/NFR codes, developer notes, schema/SQL/ORM explanations or stack badges. Rule documentation
  stays in specs/docs. Real statuses, task labels and short actionable validation/errors are allowed.
- Static design tokens/labels/neutral placeholders and actual media runtime state are limited to
  ui_rule.md exceptions; they MUST NOT fabricate business content. Violations block completion.

## Governance

Amendments MUST record the owner's explicit instruction, date and affected policy, and synchronize
the detailed project constitution. R-01 is authorized by the owner's request on 2026-10-25 to remove
email verification from password recovery. R-02/R-03 are the owner's requirements to prohibit
hardcoded UI business data and visible business-rule/engineering documentation. These amendments
do not approve unrelated Draft feature requirements or JAR installations.
Use a major version for incompatible policy removals/redefinitions, minor for added policy, and patch
for wording-only corrections. Review spec/plan/task consistency before implementation.
