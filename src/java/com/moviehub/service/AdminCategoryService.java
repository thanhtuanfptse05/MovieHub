package com.moviehub.service;

import com.moviehub.dao.AdminCatalogDAO;
import com.moviehub.dto.AdminCatalogQuery;
import com.moviehub.dto.AdminCategoryInput;
import com.moviehub.dto.AdminCategoryItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.Category;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.NotFoundException;
import jakarta.persistence.EntityManager;
import java.time.Clock;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/** Active category administration, including permanent reservation of deleted names. */
public class AdminCategoryService {
    private final AdminCatalogDAO dao;
    private final Clock clock;
    public AdminCategoryService() { this(new AdminCatalogDAO(), Clock.systemUTC()); }
    public AdminCategoryService(AdminCatalogDAO dao, Clock clock) { this.dao = Objects.requireNonNull(dao); this.clock = Objects.requireNonNull(clock); }
    public AdminCatalogQuery parseQuery(String q, String page) { return AdminMovieService.query(q, page); }
    public Map<String, String> validate(AdminCategoryInput input) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (input == null) { errors.put("form", "Dữ liệu không hợp lệ."); return errors; }
        AdminMovieService.length(errors, "name", input.getName(), 100);
        AdminMovieService.slug(errors, input.getSlug(), 120);
        return errors;
    }
    public PageResult<AdminCategoryItem> listCategories(AdminCatalogQuery query) {
        AdminMovieService.requireValid(query.getErrors());
        return dao.read(em -> {
            long total = dao.countCategories(em, query.getQ());
            int pages = PageResult.totalPagesFor(total), page = PageResult.clampPage(query.getPage(), pages);
            List<AdminCategoryItem> result = new ArrayList<>();
            for (Category category : dao.findCategories(em, query.getQ(), (page - 1) * PageResult.PAGE_SIZE)) result.add(item(category));
            return new PageResult<>(result, total, page, pages);
        });
    }
    public List<AdminCategoryItem> listActiveCategories() {
        return dao.read(em -> {
            List<AdminCategoryItem> result = new ArrayList<>();
            for (Category category : dao.findAllActiveCategories(em)) result.add(item(category));
            return result;
        });
    }
    public AdminCategoryItem getCategory(Long id) {
        AdminMovieService.requireId(id);
        return dao.read(em -> item(find(em, id)));
    }
    public AdminCategoryItem saveCategory(Long actorId, Long id, Integer version, AdminCategoryInput input) {
        if (id != null) AdminMovieService.requireId(id);
        return dao.write(actorId, em -> {
            Category category = id == null ? new Category() : find(em, id);
            if (id != null) AdminMovieService.requireVersion(category.getVersion(), version);
            AdminMovieService.requireValid(validate(input));
            String name = AdminMovieService.text(input.getName()), slug = AdminMovieService.text(input.getSlug());
            String key = AdminMovieService.canonical(name);
            Map<String, String> errors = new LinkedHashMap<>();
            // Java comparison preserves accents independently of the database's default collation.
            for (Category existing : dao.findAllCategories(em)) {
                if (id != null && id.equals(existing.getId())) continue;
                if (key.equals(AdminMovieService.canonical(existing.getName()))) errors.put("name", "Tên thể loại này đã được sử dụng.");
                if (slug.equals(existing.getSlug())) errors.put("slug", "Đường dẫn này đã được sử dụng.");
            }
            AdminMovieService.requireValid(errors);
            category.setName(name); category.setNameKey(key); category.setSlug(slug);
            if (id == null) { category.setCreatedAt(clock.instant()); dao.persistCategory(em, category); }
            dao.flush(em);
            return item(category);
        });
    }
    public void deleteCategory(Long actorId, Long id, Integer version) {
        AdminMovieService.requireId(id);
        dao.write(actorId, em -> {
            Category category = find(em, id);
            AdminMovieService.requireVersion(category.getVersion(), version);
            if (dao.categoryHasMovies(em, id)) throw new ConflictException("Thể loại đang được gán cho phim nên chưa thể xóa.");
            category.setDeletedAt(clock.instant()); dao.flush(em);
            return null;
        });
    }
    private Category find(EntityManager em, Long id) {
        Category category = dao.findCategory(em, id);
        if (category == null || category.getDeletedAt() != null) throw new NotFoundException("Thể loại không tồn tại.");
        return category;
    }
    private static AdminCategoryItem item(Category category) {
        AdminCategoryItem item = new AdminCategoryItem();
        item.setId(category.getId()); item.setName(category.getName()); item.setSlug(category.getSlug());
        item.setVersion(category.getVersion()); item.setCreatedAt(AdminMovieService.date(category.getCreatedAt()));
        return item;
    }
}
