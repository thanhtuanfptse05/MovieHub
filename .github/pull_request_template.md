## Pre-Commit & Validation Gate Checklist (MovieHub)
<!-- From SDD & ADD Playbook Section 16.6 -->

### 1. Code Quality & Standards
- [ ] Code compiles locally with zero errors: `& "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" compile`
- [ ] No `System.out.println` or temporary debug logs remaining
- [ ] No `TODO` or `FIXME` comments left in code
- [ ] Strict adherence to naming conventions in `AGENTS.md`
- [ ] **100% Pure JSTL/EL in JSP**: Zero Java scriptlets (`<% ... %>`)

### 2. Testing & Coverage
- [ ] All existing automated tests pass without regression
- [ ] Unit tests written for all new service business logic (min 80% coverage)
- [ ] Happy path, edge cases, and boundary conditions covered

### 3. Security & Safety Policies
- [ ] Passwords hashed with BCrypt (cost >= 12); no plaintext passwords in logs or code
- [ ] Input validation and sanitization applied to all endpoints
- [ ] Zero SQL string concatenation; parameterized JPA queries only
- [ ] All dynamic JSP variables escaped via `<c:out value="${...}" escapeXml="true" />`
- [ ] Strict usage of `allowedlib/` only (no extra external JARs)

### 4. Spec & Architecture Compliance
- [ ] Code satisfies all Acceptance Criteria (EARS) in corresponding `spec.md`
- [ ] No scope creep or unauthorized extra features
- [ ] Architecture follows 3-Tier MVC: Servlet -> Service -> JPA EntityManager -> JSP

### 5. Git & Delivery
- [ ] Commit messages follow Conventional Commits format (`feat:`, `fix:`, `docs:`, etc.)
- [ ] Feature branch pushed to remote GitHub repository
