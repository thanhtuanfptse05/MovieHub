# Hướng dẫn giao việc cho agent triển khai

Ngày 2026-10-25 | Chỉ dùng sau khi bộ spec được chủ dự án duyệt. Không phải plan/tasks đã duyệt.

## 1. Đầu vào bắt buộc

Đọc AGENTS.md, [overview](overview.md), [system-rules](shared/system-rules.md), [data-contract](shared/data-contract.md), [decisions](shared/decisions.md) và spec module được giao. Chọn đúng module, không chạy tasks.md scaffold có cảnh báo SPEC-REVISION-NOTICE.

Mọi công việc UI đọc thêm [ui_rule.md](../ui_rule.md) và [design.md](../design.md). R-02/R-03 đã bắt buộc: DB là nguồn business data, không mock/hardcode/fallback; public/admin không có khối Business Rules/BR/FR/ghi chú developer. Không copy literal data hoặc chức năng ngoài spec từ HTML mẫu. Plan phải khai báo data lineage từng block; bàn giao phải có kiểm chứng đổi DB phản ánh lên màn hình, empty/error thật và copy sản phẩm.

Đã có 8 spec Draft. Chủ dự án xác nhận được đề xuất thêm JAR và thay đổi R-01: email ACTIVE khớp được đặt password mới trực tiếp, không xác thực email/mail/OTP/reset token; không cần SMTP. Chưa duyệt toàn bộ danh sách JAR hoặc cho tải/cài. Các phần nghiệp vụ/D-* còn lại và GOV-01/GOV-02 vẫn cần duyệt, chuẩn bị ENV-01 cho media. Khi chưa chốt, có thể lập plan dự thảo và inventory thư viện để review, không tự bỏ JPA/BCrypt hay thay công nghệ.

## 2. Chọn feature cho Spec Kit

Spec Kit xử lý từng feature, không xem cả 8 module như một feature. Các thư mục hiện có được tái sử dụng. Setup checklist gần nhất trỏ local feature context về 001-auth. Khi chuyển module, chỉ định đường dẫn rõ:

```powershell
$env:SPECIFY_FEATURE_DIRECTORY = 'specs/003-movie-catalog'
& '.specify/scripts/powershell/check-prerequisites.ps1' -Json -PathsOnly
```

Đọc kết quả FEATURE_SPEC/FEATURE_DIR trước khi gọi speckit-plan/tasks/analyze. Không suy ra module chỉ từ branch main. Chưa chạy speckit-analyze với plan/tasks cũ rồi gọi kết quả đó là xác nhận spec mới sẵn sàng code.

## 3. Thứ tự triển khai đề nghị

1. Chốt gate, dependency inventory, cấu hình ngoài Git; smoke test JPA/BCrypt/JSTL, schema/seed và hợp đồng chung. Không thêm mail dependency cho R-01.
2. 001 auth/guard; phần CRUD phim/thể loại 007 và public catalog 003 dựa cùng schema.
3. 002 profile, 004 favorites.
4. 005 review, 006 Q&A và phần moderation 007; phần user/role 007 kiểm chứng cùng auth.
5. 008 analytics và [acceptance](acceptance.md) toàn hệ thống.

Đây là thứ tự tích hợp, không sửa quyền sở hữu module. Mỗi module cần plan/tasks mới, phân việc MVC, mapping AC→task→test rồi analyze. Khi cần kiến trúc/code phải dùng CodeGraph/graphify theo AGENTS.md, không giả định graph tooling hiện tại chứng minh business code đã tồn tại.

## 4. Prompt giao module có thể dùng lại

> Thực hiện module được chỉ định theo phiên bản spec hiện hành đã được chủ dự án duyệt và các shared contract (001-auth v1.1.0/R-01; các module khác v1.0.0). Đọc decisions trước, kiểm tra gate thư viện/constitution đã có xác nhận cụ thể. Không dùng plan/tasks scaffold có cảnh báo. Lập lại plan/tasks và chạy speckit-analyze trước code; bám AC được giao, không tự thêm chức năng. Khi code dùng skill bắt buộc của dự án, viết kiểm thử nghiệp vụ có ý nghĩa, giữ JPA/transaction, zero scriptlet và escaping. Báo cáo file thay đổi, AC đã kiểm chứng, lệnh/kết quả test và phần chưa chạy. Không báo complete nếu còn blocker/test chưa có bằng chứng.

Thay “module được chỉ định” bằng một trong 8 đường dẫn trong overview; đính kèm phạm vi nếu chỉ làm một lát cắt của 007. Không gộp phạm vi auth/profile/user admin vì số UC gần nhau.

## 5. Checklist chứng cứ trước bàn giao sản phẩm

- Mọi AC P0 liên quan có scenario và bằng chứng; custom requirements checklist do reviewer đánh giá, không tự tick từ việc đã code.
- Lỗi/empty/media, ownership, role/session revoke, CSRF/XSS, unique/rollback và race được kiểm tra đúng hợp đồng.
- Ant compile/test/dist theo runner trong AGENTS.md; deploy Tomcat, DB thật và video thật; UC-03 không cần email test. Không coi build scaffold là kiểm chứng logic chưa viết.
- UI dùng design-taste-frontend và kiểm tra browser/viewport theo yêu cầu dự án.
- Sau khi feature thực sự hoàn thành, áp dụng quy trình review/commit/push trong AGENTS.md; không suy ra tài liệu Draft nghĩa là feature đã hoàn thành.
