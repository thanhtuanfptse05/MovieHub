<!-- Sync Impact Report: 2.1.0 -> 2.2.0 on 2026-10-26, direct owner instruction R-04.
Added DATA-02 Vietnamese & Unicode Character Integrity (Anti-Mojibake Policy) across database, compilation, scripts, and web layer.
-->
<!-- Sync Impact Report: 2.0.0 -> 2.1.0 on 2026-10-25, direct owner instructions R-02/R-03.
Added UI-01 database-backed UI data and UI-02 prohibition of business-rule/developer documentation in product UI.
Design baseline: design.md; enforceable details: ui_rule.md; entrypoint: AGENTS.md.
Minor version adds mandatory UI policies. R-01 password recovery and all unrelated constraints are preserved.
No unresolved placeholders; no application source/build/dependency changes in this documentation task.
-->
<!-- Amendment R-01: 1.0.0 -> 2.0.0 on 2026-10-25, direct owner instruction.
SEC-01 password recovery changed from email/reset-token verification to registered ACTIVE email match.
Major version records incompatible policy redefinition. Other hard constraints remain unchanged.
Synced with .specify/memory/constitution.md; auth spec v1.1.0 is the behavioral contract.
-->
# PROJECT CONSTITUTION — MovieHub
<!-- SDD & ADD Framework: Spec-Driven & Agent-Driven Development Playbook -->
Version: 2.2.0 | Status: LOCKED; owner amendments R-01/R-02/R-03/R-04 | Ratified: 2026-10-25 | Last Amended: 2026-10-26 | Project: MovieHub (PRJ301)

═══════════════════════════════════════════════════════════════════════════
  LAYER 1: HARD RULES — KHÔNG BAO GIỜ VI PHẠM (NON-NEGOTIABLE)
═══════════════════════════════════════════════════════════════════════════

## SEC-01: Password Security & Cryptography
- THE system SHALL hash user passwords using BCrypt (work factor >= 12).
- Plaintext passwords SHALL NEVER be stored, logged, transmitted in error messages, or hardcoded.
- Per direct owner decision R-01 (2026-10-25), password recovery accepts a registered ACTIVE email and opens the new-password form immediately, without email verification, OTP, SMTP or password-reset tokens. Preserve BCrypt and CSRF, bind the target to server session context, update credentialsVersion atomically and revoke old sessions. This flow does not verify email ownership; anyone knowing an ACTIVE email can reset that account. See specs/001-auth/spec.md v1.1.0.

## SEC-02: Authentication & Role-Based Authorization
- THE system SHALL authenticate users via HTTP Session (`HttpSession`).
- Admin endpoints (`/admin/*`) and actions SHALL be protected by `AdminFilter` or explicit role verification (`role == 'ADMIN'`).
- Unauthorized requests to protected resources MUST redirect to `/login` or return HTTP 403 Forbidden.
- Session IDs MUST be regenerated upon successful login to prevent Session Fixation attacks.

## SEC-03: SQL Injection Prevention & ORM Exclusivity
- THE system SHALL access database exclusively via JPA / Hibernate `EntityManager` or parameterized JPA queries (`TypedQuery`, named parameters `:param`).
- String concatenation with user inputs inside SQL/JPQL/HQL queries is STRICTLY FORBIDDEN.

## SEC-04: XSS Prevention & Zero Scriptlet Policy in JSP
- ALL Dynamic data rendered in JSP MUST use JSTL `<c:out value="${...}" escapeXml="true" />` or standard EL with HTML escaping.
- Java Scriptlets (`<% ... %>`, `<%= ... %>`, `<%! ... %>`) in JSP files are 100% PROHIBITED.
- Pure JSTL tag library (`jakarta.servlet.jsp.jstl`) and Expression Language (`${...}`) ONLY.

## LIB-01: Strict Allowed Libraries (allowedlib Only)
- THE system SHALL ONLY use libraries present in [allowedlib](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/allowedlib):
  1. `jakarta.servlet.jsp.jstl-2.0.0.jar`
  2. `jakarta.servlet.jsp.jstl-api-2.0.0.jar`
  3. `jaxb-api-2.1.jar`
  4. `sqljdbc42.jar`
- Adding external Maven dependencies, downloading external JARs, or using unauthorized libraries without explicit supervisor approval is STRICTLY PROHIBITED.

## DATA-01: Soft Delete for Business Entities
- THE system SHALL use soft deletion (`deleted_at` / `is_active` flag) for business entities: Users, Movies, Reviews, Categories, Questions.
- Physical hard delete is only permitted for transient data (expired password reset tokens).

## DATA-02: Vietnamese & Unicode Character Integrity (Anti-Mojibake Policy)
- THE system and development agents SHALL guarantee 100% data integrity for Vietnamese diacritics and Unicode text across all storage, scripts, and runtime layers. Character corruption (mojibake) is a Layer 1 hard failure.
- **Java Compilation**: Any standalone compilation of Java classes/seeders MUST explicitly specify `-encoding UTF-8` (e.g., `javac -encoding UTF-8 ...`). Never rely on Windows default ANSI/CP1252.
- **SQL Server Unicode Literals & Types**: All SQL statements containing Vietnamese literals MUST use the `N` prefix (e.g. `N'Inception: Kẻ Đánh Cắp Giấc Mơ'`), and text columns MUST use `NVARCHAR`/`NVARCHAR(MAX)`.
- **Database Utilities**: On Windows, `sqlcmd` MUST always specify `-I` (QUOTED_IDENTIFIER ON) and `-f 65001` (UTF-8 code page).
- **PowerShell / Terminal**: Terminal scripts MUST set `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` and write UTF-8 files without corrupting BOM/diacritics.
- **Web Tier**: All requests and responses MUST be filtered with UTF-8 encoding via `CharacterEncodingFilter`. All JSP views MUST declare `<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>` and `<meta charset="UTF-8">`.
- **Mandatory Verification Gate**: Agents MUST execute a verification query (`SELECT`) following any database insert/seed and inspect for mojibake patterns (`áº`, `Ä`, `Ã`, `Â`, `â€`, `á»`, `Æ`, `?`). Detection of corrupted characters blocks task completion until resolved.

## SPEC-01: Spec First, Code Second (SDD Core Principle)
- NO code SHALL be written without an approved `spec.md`, `plan.md`, and `tasks.md`.
- Implementation must strictly correspond to Acceptance Criteria defined in EARS syntax.

## UI-01: Database-Backed Business Data (R-02)

- UI business records, media metadata, account state, counts, ratings and analytics MUST originate from the database through JPA/Service/DTO/Servlet. Fixed business data in JSP/JS/CSS/JSON or UI-serving Java fixtures is prohibited.
- Missing/error data MUST use honest empty/error states, never mock fallback content. Demo data MUST be seeded into a DB and queried normally. Static UI tokens/labels and real media runtime state are limited to the exceptions in ui_rule.md.
- Agents MUST follow design.md and ui_rule.md, trace every business field to its data source and verify DB changes appear without editing UI code before handoff.

## UI-02: Product Copy, Not Engineering Documentation (R-03)

- Public and admin UI MUST NOT render Business Rules panels, BR/FR/UC/NFR codes, developer/agent notes, schema/SQL/ORM explanations or technical stack badges, including tooltip/accessibility copy.
- Keep rule documentation in specs/docs. Task labels, real statuses and short actionable validation/errors are permitted; server-side business enforcement remains mandatory.
- UI-01/UI-02 violations block completion; a visually complete mockup is not acceptable evidence of a working database-backed UI.

═══════════════════════════════════════════════════════════════════════════
  LAYER 2: ARCHITECTURAL CONSTRAINTS & BOUNDARIES
═══════════════════════════════════════════════════════════════════════════

## ARCH-01: Clean MVC Layer Boundaries
- System follows classic 3-Tier Web MVC Architecture:
  - **Controller**: Jakarta Servlets (`jakarta.servlet.http.HttpServlet`) handling HTTP requests, query parsing, validation, session, and forwarding to View.
  - **Service Layer**: Pure Java classes encapsulating business logic, transaction handling, and validations. Servlets MUST NOT contain database logic.
  - **Data Access Layer**: JPA / Hibernate `EntityManager` with DAO/Repository pattern.
  - **View Layer**: JSP files located under `/WEB-INF/views/` (inaccessible via direct URL) using JSTL and CSS/JS assets.

## ARCH-02: Jakarta EE 10 Namespace (Tomcat 10.1)
- THE system runs on Apache Tomcat 10.1 and Java 17.
- ALL Servlet, Filter, Listener, and JSP code MUST import `jakarta.*` packages (`jakarta.servlet.*`, `jakarta.servlet.http.*`, `jakarta.servlet.jsp.*`).
- Legacy `javax.servlet.*` imports SHALL NOT be used.

## ARCH-03: Error Handling & Security Disclosure
- Stack traces SHALL NEVER be exposed to the end user.
- Global error page configured in `web.xml` (e.g. 404, 500) to render user-friendly, consistent UI.
- All server errors must be logged using `java.util.logging.Logger`.

═══════════════════════════════════════════════════════════════════════════
  LAYER 3: ENGINEERING STANDARDS & SKILL INTEGRATION
═══════════════════════════════════════════════════════════════════════════

## TOOL-01: Code Navigation via CodeGraph & Graphify
- AI Agents MUST invoke `codegraph_explore` or `codegraph explore` BEFORE reading files or running broad greps when analyzing symbols, call hierarchies, or blast radius.
- System architectural reviews and dependency checks MUST leverage `graphify` knowledge graph (`graphify-out/`).

## TOOL-02: Spec-Driven Lifecycle via Spec Kit
- All feature specifications, updates, and clarifications MUST be generated and managed using Spec Kit commands (`/speckit-*`).
- Run `/speckit-analyze` to verify consistency across `spec.md`, `plan.md`, and `tasks.md`.

## TOOL-03: Engineering Discipline via Superpowers
- Follow Superpowers TDD discipline (`/test-driven-development`): Red -> Green -> Refactor.
- Implementation plans MUST be structured in 2-5 minute actionable increments (`/writing-plans`).
- Verification must produce verifiable evidence before claiming completion (`/verification-before-completion`).

## TOOL-04: Prose Quality via Humanizer
- All documentation, specs, and comments must pass through `/humanizer` to eliminate robotic AI writing patterns, stock clichés, and empty filler.

## TOOL-05: Frontend Art Direction via taste-skill (design-taste-frontend)
- All user-facing views and JSP interfaces MUST be designed using `design-taste-frontend` (`taste-skill v2.1.5`):
  - Public pages: Run `scripts/draw.mjs --sector culture` for distinct cinema art direction, atmospheric palettes, and zero AI template slop.
  - App screens (Admin & Analytics): Run `scripts/draw.mjs --app --kind analytics` for quiet, legible, data-focused panels.
  - Quality verification: Run `scripts/inspect.mjs` to audit layout and contrast in a headless browser before final JSP delivery.
  - Constraints: All UI must compile to pure JSTL views under `/WEB-INF/views/` with zero scriptlets.

═══════════════════════════════════════════════════════════════════════════
  LAYER 4: GIT CONVENTIONS & DELIVERY GATE
═══════════════════════════════════════════════════════════════════════════

## GIT-01: Branching Model
- `main`: Production-ready, protected branch.
- `develop`: Integration branch.
- `feat/{feature-name}`: Feature development branch created from `develop`.
- `spec/{feature-name}`: Spec definition and review branch.

## GIT-02: Feature Completion & GitHub Push Rule
- WHEN a feature passes all items on the 15-item Validation Gate Checklist:
  1. Commit changes using Conventional Commits (`feat:`, `fix:`, `docs:`, `spec:`, `test:`, `chore:`).
  2. Push the completed feature branch to the remote GitHub repository.
- No task is marked complete without successful local verification and clean Git commit/push.
