> SPEC-REVISION-NOTICE (2026-10-25): Scaffold cũ, chưa đồng bộ với spec.md v1.0.0. Giữ để tham khảo lịch sử; KHÔNG dùng để triển khai hoặc xác nhận nghiệm thu. Sau khi duyệt spec/GOV, tạo lại artifact này và chạy speckit-analyze. Xem [overview](../overview.md) và [decisions](../shared/decisions.md).

# Tasks Breakdown: 006-qa
<!-- Actionable, Dependency-Ordered Task List -->

- [ ] **Task 1: Question and Answer Entities**
  - Implement `Question.java` and `Answer.java` with JPA relationships.
- [ ] **Task 2: DAOs**
  - Implement `QuestionDAO` and `AnswerDAO`.
- [ ] **Task 3: QAService (TDD)**
  - Write unit tests in `QAServiceTest.java`.
  - Implement `QAService.java`.
- [ ] **Task 4: QAServlet**
  - Implement request handlers for question creation, answering, and accepting.
- [ ] **Task 5: Views (Pure JSTL)**
  - Build Q&A discussion UI with `<c:out>`.
- [ ] **Task 6: Verification & Delivery**
  - Pass 15-item validation gate.
  - Commit `feat(qa): implement movie Q&A discussions`.
  - Push branch `feat/006-qa` to GitHub.
