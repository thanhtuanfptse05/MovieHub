package com.moviehub.service;

import com.moviehub.dao.AdminCatalogDAO;
import com.moviehub.dto.AdminCategoryInput;
import com.moviehub.dto.AdminCatalogQuery;
import com.moviehub.dto.AdminMovieInput;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/** Catalog validation contracts, without a running database. */
public class AdminCatalogServiceTest {
    private AdminMovieService movies;
    private AdminCategoryService categories;

    @Before public void setUp() {
        Clock clock = Clock.fixed(Instant.parse("2026-10-26T00:00:00Z"), ZoneOffset.UTC);
        movies = new AdminMovieService(new AdminCatalogDAO(), clock);
        categories = new AdminCategoryService(new AdminCatalogDAO(), clock);
    }

    @Test public void draftRequiresCoreTextAndValidNumbers() {
        AdminMovieInput input = new AdminMovieInput();
        Map<String, String> errors = movies.validate(input);
        assertTrue(errors.containsKey("title"));
        assertTrue(errors.containsKey("slug"));
        assertTrue(errors.containsKey("description"));
        assertTrue(errors.containsKey("releaseYear"));
        assertTrue(errors.containsKey("durationMinutes"));
    }

    @Test public void draftCanOmitPosterVideoAndCategories() {
        assertTrue(movies.validate(validMovie()).isEmpty());
    }

    @Test public void publishedNeedsPosterAndCategory() {
        AdminMovieInput input = validMovie();
        input.setStatus("PUBLISHED");
        assertTrue(movies.validate(input).containsKey("posterUrl"));
        assertTrue(movies.validate(input).containsKey("categoryIds"));
        input.setPosterUrl("https://example.org/poster.jpg");
        input.setCategoryIds(new String[]{"3", "3"});
        assertTrue(movies.validate(input).isEmpty());
    }

    @Test public void yearsAndDurationAreBoundedIntegers() {
        AdminMovieInput input = validMovie();
        for (String year : new String[]{"1887", "2029", "2026.0", "+2026", "999999999999999"}) {
            input.setReleaseYear(year);
            assertTrue(year, movies.validate(input).containsKey("releaseYear"));
        }
        input.setReleaseYear("2028");
        for (String duration : new String[]{"0", "601", "1.5", "-1"}) {
            input.setDurationMinutes(duration);
            assertTrue(duration, movies.validate(input).containsKey("durationMinutes"));
        }
        input.setDurationMinutes("600");
        assertTrue(movies.validate(input).isEmpty());
    }

    @Test public void slugsEnumsAndCategoryIdentifiersRejectMalformedInputs() {
        AdminMovieInput input = validMovie();
        for (String slug : new String[]{"UPPER", "two--words", "with space", "cafe\u0301", "a".repeat(251)}) {
            input.setSlug(slug);
            assertTrue(slug, movies.validate(input).containsKey("slug"));
        }
        input.setSlug("valid-slug");
        input.setStatus("DELETED");
        assertTrue(movies.validate(input).containsKey("status"));
        input.setStatus("DRAFT");
        for (String id : new String[]{"0", "-3", "abc", "9223372036854775808", ""}) {
            input.setCategoryIds(new String[]{id});
            assertTrue(id, movies.validate(input).containsKey("categoryIds"));
        }
    }

    @Test public void mediaRejectsUnsafeUrlsAndAllowsLocalDevelopmentMp4() {
        AdminMovieInput input = validMovie();
        for (String url : new String[]{"http://example.org/p.jpg", "javascript:alert(1)", "//example.org/p.jpg", "https://name@example.org/p.jpg", "https://example.org/a\n.jpg", "http://localhost.evil/p.jpg", "https://example.org/" + "a".repeat(1000)}) {
            input.setPosterUrl(url);
            assertTrue(url, movies.validate(input).containsKey("posterUrl"));
        }
        input.setPosterUrl("http://localhost:8080/poster.jpg");
        input.setVideoUrl("http://127.0.0.1:8080/movie.MP4?token=one");
        input.setTrailerUrl("https://example.org/trailer.mp4?q=1");
        assertTrue(movies.validate(input).isEmpty());
        input.setVideoUrl("https://youtube.com/watch?v=one");
        assertTrue(movies.validate(input).containsKey("videoUrl"));
    }

    @Test public void normalizedUnicodeTextUsesCodePointLimits() {
        AdminMovieInput input = validMovie();
        input.setTitle("\uD83C\uDFAC".repeat(100));
        input.setDescription("a".repeat(10000));
        assertTrue(movies.validate(input).isEmpty());
        input.setTitle("a".repeat(201));
        input.setDescription("a".repeat(10001));
        assertTrue(movies.validate(input).containsKey("title"));
        assertTrue(movies.validate(input).containsKey("description"));
        input.setTitle("\uD83C\uDFAC".repeat(101));
        assertTrue("NVARCHAR(200) also limits UTF-16 units", movies.validate(input).containsKey("title"));
        input.setTitle("\u2003\u2003");
        assertTrue(movies.validate(input).containsKey("title"));
        input.setTitle("\u00a0\u00a0");
        assertTrue("Nonbreaking spaces alone are not a title", movies.validate(input).containsKey("title"));
    }

    @Test public void categoryRequiresNameAndLowercaseSlug() {
        AdminCategoryInput input = new AdminCategoryInput();
        assertTrue(categories.validate(input).containsKey("name"));
        assertTrue(categories.validate(input).containsKey("slug"));
        input.setName("  Cafe\u0301  ");
        input.setSlug("cafe");
        assertTrue(categories.validate(input).isEmpty());
        input.setName("a".repeat(101));
        input.setSlug("a".repeat(121));
        assertEquals(2, categories.validate(input).size());
    }

    @Test public void queriesNormalizeValidateAndDefaultMalformedPages() {
        AdminCatalogQuery query = movies.parseQuery("  Cafe\u0301  ", "PUBLISHED", "-9");
        assertEquals("Caf\u00e9", query.getQ());
        assertEquals("PUBLISHED", query.getStatus());
        assertEquals(1, query.getPage());
        assertTrue(query.isValid());
        assertFalse(movies.parseQuery("a".repeat(201), "DELETED", "1").isValid());
        assertEquals(1, movies.parseQuery(null, null, "999999999999999999999").getPage());
        assertEquals(12, categories.parseQuery(null, "12").getPage());
        assertFalse(categories.parseQuery("\uD83C\uDFAC".repeat(201), null).isValid());
    }

    static AdminMovieInput validMovie() {
        AdminMovieInput input = new AdminMovieInput();
        input.setTitle("Phim th\u1eed");
        input.setSlug("phim-thu");
        input.setDescription("M\u00f4 t\u1ea3 phim");
        input.setReleaseYear("2026");
        input.setDurationMinutes("100");
        return input;
    }
}
