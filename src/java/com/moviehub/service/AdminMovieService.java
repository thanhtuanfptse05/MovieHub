package com.moviehub.service;

import com.moviehub.dao.AdminCatalogDAO;
import com.moviehub.dto.AdminCatalogQuery;
import com.moviehub.dto.AdminMovieInput;
import com.moviehub.dto.AdminMovieItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.Category;
import com.moviehub.entity.Movie;
import com.moviehub.exception.AdminValidationException;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.NotFoundException;
import jakarta.persistence.EntityManager;
import java.net.URI;
import java.text.Normalizer;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Versioned catalog writes; every write is guarded and committed as one unit. */
public class AdminMovieService {
    private static final Set<String> STATUSES = Set.of("DRAFT", "PUBLISHED", "HIDDEN");
    private final AdminCatalogDAO dao;
    private final Clock clock;

    public AdminMovieService() { this(new AdminCatalogDAO(), Clock.systemUTC()); }
    public AdminMovieService(AdminCatalogDAO dao, Clock clock) {
        this.dao = Objects.requireNonNull(dao);
        this.clock = Objects.requireNonNull(clock);
    }

    public AdminCatalogQuery parseQuery(String q, String status, String page) {
        AdminCatalogQuery query = query(q, page);
        String value = text(status);
        if (!value.isEmpty()) {
            query.setStatus(value);
            if (!STATUSES.contains(value)) query.getErrors().put("status", "Trạng thái không hợp lệ.");
        }
        return query;
    }

    public PageResult<AdminMovieItem> listMovies(AdminCatalogQuery query) {
        requireValid(query.getErrors());
        return dao.read(em -> {
            long total = dao.countMovies(em, query.getQ(), query.getStatus());
            int pages = PageResult.totalPagesFor(total);
            int page = PageResult.clampPage(query.getPage(), pages);
            List<AdminMovieItem> items = new ArrayList<>();
            for (Movie movie : dao.findMovies(em, query.getQ(), query.getStatus(), (page - 1) * PageResult.PAGE_SIZE)) items.add(item(movie));
            return new PageResult<>(items, total, page, pages);
        });
    }

    public AdminMovieItem getMovie(Long id) {
        requireId(id);
        return dao.read(em -> item(find(em, id, false)));
    }

    /** Allows partial drafts, while enforcing every core field on every save. */
    public Map<String, String> validate(AdminMovieInput input) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (input == null) { errors.put("form", "Dữ liệu không hợp lệ."); return errors; }
        length(errors, "title", input.getTitle(), 200);
        length(errors, "description", input.getDescription(), 10000);
        slug(errors, input.getSlug(), 250);
        int maxYear = LocalDate.now(clock.withZone(ZoneId.of("Asia/Ho_Chi_Minh"))).getYear() + 2;
        number(errors, "releaseYear", input.getReleaseYear(), 1888, maxYear);
        number(errors, "durationMinutes", input.getDurationMinutes(), 1, 600);
        String status = text(input.getStatus());
        if (!STATUSES.contains(status)) errors.put("status", "Trạng thái không hợp lệ.");
        media(errors, "posterUrl", input.getPosterUrl(), false);
        media(errors, "videoUrl", input.getVideoUrl(), true);
        media(errors, "trailerUrl", input.getTrailerUrl(), true);
        Set<Long> ids = categoryIds(input.getCategoryIds(), errors);
        if ("PUBLISHED".equals(status)) {
            if (text(input.getPosterUrl()).isEmpty()) errors.put("posterUrl", "Hãy nhập ảnh bìa để xuất bản.");
            if (ids.isEmpty()) errors.put("categoryIds", "Hãy chọn ít nhất một thể loại để xuất bản.");
        }
        return errors;
    }

    public AdminMovieItem createMovie(Long actorId, AdminMovieInput input) {
        return dao.write(actorId, em -> {
            requireValid(validate(input));
            Set<Category> categories = selectedCategories(em, input);
            checkSlug(em, null, text(input.getSlug()));
            Movie movie = new Movie();
            Instant now = clock.instant();
            movie.setViewCount(0L);
            movie.setCreatedAt(now);
            movie.setUpdatedAt(now);
            apply(movie, input, categories);
            dao.persistMovie(em, movie);
            dao.flush(em);
            return item(movie);
        });
    }

    public AdminMovieItem updateMovie(Long actorId, Long id, Integer version, AdminMovieInput input) {
        requireId(id);
        return dao.write(actorId, em -> {
            Movie movie = find(em, id, true);
            requireVersion(movie.getVersion(), version);
            requireValid(validate(input));
            Set<Category> categories = selectedCategories(em, input);
            checkSlug(em, id, text(input.getSlug()));
            apply(movie, input, categories);
            movie.setUpdatedAt(clock.instant());
            dao.flush(em);
            return item(movie);
        });
    }

    public AdminMovieItem hideMovie(Long actorId, Long id, Integer version) {
        requireId(id);
        return dao.write(actorId, em -> {
            Movie movie = find(em, id, true);
            requireVersion(movie.getVersion(), version);
            if (!Movie.STATUS_HIDDEN.equals(movie.getStatus())) {
                movie.setStatus(Movie.STATUS_HIDDEN);
                movie.setUpdatedAt(clock.instant());
                dao.flush(em);
            }
            return item(movie);
        });
    }

    private Movie find(EntityManager em, Long id, boolean lock) {
        Movie movie = lock ? dao.findMovieForUpdate(em, id) : dao.findMovie(em, id);
        if (movie == null) throw new NotFoundException("Phim không tồn tại.");
        return movie;
    }

    private void checkSlug(EntityManager em, Long id, String slug) {
        if (dao.movieSlugExists(em, slug, id)) throw new AdminValidationException(Map.of("slug", "Đường dẫn này đã được sử dụng."));
    }

    private Set<Category> selectedCategories(EntityManager em, AdminMovieInput input) {
        Set<Category> result = new LinkedHashSet<>();
        for (Long id : categoryIds(input.getCategoryIds(), new LinkedHashMap<>())) {
            Category category = dao.findCategory(em, id);
            if (category == null || category.getDeletedAt() != null) {
                throw new AdminValidationException(Map.of("categoryIds", "Thể loại không tồn tại hoặc đã bị xóa."));
            }
            result.add(category);
        }
        return result;
    }

    private static void apply(Movie movie, AdminMovieInput input, Set<Category> categories) {
        movie.setTitle(text(input.getTitle()));
        movie.setSlug(text(input.getSlug()));
        movie.setDescription(text(input.getDescription()));
        movie.setReleaseYear(Integer.valueOf(text(input.getReleaseYear())));
        movie.setDurationMinutes(Integer.valueOf(text(input.getDurationMinutes())));
        movie.setPosterUrl(optional(input.getPosterUrl()));
        movie.setVideoUrl(optional(input.getVideoUrl()));
        movie.setTrailerUrl(optional(input.getTrailerUrl()));
        movie.setStatus(text(input.getStatus()));
        movie.setFeatured(input.isFeatured());
        // Keep the managed collection so link changes participate in its version check.
        movie.getCategories().clear();
        movie.getCategories().addAll(categories);
    }

    private static Set<Long> categoryIds(String[] values, Map<String, String> errors) {
        Set<Long> ids = new LinkedHashSet<>();
        if (values == null) return ids;
        for (String raw : values) {
            String value = text(raw);
            try {
                if (!value.matches("[0-9]{1,19}")) throw new NumberFormatException();
                long id = Long.parseLong(value);
                if (id < 1) throw new NumberFormatException();
                ids.add(id);
            } catch (NumberFormatException ex) { errors.put("categoryIds", "Thể loại không hợp lệ."); }
        }
        return ids;
    }

    static AdminMovieItem item(Movie movie) {
        AdminMovieItem item = new AdminMovieItem();
        item.setId(movie.getId()); item.setTitle(movie.getTitle()); item.setSlug(movie.getSlug());
        item.setDescription(movie.getDescription()); item.setReleaseYear(movie.getReleaseYear());
        item.setDurationMinutes(movie.getDurationMinutes()); item.setPosterUrl(movie.getPosterUrl());
        item.setVideoUrl(movie.getVideoUrl()); item.setTrailerUrl(movie.getTrailerUrl());
        item.setStatus(movie.getStatus()); item.setFeatured(movie.isFeatured());
        item.setVersion(movie.getVersion()); item.setViewCount(movie.getViewCount());
        item.setCreatedAt(date(movie.getCreatedAt())); item.setUpdatedAt(date(movie.getUpdatedAt()));
        List<Long> ids = new ArrayList<>();
        List<String> names = new ArrayList<>();
        for (Category category : movie.getCategories()) { ids.add(category.getId()); names.add(category.getName()); }
        item.setCategoryIds(List.copyOf(ids)); item.setCategoryNames(List.copyOf(names));
        return item;
    }

    static AdminCatalogQuery query(String q, String page) {
        AdminCatalogQuery query = new AdminCatalogQuery();
        query.setQ(text(q)); query.setPage(MovieService.parsePage(page));
        if (query.getQ().codePointCount(0, query.getQ().length()) > 200) query.getErrors().put("q", "Từ khóa tối đa 200 ký tự.");
        return query;
    }
    static String text(String value) {
        if (value == null) return "";
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFC);
        int start = 0, end = normalized.length();
        while (start < end && space(normalized.codePointAt(start))) start += Character.charCount(normalized.codePointAt(start));
        while (end > start && space(normalized.codePointBefore(end))) end -= Character.charCount(normalized.codePointBefore(end));
        return normalized.substring(start, end);
    }
    private static boolean space(int codePoint) { return Character.isWhitespace(codePoint) || Character.isSpaceChar(codePoint); }
    static String optional(String value) { String normalized = text(value); return normalized.isEmpty() ? null : normalized; }
    static String canonical(String value) { return text(value).toLowerCase(Locale.ROOT); }
    static Date date(Instant value) { return value == null ? null : Date.from(value); }
    static void requireValid(Map<String, String> errors) { if (!errors.isEmpty()) throw new AdminValidationException(errors); }
    static void requireId(Long id) { if (id == null || id < 1) throw new IllegalArgumentException("Mã không hợp lệ."); }
    static void requireVersion(Integer current, Integer submitted) {
        if (submitted == null || submitted < 1 || !submitted.equals(current)) throw new ConflictException("Dữ liệu đã thay đổi. Hãy tải lại trang.");
    }
    static void length(Map<String, String> errors, String field, String raw, int max) {
        String value = text(raw);
        int size = value.codePointCount(0, value.length());
        boolean columnOverflow = !"description".equals(field) && value.length() > max;
        if (size < 1 || size > max || columnOverflow || value.indexOf('\0') >= 0) errors.put(field, "Hãy nhập từ 1 đến " + max + " ký tự.");
    }
    static void slug(Map<String, String> errors, String raw, int max) {
        String value = text(raw);
        if (value.length() > max || !value.matches("[a-z0-9]+(-[a-z0-9]+)*")) errors.put("slug", "Chỉ dùng chữ thường không dấu, chữ số và dấu gạch nối.");
    }
    private static void number(Map<String, String> errors, String field, String raw, int min, int max) {
        String value = text(raw);
        try {
            if (!value.matches("[0-9]{1,9}")) throw new NumberFormatException();
            int number = Integer.parseInt(value);
            if (number < min || number > max) throw new NumberFormatException();
        } catch (NumberFormatException ex) { errors.put(field, "Hãy nhập số nguyên từ " + min + " đến " + max + "."); }
    }
    private static void media(Map<String, String> errors, String field, String raw, boolean mp4) {
        if (raw == null || raw.isBlank()) return;
        String value = text(raw);
        try {
            if (value.length() > 1000 || raw.codePoints().anyMatch(Character::isISOControl)) throw new IllegalArgumentException();
            URI uri = new URI(value);
            String scheme = uri.getScheme(), host = uri.getHost();
            boolean localHttp = "http".equalsIgnoreCase(scheme) && ("localhost".equalsIgnoreCase(host) || "127.0.0.1".equals(host));
            if (host == null || uri.getRawUserInfo() != null || !("https".equalsIgnoreCase(scheme) || localHttp)) throw new IllegalArgumentException();
            if (mp4 && (uri.getPath() == null || !uri.getPath().toLowerCase(Locale.ROOT).endsWith(".mp4"))) throw new IllegalArgumentException();
        } catch (Exception ex) { errors.put(field, mp4 ? "Hãy nhập URL HTTPS đến tệp MP4 hợp lệ." : "Hãy nhập URL ảnh HTTPS hợp lệ."); }
    }
}
