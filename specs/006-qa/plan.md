# Implementation Plan: 006-qa
<!-- Architecture & Engineering Plan aligned with spec.md v1.0.0 -->

## 1. Architectural Layers & File Map
- **Entities**:
  - `com.moviehub.entity.Question`: Full JPA mapping for `Questions` (`id`, `movieId`, `userId`, `content`, `status`, `moderatedBy`, `moderatedAt`, `createdAt`, `@Version version`).
  - `com.moviehub.entity.Answer`: Full JPA mapping for `Answers` (`id`, `questionId`, `userId`, `content`, `status`, `moderatedBy`, `moderatedAt`, `createdAt`, `@Version version`).
  - Register `Question` and `Answer` in `src/conf/persistence.xml`.
- **DTOs**:
  - `com.moviehub.dto.QuestionItem`: Public question item (`id`, `movieId`, `userId`, `authorName`, `authorAvatarUrl`, `content`, `status`, `createdAt`, `answerCount`).
  - `com.moviehub.dto.AnswerItem`: Public answer item (`id`, `questionId`, `userId`, `authorName`, `authorAvatarUrl`, `content`, `status`, `createdAt`).
  - `com.moviehub.dto.MyQaItem`: Private author submission (`id`, `type` [QUESTION/ANSWER], `targetId`, `questionTitle`, `content`, `status`, `createdAt`, `isParentPublic`).
  - `com.moviehub.dto.QuestionPage`, `com.moviehub.dto.AnswerPage`, `com.moviehub.dto.MyQaPage`.
- **DAOs**:
  - `com.moviehub.dao.QuestionDAO`:
    - `findById(Long id)`
    - `save(Question question)`
    - `findPublicQuestions(Long movieId, int page, int pageSize)`
    - `countPublicQuestions(Long movieId)`
    - `findUserQuestions(Long userId, Long movieId)`
  - `com.moviehub.dao.AnswerDAO`:
    - `findById(Long id)`
    - `save(Answer answer)`
    - `findPublicAnswers(Long questionId, int page, int pageSize)`
    - `countPublicAnswers(Long questionId)`
    - `findUserAnswers(Long userId, Long movieId)`
- **Services**:
  - `com.moviehub.service.QAService`:
    - Input validation: question (10..500 chars), answer (1..1000 chars), NFC trim.
    - Double submit protection: nonce validation and idempotency via `submissionId`.
    - Create question: verifies active actor and published movie, creates `PENDING`.
    - Create answer: verifies active actor, published movie, and `APPROVED` parent question at commit, creates `PENDING`.
    - Public queries: paginated questions (10/page), paginated answers (10/page), approved answer counters.
    - Private queries: user's personal submissions on the movie (`myQaPage`).
- **Controllers (Servlets)**:
  - `com.moviehub.controller.qa.QuestionCreateServlet`: `POST /questions/create` (movieId, content, submissionId, csrfToken -> 303 redirect to detail#qa).
  - `com.moviehub.controller.qa.AnswerCreateServlet`: `POST /answers/create` (questionId, content, submissionId, csrfToken -> 303 redirect to detail?questionId=...#qa).
  - `com.moviehub.controller.movie.MovieDetailServlet`: Updated to generate submission nonces, load questions, selected question answers, and user's private Q&A.
- **Views (JSP + JSTL)**:
  - Update `web/WEB-INF/views/movie/movie-detail.jsp` with `#qa` section:
    - Community questions list with answer count pills.
    - Selected question thread with answers list and answer submission form.
    - "Đặt câu hỏi" form with character counter and CSRF/submissionId tokens.
    - "Nội dung tôi gửi" private submissions card for logged-in users.
    - Guest login prompt.
    - 100% pure JSTL/EL with XML escaping (`<c:out escapeXml="true" />`), zero scriptlets.

## 2. Verification Strategy
- **Unit Tests**: `test/com/moviehub/service/QAServiceTest.java` (JUnit 4):
  - Validation: question length boundaries (9, 10, 500, 501), answer length boundaries (0, 1, 1000, 1001), blank text.
  - Create question: unpublished movie (404), inactive user (403), valid create sets `PENDING`.
  - Create answer: unpublished movie (404), pending/rejected question (404), non-existent question (404), valid create sets `PENDING`.
  - Nonce protection: replay with same submissionId returns cached redirect without duplicate insert.
  - Public visibility: parent rejected hides all answers; parent re-approved reveals only approved answers.
  - Private submissions: author sees own pending/rejected items without leaking other users' private parent text.
- **End-to-End Tests**: `scratch/test_e2e_qa.py`:
  - Full HTTP lifecycle on live Tomcat: question creation, answer creation, parent rejection cascade visibility, replay protection, anti-mojibake check on DB.
