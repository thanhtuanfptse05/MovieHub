# ADR-002: Restriction to allowedlib Dependencies and Pure JSTL/EL
<!-- Architecture Decision Record -->
Status: ACCEPTED | Date: 2026-10-25 | Deciders: Team MovieHub

## Context
Project MovieHub must run strictly within the course evaluation environment (PRJ301 / NetBeans 17 / Tomcat 10.1 / SQL Server).
The evaluation rules mandate that only specific JARs provided in `allowedlib/` are permissible.
Using external dependencies or Maven plugins can cause build failure or rejection during evaluation.
Furthermore, legacy JSP scriptlets (`<% ... %>`) are a major source of XSS bugs, unmaintainable views, and violation of clean coding principles.

## Decision
1. **Permitted Libraries**: MovieHub will strictly only link and package the 4 JARs from `allowedlib/`:
   - `jakarta.servlet.jsp.jstl-2.0.0.jar`
   - `jakarta.servlet.jsp.jstl-api-2.0.0.jar`
   - `jaxb-api-2.1.jar`
   - `sqljdbc42.jar`
2. **Zero Scriptlet Rule**: JSPs must NEVER contain scriptlets (`<% %>`, `<%= %>`, `<%! %>`).
3. **Pure JSTL & EL**: All dynamic rendering must utilize standard JSTL 2.0 tags (`<c:forEach>`, `<c:if>`, `<c:choose>`, `<c:out>`) and Expression Language (`${...}`).
4. **XSS Protection**: All user-generated text must be XML-escaped via `<c:out ... escapeXml="true" />`.

## Consequences
- **Positive**: 100% compliance with evaluation constraints; zero dependency drift; clean, declarative JSP views; fortified XSS defense.
- **Negative**: Missing modern utility libraries (like Jackson, Lombok, Commons-Lang), requiring clean native Java implementations for utility helpers.
