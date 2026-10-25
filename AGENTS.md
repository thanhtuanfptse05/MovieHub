# MovieHub — AI Agent Guidelines & Engineering Constitution
<!-- Follows Spec-Driven Development (SDD) & Agent-Driven Development (ADD) Playbook -->
Version: 2.1.0 | Ratified: 2026-10-25 | Project: MovieHub (PRJ301 Java Ant Web Application)

## 0. Persistent UI Instructions — Read Before Every UI Task

- MUST read [ui_rule.md](ui_rule.md), [design.md](design.md), and the current module spec before creating, editing, reviewing or testing any UI. The supplied HTML is a visual reference only; its sample content and developer annotations are not runtime requirements.
- **R-02 / UI-DATA-01: NO HARDCODED BUSINESS DATA.** All movie/user/category/favorite/review/Q&A/media metadata/count/rating/KPI data MUST come from SQL Server through JPA → Service → DTO → Servlet → JSP. Do not move fixed arrays into Java services, static JSON, localStorage or mock endpoints to evade this rule. Missing/failed DB data MUST render honest empty/error states; seed demo data into the DB rather than into UI code.
- **R-03 / UI-COPY-01: NO BUSINESS-RULE DOCUMENTATION IN PRODUCT UI.** Never render Business Rules/BusinessRule panels, BR/FR/UC/NFR references, schema/SQL/JPA/transaction explanations, stack badges or developer/agent notes on public OR admin pages, including tooltips and accessibility text. Keep these in docs. Short task labels, input guidance, real statuses and understandable errors remain valid product copy.
- Static UI labels, brand assets, neutral placeholders, CSS tokens and domain-option labels are allowed within UI-DATA-03; they MUST NOT contain fabricated entity records or statistics. Browser media state may come from the actual video element, never from a simulated timeline.
- Existing feature specs govern scope. Do not copy unsupported 4K/Dolby claims, weekly trends, director/cast data, notification/like/accepted-answer/audit-log controls or dead links from the mockup.
- Before UI handoff, demonstrate DB-to-screen data lineage and a DB fixture change reflected without editing UI source; check empty/error states and absence of generated engineering copy. UI-DATA-01/UI-COPY-01 violations block completion even if the page looks finished. Follow the full checklist in ui_rule.md.

---

## 1. Project Overview & Context
- **Name**: MovieHub — Online Movie Streaming, Community Q&A & Review Management Platform.
- **Project Model**: NetBeans 17 Ant Web Application (Java 17 LTS, Apache Tomcat 10.1).
- **Core Architecture**: Clean 3-Tier Web MVC (Jakarta Servlet -> Service -> JPA EntityManager -> JSP View).
- **Database**: Microsoft SQL Server (Port 1433, 9 Tables: `Users`, `Movies`, `Categories`, `MovieCategories`, `Favorites`, `Reviews`, `Questions`, `Answers`, `PasswordResetTokens`).
- **Development Philosophy**: **Spec-First, Code-Second**; Verification before completion; Commit & push to GitHub upon feature completion.

---

## 2. Hard Constraints (Layer 1 Rules — Non-Negotiable)

### Rule 1: Strict Library Restriction (`allowedlib` Only)
The application MUST strictly run with only the 4 JAR libraries located in [`allowedlib`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/allowedlib) and deployed to `web/WEB-INF/lib/`:
1. `jakarta.servlet.jsp.jstl-2.0.0.jar`
2. `jakarta.servlet.jsp.jstl-api-2.0.0.jar`
3. `jaxb-api-2.1.jar`
4. `sqljdbc42.jar`
> [!CAUTION]
> Under NO circumstance may the agent add external Maven dependencies, download third-party JARs (e.g. Jackson, Gson, Lombok, Apache Commons), or modify the build setup to pull outside libraries. All utility code must be written in pure Java 17.

### Rule 2: Zero Scriptlet Policy & Strict JSTL / EL in JSP
- **Zero Scriptlets**: Java Scriptlet tags (`<% ... %>`, `<%= ... %>`, `<%! ... %>`) are **100% PROHIBITED** in any `.jsp` file.
- **Pure JSTL**: All UI iteration, conditionals, and formatting MUST use standard JSTL 2.0 tags (`<c:forEach>`, `<c:if>`, `<c:choose>`, `<c:out>`, `<fmt:formatDate>`).
- **Tomcat 10.1 Taglib URIs**:
  ```jsp
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
  <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
  <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
  ```
- **XSS Defense**: Any dynamic text originating from user input or database MUST be escaped:
  ```jsp
  <c:out value="${movie.title}" escapeXml="true" />
  ```
- **View Location**: All views must reside under `/WEB-INF/views/` (never in public web root) to prevent bypass of Servlets.

### Rule 3: Database Access Exclusively via JPA / Hibernate
- Database operations MUST be executed via JPA 3.0 / Hibernate `EntityManager` or named parameterized queries (`TypedQuery`, `:namedParam`).
- **Zero SQL String Concatenation**: Raw SQL string concatenation is strictly banned.
- All mutating database operations must run within active JPA transactions (`EntityTransaction`) with automatic rollback on failure.

### Rule 4: Security & Authentication Guardrails
- **Password Hashing**: User passwords MUST be hashed using BCrypt (cost >= 12). Plaintext passwords SHALL NEVER be stored, printed to console, or passed in URLs.
- **Session Security**: Session ID must be regenerated on login (`session.invalidate()` -> `request.getSession(true)`).
- **Admin Isolation**: All `/admin/*` routes must be guarded by `AdminAuthFilter` or role checks.

---

## 3. Workflow Discipline: Spec-First, Code-Second

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ 1. SPECIFY      │ ----> │ 2. PLAN & TASKS │ ----> │ 3. IMPLEMENT    │
│ /speckit-specify│       │ /speckit-plan   │       │ Superpowers TDD │
│ /speckit-clarify│       │ /speckit-tasks  │       │ Red-Green-Refac │
└─────────────────┘       └─────────────────┘       └────────┬────────┘
                                                             │
┌─────────────────┐       ┌─────────────────┐                │
│ 5. GITHUB PUSH  │ <---- │ 4. VALIDATE     │ <──────────────┘
│ feat/{name}     │       │ 15-Item Check   │
│ Conventional Msg│       │ ant compile/test│
└─────────────────┘       └─────────────────┘
```

1. **Phase 1: Spec Definition**:
   - Every feature must have an approved `spec.md` with User Stories and Acceptance Criteria in EARS syntax (`Ubiquitous`, `Event-driven`, `State-driven`, `Unwanted`).
   - Use `/speckit-clarify` to resolve any ambiguity before planning.
2. **Phase 2: Planning & Tasks**:
   - Generate `plan.md` mapping MVC layers (Controller, Service, DAO, JSP).
   - Generate `tasks.md` with 2-5 minute atomic tasks and clear dependency ordering.
   - Run `/speckit-analyze` to verify spec-plan-tasks consistency.
3. **Phase 3: Implementation**:
   - Write unit tests first (`/test-driven-development`).
   - Implement business logic in Service layer -> Controller -> JSP View.
4. **Phase 4: Validation Gate**:
   - Check all 15 items in `checklists.md`.
   - Verify code compiles cleanly with local Ant:
     ```powershell
     & "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" compile
     ```
5. **Phase 5: GitHub Delivery**:
   - When a feature is complete and verified:
     ```powershell
     git add .
     git commit -m "feat(module): description conforming to conventional commits"
     git push origin feat/{feature-name}
     ```

---

## 4. Installed Skills & Required Tool Synergies

You have 42 modern agent skills pre-installed in [`.agents/skills/`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/.agents/skills). You MUST utilize them systematically:

### 1. Code Intelligence & Fast Navigation (MANDATORY BEFORE GREP/READ)
- **`codegraph_explore` / `codegraph`**:
  - **Rule**: Whenever you need to read symbol definitions, trace function callees/callers, or examine blast radius, you MUST use `codegraph_explore` (or CLI `codegraph explore "<query>"`) BEFORE reading entire files or running ripgrep.
  - The SQLite knowledge graph at [`.codegraph/`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/.codegraph) gives you exact line-numbered source code and call hierarchies in a single step.
- **`graphify`**:
  - **Rule**: Before making architectural decisions or cross-module refactorings, query the project graph via `query_graph`, `graphify explain "<Class>"`, or inspect [`graphify-out/GRAPH_REPORT.md`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/graphify-out/GRAPH_REPORT.md) to detect God Nodes and maintain architectural boundaries.

### 2. Spec-Driven Development Suite (`github/spec-kit`)
- `/speckit-constitution`: Check or update project constitution.
- `/speckit-specify`: Create or update feature specs from requirements.
- `/speckit-clarify`: Ask targeted clarification questions before planning.
- `/speckit-plan`: Generate implementation plan from spec.
- `/speckit-tasks`: Break down plan into dependency-ordered tasks.
- `/speckit-analyze`: Non-destructive cross-artifact consistency audit.
- `/speckit-implement`: Orchestrate execution of tasks.
- `/speckit-converge`: Verify codebase against spec and add missing work.
- `/speckit-bug-assess`, `/speckit-bug-fix`, `/speckit-bug-test`: Bug triage workflow.

### 3. Engineering Rigor (`obra/superpowers`)
- `/brainstorming`: Explore design trade-offs before any creative feature work.
- `/writing-plans` & `/executing-plans`: Break work into 2-5 min steps with verification commands.
- `/test-driven-development`: Red-Green-Refactor cycle for business logic.
- `/systematic-debugging`: 4-phase root-cause analysis for any bug or test failure.
- `/verification-before-completion`: MANDATORY evidence verification before claiming any task is done.
- `/requesting-code-review` & `/receiving-code-review`: Rigorous code quality audit.

### 4. Code & Text Refinement
- `/humanizer`: Polish documentation, specs, and comments to eliminate robotic AI cliches, overused jargon, and empty filler.
- `/frontend-design`: Guidance for distinctive, intentional visual layout.
- `/webapp-testing`: Automated browser interaction and screenshot verification using Playwright.
- `/security-best-practices` & `/security-threat-model`: Identify threat boundaries, SQL injection risks, and XSS vulnerabilities.

### 5. Frontend Art Direction & Anti-Slop UI Engine (`taste-skill` / `design-taste-frontend`)
The **`design-taste-frontend`** skill ([`taste-skill v2.1.5`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/.agents/skills/design-taste-frontend)) is the **MANDATORY art direction engine** for all MovieHub views to guarantee distinctive, cinema-grade aesthetics and eliminate generic AI slop:
- **Public Cinema Pages (Home, Movie Catalog, Movie Detail, Watchlist)**:
  - Run art direction deal:
    ```powershell
    node .agents/skills/design-taste-frontend/scripts/draw.mjs --sector culture --brief "MovieHub - Cinematic Movie Streaming & Community Review Platform"
    ```
  - **Cinema Aesthetics**: Dark cinematic background, high typographic contrast, immersive backdrop imagery, distinct color accents (e.g. amber, neon cyan, warm gold), zero boring centered hero cards.
- **Admin & Management Screens (Dashboard, Analytics, Movie/User CRUD)**:
  - Run app-screen design deal:
    ```powershell
    node .agents/skills/design-taste-frontend/scripts/draw.mjs --app --kind analytics --brief "MovieHub Admin Analytics & Content Management"
    ```
  - **App Screen Discipline**: Quiet panels, aligned numeric figures, color reserved strictly for KPI status tags (`ACTIVE`, `PENDING`, `BANNED`), dense and readable tables, collapsable navigation on mobile.
- **Real Imagery & Open Archives**:
  - Run `node .agents/skills/design-taste-frontend/scripts/assets.mjs` to fetch authentic film photography and public domain cinema assets with attribution.
- **Browser Quality Inspection**:
  - Run `node .agents/skills/design-taste-frontend/scripts/inspect.mjs` to test rendered views in headless browser across 3 viewports (desktop, tablet, mobile) and verify zero alignment or contrast slop.
- **Strict MovieHub Guardrail Compatibility**:
  - All UI generated under `design-taste-frontend` MUST compile into pure JSP + JSTL views under `/WEB-INF/views/`.
  - **100% Pure JSTL/EL**: ZERO Java scriptlets (`<% %>`). Dynamic attributes rendered via `<c:out value="${...}" escapeXml="true" />`.
  - All stylesheets placed in `/assets/css/` and scripts in `/assets/js/`.

---

## 5. Directory Structure & Spec Mapping

```
MovieHub/
├── .agents/skills/              # 42 Installed agent skills
├── .codegraph/                  # Fast semantic code intelligence index
├── .github/pull_request_template.md # 15-item validation gate
├── .sdd/                        # Core SDD architecture & constraints
│   ├── constitution.md          # Project constitution (Layer 1-4)
│   ├── shared_context.md        # Cross-agent sync & active state
│   ├── constraints/             # global.md, business.md, safety.md
│   ├── rfcs/                    # Architecture Decision Records (ADRs)
│   └── reviews/                 # Spec review & audit logs
├── .specify/                    # Spec Kit configuration & templates
├── allowedlib/                  # The ONLY 4 permitted JAR libraries
├── docs/                        # Architecture & API documentation
│   ├── api/README.md            # Servlet routes & contracts
│   └── architecture/            # Architecture overview & schema
├── nbproject/                   # NetBeans Ant project configuration
├── specs/                       # Feature specifications (8 core modules)
│   ├── overview.md              # System roadmap & status
│   ├── template.md              # Standard feature template
│   ├── 001-auth/                # UC-01, UC-02, UC-03 (spec, plan, tasks, checklists)
│   ├── 002-user-profile/        # UC-04, UC-14
│   ├── 003-movie-catalog/       # UC-05, UC-06, UC-07, UC-17
│   ├── 004-favorites/           # UC-08
│   ├── 005-reviews-rating/      # UC-09, UC-15
│   ├── 006-qa/                  # UC-10, UC-11, UC-15
│   ├── 007-admin-crud/          # UC-12, UC-13, UC-14
│   └── 008-admin-analytics/     # UC-16
├── src/
│   ├── conf/persistence.xml     # JPA configuration
│   └── java/com/moviehub/       # Controller, Service, DAO, Entity, Filter, Util
├── test/com/moviehub/service/   # Unit test suites
└── web/
    ├── WEB-INF/
    │   ├── lib/                 # The 4 allowed JARs
    │   ├── views/               # JSP views (auth, user, movie, admin, etc.)
    │   └── web.xml              # Deployment descriptor & servlet mappings
    └── assets/                  # CSS, JS, Images, Icons
```

---

## 6. Local Build & Test Commands
Always use the NetBeans bundled Ant runner on Windows:
- **Compile Project**:
  ```powershell
  & "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" compile
  ```
- **Run Unit Tests**:
  ```powershell
  & "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" test
  ```
- **Build WAR Distribution**:
  ```powershell
  & "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" dist
  ```
