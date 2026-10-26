package com.moviehub.service;

import com.moviehub.dao.AdminCatalogDAO;
import com.moviehub.dto.AdminCatalogQuery;
import com.moviehub.dto.AdminCategoryInput;
import com.moviehub.dto.AdminCategoryItem;
import com.moviehub.dto.AdminMovieInput;
import com.moviehub.dto.AdminMovieItem;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.Category;
import com.moviehub.entity.Movie;
import com.moviehub.exception.AdminValidationException;
import com.moviehub.exception.ConflictException;
import com.moviehub.exception.NotFoundException;
import jakarta.persistence.EntityManager;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/** Exercises production service decisions with a small persistence boundary double. */
public class AdminCatalogMutationTest {
    private static final Instant NOW = Instant.parse("2026-10-26T02:00:00Z");
    private MemoryCatalog dao;
    private AdminMovieService movies;
    private AdminCategoryService categories;

    @Before public void setup() {
        dao = new MemoryCatalog();
        Clock clock = Clock.fixed(NOW, ZoneOffset.UTC);
        movies = new AdminMovieService(dao, clock);
        categories = new AdminCategoryService(dao, clock);
        dao.categories.put(3L, category(3L, "H\u00e0nh \u0111\u1ed9ng", "hanh-dong"));
        dao.categories.put(4L, category(4L, "T\u00e2m l\u00fd", "tam-ly"));
    }

    @Test public void createDefaultsAndServerFieldsAreGeneratedAndIdsDeduplicated() {
        AdminMovieInput input = AdminCatalogServiceTest.validMovie();
        input.setTitle("  Cafe\u0301  ");
        input.setCategoryIds(new String[]{"3", "3", "4"});
        AdminMovieItem saved = movies.createMovie(99L, input);
        assertNotNull(saved.getId());
        assertEquals("Caf\u00e9", saved.getTitle());
        assertEquals("DRAFT", saved.getStatus());
        assertFalse(saved.isFeatured());
        assertEquals(Long.valueOf(0), saved.getViewCount());
        assertEquals(NOW, saved.getCreatedAt().toInstant());
        assertEquals(NOW, saved.getUpdatedAt().toInstant());
        assertEquals(List.of(3L, 4L), saved.getCategoryIds());
        assertNull(saved.getVideoUrl());
    }

    @Test public void editReplacesLinksAndPreservesCreationAndViews() {
        Movie existing = existingMovie();
        AdminMovieInput input = AdminCatalogServiceTest.validMovie();
        input.setCategoryIds(new String[]{"4"});
        input.setFeatured(true);
        AdminMovieItem saved = movies.updateMovie(99L, 8L, 5, input);
        assertEquals(List.of(4L), saved.getCategoryIds());
        assertEquals(Long.valueOf(73), saved.getViewCount());
        assertEquals(Instant.parse("2020-01-01T00:00:00Z"), saved.getCreatedAt().toInstant());
        assertEquals(NOW, saved.getUpdatedAt().toInstant());
        assertTrue(saved.isFeatured());
        assertEquals(1, existing.getCategories().size());
    }

    @Test public void staleEditAndHideCannotChangeMovie() {
        Movie existing = existingMovie();
        expect(ConflictException.class, () -> movies.updateMovie(99L, 8L, 4, AdminCatalogServiceTest.validMovie()));
        expect(ConflictException.class, () -> movies.hideMovie(99L, 8L, 4));
        assertEquals("Original", existing.getTitle());
        assertEquals("PUBLISHED", existing.getStatus());
        assertEquals(List.of(3L), movies.getMovie(8L).getCategoryIds());
    }

    @Test public void hideKeepsCategoriesViewsAndCreationAndCanRepeatCurrentVersion() {
        existingMovie();
        AdminMovieItem hidden = movies.hideMovie(99L, 8L, 5);
        assertEquals("HIDDEN", hidden.getStatus());
        assertEquals(List.of(3L), hidden.getCategoryIds());
        assertEquals(Long.valueOf(73), hidden.getViewCount());
        assertEquals(hidden.getUpdatedAt(), movies.hideMovie(99L, 8L, 5).getUpdatedAt());
    }

    @Test public void deletedOrMissingCategoryRejectsBeforeMovieOrLinksAreChanged() {
        Movie existing = existingMovie();
        dao.categories.get(4L).setDeletedAt(NOW);
        AdminMovieInput input = AdminCatalogServiceTest.validMovie();
        for (String id : new String[]{"4", "999"}) {
            input.setCategoryIds(new String[]{id});
            AdminValidationException ex = expect(AdminValidationException.class, () -> movies.updateMovie(99L, 8L, 5, input));
            assertTrue(ex.getErrors().containsKey("categoryIds"));
            assertEquals("Original", existing.getTitle());
            assertEquals(List.of(3L), movies.getMovie(8L).getCategoryIds());
        }
    }

    @Test public void duplicateMovieSlugIsFieldErrorAndDoesNotCreateRecord() {
        existingMovie();
        AdminMovieInput input = AdminCatalogServiceTest.validMovie();
        input.setSlug("original");
        AdminValidationException ex = expect(AdminValidationException.class, () -> movies.createMovie(99L, input));
        assertTrue(ex.getErrors().containsKey("slug"));
        assertEquals(1, dao.movies.size());
    }

    @Test public void deletedCanonicalNameRemainsReservedButDistinctAccentsAreAllowed() {
        Category old = category(6L, "Caf\u00e9", "old-cafe");
        old.setDeletedAt(NOW);
        dao.categories.put(6L, old);
        AdminCategoryInput input = new AdminCategoryInput();
        input.setName(" CAFE\u0301 "); input.setSlug("new-cafe");
        AdminValidationException ex = expect(AdminValidationException.class, () -> categories.saveCategory(99L, null, null, input));
        assertTrue(ex.getErrors().containsKey("name"));
        input.setName("Cafe");
        AdminCategoryItem saved = categories.saveCategory(99L, null, null, input);
        assertEquals("Cafe", saved.getName());
        assertEquals("cafe", dao.categories.get(saved.getId()).getNameKey());
    }

    @Test public void categoryEditKeepsIdentityCreationAndRejectsOtherSlugAndStaleVersion() {
        AdminCategoryInput input = new AdminCategoryInput();
        input.setName("Th\u1ec3 lo\u1ea1i m\u1edbi"); input.setSlug("tam-ly");
        AdminValidationException ex = expect(AdminValidationException.class, () -> categories.saveCategory(99L, 3L, 1, input));
        assertTrue(ex.getErrors().containsKey("slug"));
        input.setSlug("the-loai-moi");
        expect(ConflictException.class, () -> categories.saveCategory(99L, 3L, 2, input));
        AdminCategoryItem saved = categories.saveCategory(99L, 3L, 1, input);
        assertEquals(Long.valueOf(3), saved.getId());
        assertEquals(Instant.parse("2020-01-01T00:00:00Z"), saved.getCreatedAt().toInstant());
        assertEquals("Th\u1ec3 lo\u1ea1i m\u1edbi", saved.getName());
    }

    @Test public void categoryAssignedToHiddenMovieCannotBeDeleted() {
        existingMovie().setStatus("HIDDEN");
        expect(ConflictException.class, () -> categories.deleteCategory(99L, 3L, 1));
        assertNull(dao.categories.get(3L).getDeletedAt());
    }

    @Test public void unassignedCategoryIsSoftDeletedAndUnavailableForEditAndNewAssignment() {
        categories.deleteCategory(99L, 4L, 1);
        assertEquals(NOW, dao.categories.get(4L).getDeletedAt());
        expect(NotFoundException.class, () -> categories.getCategory(4L));
        AdminMovieInput input = AdminCatalogServiceTest.validMovie();
        input.setCategoryIds(new String[]{"4"});
        expect(AdminValidationException.class, () -> movies.createMovie(99L, input));
        assertTrue(dao.movies.isEmpty());
        assertEquals(1, categories.listActiveCategories().size());
    }

    @Test public void listsClampPastEndAndUseEmptyPageOneWithoutLinks() {
        dao.movieTotal = 23;
        AdminCatalogQuery query = movies.parseQuery("", null, "999");
        PageResult<AdminMovieItem> result = movies.listMovies(query);
        assertEquals(3, result.getPage()); assertEquals(3, result.getTotalPages());
        assertEquals(23, result.getTotal()); assertEquals(20, dao.movieOffset);
        assertTrue(result.isHasPrevious()); assertFalse(result.isHasNext());
        PageResult<AdminCategoryItem> empty = categories.listCategories(categories.parseQuery(null, "3"));
        assertEquals(1, empty.getPage()); assertEquals(0, empty.getTotalPages());
        assertFalse(empty.isHasPrevious()); assertFalse(empty.isHasNext());
    }

    @Test public void invalidListFilterNeverReachesPersistence() {
        expect(AdminValidationException.class, () -> movies.listMovies(movies.parseQuery(null, "DELETED", null)));
        expect(AdminValidationException.class, () -> categories.listCategories(categories.parseQuery("a".repeat(201), null)));
        assertEquals(0, dao.reads);
    }

    private Movie existingMovie() {
        Movie movie = new Movie(); movie.setId(8L); movie.setTitle("Original"); movie.setSlug("original");
        movie.setDescription("Original description"); movie.setReleaseYear(2020); movie.setDurationMinutes(90);
        movie.setStatus("PUBLISHED"); movie.setPosterUrl("https://example.org/original.jpg");
        movie.setVersion(5); movie.setViewCount(73L); movie.setCreatedAt(Instant.parse("2020-01-01T00:00:00Z"));
        movie.setUpdatedAt(Instant.parse("2020-01-01T00:00:00Z")); movie.getCategories().add(dao.categories.get(3L));
        dao.movies.put(8L, movie); return movie;
    }
    private static Category category(Long id, String name, String slug) {
        Category c = new Category(); c.setId(id); c.setName(name); c.setSlug(slug); c.setVersion(1);
        c.setCreatedAt(Instant.parse("2020-01-01T00:00:00Z")); return c;
    }
    private static <T extends Throwable> T expect(Class<T> type, Runnable work) {
        try { work.run(); fail("Expected " + type.getSimpleName()); }
        catch (Throwable ex) { if (type.isInstance(ex)) return type.cast(ex); throw ex; }
        throw new AssertionError();
    }

    private static class MemoryCatalog extends AdminCatalogDAO {
        final Map<Long, Movie> movies = new LinkedHashMap<>();
        final Map<Long, Category> categories = new LinkedHashMap<>();
        long movieTotal; int movieOffset; int reads;
        @Override public <T> T read(Function<EntityManager, T> work) { reads++; return work.apply(null); }
        @Override public <T> T write(Long actor, Function<EntityManager, T> work) { return work.apply(null); }
        @Override public Movie findMovie(EntityManager em, Long id) { return movies.get(id); }
        @Override public Movie findMovieForUpdate(EntityManager em, Long id) { return movies.get(id); }
        @Override public Category findCategory(EntityManager em, Long id) { return categories.get(id); }
        @Override public void persistMovie(EntityManager em, Movie movie) { movie.setId(100L); movies.put(100L, movie); }
        @Override public void persistCategory(EntityManager em, Category category) { category.setId(100L); categories.put(100L, category); }
        @Override public void flush(EntityManager em) { }
        @Override public boolean movieSlugExists(EntityManager em, String slug, Long excluded) {
            return movies.values().stream().anyMatch(m -> !Objects.equals(excluded, m.getId()) && slug.equals(m.getSlug()));
        }
        @Override public List<Category> findAllCategories(EntityManager em) { return new ArrayList<>(categories.values()); }
        @Override public List<Category> findAllActiveCategories(EntityManager em) { return categories.values().stream().filter(c -> c.getDeletedAt() == null).toList(); }
        @Override public boolean categoryHasMovies(EntityManager em, Long id) {
            return movies.values().stream().anyMatch(m -> m.getCategories().stream().anyMatch(c -> id.equals(c.getId())));
        }
        @Override public long countMovies(EntityManager em, String q, String status) { return movieTotal; }
        @Override public List<Movie> findMovies(EntityManager em, String q, String status, int offset) { movieOffset = offset; return List.of(); }
        @Override public long countCategories(EntityManager em, String q) { return 0; }
        @Override public List<Category> findCategories(EntityManager em, String q, int offset) { return List.of(); }
    }
}
