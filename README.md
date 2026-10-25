# MovieHub — Cinematic Movie Streaming & Community Review Platform
<!-- Spec-Driven Development (SDD) & Agent-Driven Development (ADD) Showcase -->

MovieHub is a Java Ant Web Application developed according to **Spec-Driven Development (SDD)** and **Agent-Driven Development (ADD)** methodologies. It features a clean 3-tier MVC architecture running on Jakarta EE 10 / Tomcat 10.1, backed by Microsoft SQL Server.

---

## 🚀 Key Features & Modules
- **001-auth**: User Authentication (Register, Login, Session Management, Password Recovery via the R-01 session flow).
- **002-user-profile**: User Profile Management.
- **003-movie-catalog**: Movie Catalog, Multi-attribute Filtering, Keyword Search & Detail View.
- **004-favorites**: Personal Movie Watchlist / Bookmarking.
- **005-reviews-rating**: Community Star Ratings (1-5) & Written Reviews with Auto-calculated Average.
- **006-qa**: Interactive Q&A Discussions on Movies with content moderation.
- **007-admin-crud**: Administrative Management for Movies, Categories, and User Accounts with Soft-Delete.
- **008-admin-analytics**: Executive Dashboard with KPI counters, Top-viewed & Top-rated Reports.

---

## 🛠 Tech Stack & Strict Environment
- **Runtime**: Java SE 17 (LTS)
- **Web Application Server**: Apache Tomcat 10.1 (Jakarta EE 10 Web Profile, `jakarta.*` packages)
- **Database**: Microsoft SQL Server 2019 / 2022 (Port 1433)
- **Persistence**: JPA 3.0 / Hibernate `EntityManager` (Strictly parameterized queries)
- **View Layer**: Pure JSTL 2.0 & EL (`jakarta.tags.core`), Zero Java Scriptlets (`<% %>`), Built-in XSS Escaping
- **Build System**: Apache Ant (NetBeans 17 Ant Web Project)
- **Permitted Libraries**: Exclusively the 4 JARs in [`allowedlib/`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/allowedlib):
  - `jakarta.servlet.jsp.jstl-2.0.0.jar`
  - `jakarta.servlet.jsp.jstl-api-2.0.0.jar`
  - `jaxb-api-2.1.jar`
  - `sqljdbc42.jar`

---

## 📁 SDD Project Structure
```text
MovieHub/
├── .agents/skills/          # 43 Installed agent skills (Superpowers, Spec Kit, Taste Skill, etc.)
├── .codegraph/              # Fast semantic code intelligence index
├── .sdd/                    # SDD Architecture Brain
│   ├── constitution.md      # Immutable Project Constitution (Layers 1-4)
│   ├── shared_context.md    # Cross-agent synchronization state
│   ├── constraints/         # global.md, business.md, safety.md
│   └── rfcs/                # ADR-001 (Layered MVC), ADR-002 (Strict allowedlib)
├── .specify/                # Spec Kit templates & PowerShell workflows
├── allowedlib/              # 4 strictly permitted JAR libraries
├── docs/                    # Architecture, DB Schema & API Route Inventory
├── specs/                   # 8 Feature Modules with spec.md, plan.md, tasks.md, checklists.md
├── src/java/com/moviehub/   # 3-Tier MVC Java Source Code
├── test/com/moviehub/       # Automated Unit Tests
├── web/                     # Webdoc root, WEB-INF views (Pure JSTL), static assets
├── AGENTS.md                # Agent guidelines, skill synergies, and non-negotiable rules
└── CLAUDE.md                # Project memory and conventions
```

---

## ⚡ Build & Run
Database setup, SQL scripts and connection instructions: [database/README.md](database/README.md). The [schema design](docs/architecture/database.md) includes the entity relationships and constraints.

Compile the project using the NetBeans bundled Ant:
```powershell
& "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" compile
```

Run test suite:
```powershell
& "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" test
```

Build WAR distribution:
```powershell
& "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" dist
```

---

## 📜 Development Constitution
Development strictly follows the rule: **Spec-First, Code-Second**. All feature work begins in [`specs/`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/specs), requires approval of Acceptance Criteria in EARS syntax, adheres to the 15-item Validation Gate checklist in [`.github/pull_request_template.md`](file:///d:/wd%20c%20sang%20d/Documents/NetBeansProjects/MovieHub/.github/pull_request_template.md), and commits via Conventional Commits before pushing to GitHub.
