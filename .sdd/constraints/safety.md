# Safety & Security Guardrails — MovieHub
<!-- SDD Constraint Layer 3: Agent Guardrails & AppSec Policy -->

## 1. Authentication & Session Safety
- Passwords MUST be encrypted using BCrypt (`BCrypt.hashpw(password, BCrypt.gensalt(12))`).
- Passwords MUST NEVER be stored in plain text, logged into server console/files, or sent in JSON/HTML attributes.
- When authenticating, invalidate existing session (`session.invalidate()`) and create a fresh session (`request.getSession(true)`) to prevent session fixation.
- Store minimal user profile in session (`UserDTO`: `id`, `email`, `fullName`, `role`). Never store the password hash in session.

## 2. SQL & Data Access Safety
- 100% of database queries must be executed via JPA / Hibernate `EntityManager` or named parameterized queries.
- ZERO raw string interpolation:
  - ❌ BAD: `"SELECT u FROM User u WHERE u.email = '" + email + "'"`
  - ✅ GOOD: `em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class).setParameter("email", email)`
- All write operations (Create, Update, Delete) must execute within an active JPA Transaction (`EntityTransaction`).
- Rollback transaction immediately on exception (`if (tx.isActive()) tx.rollback();`).

## 3. View & XSS Protection
- All dynamic values rendered in JSP must be escaped.
- ❌ BAD: `<%= request.getAttribute("message") %>`
- ❌ BAD: `<p>${user.bio}</p>` (unescaped)
- ✅ GOOD: `<c:out value="${user.bio}" escapeXml="true" />`
- Static CSS and JavaScript files must be served from designated `/assets/` directory.

## 4. CSRF & Form Submission Safety
- Mutating POST forms (Registration, Login, Reviews, CRUD actions) should validate HTTP Referer / Origin or include a session-bound token where state-changing actions take place.

## 5. Agent Safety Guardrails
- **No Hallucinated Libraries**: The agent is FORBIDDEN from adding any library not in `allowedlib/`.
- **No Scriptlet Generation**: The agent must NEVER write scriptlets in JSPs.
- **Spec Compliance**: The agent must NEVER invent extra business logic or UI fields not defined in the corresponding `spec.md`.
- **Human Verification Gate**: All code must pass the 15-item Validation Gate before being committed and pushed.
