> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Implementation Plan: 006-qa
<!-- Architecture & Engineering Plan -->

## 1. Architectural Layers & File Map
- **Entities**:
  - `com.moviehub.entity.Question` (Table: `Questions`)
  - `com.moviehub.entity.Answer` (Table: `Answers`)
- **DAOs**:
  - `com.moviehub.dao.QuestionDAO` (`findByMovieId`, `save`, `delete`, `markAnswerAccepted`)
  - `com.moviehub.dao.AnswerDAO` (`findByQuestionId`, `save`, `delete`)
- **Services**: `com.moviehub.service.QAService`
- **Controllers (Servlets)**:
  - `com.moviehub.controller.qa.QAServlet`
- **Views (JSP + JSTL)**:
  - Included as fragment in `movie-detail.jsp`

## 2. Verification Strategy
- Unit tests: `QAServiceTest.java` (Validation limits, permission checks).
- Web tests: Verify questions and answers render properly under movie details.
