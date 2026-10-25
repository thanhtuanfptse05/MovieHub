package com.moviehub.service;

import com.moviehub.dao.CategoryDAO;
import com.moviehub.dao.MovieDAO;
import com.moviehub.dto.CatalogQuery;
import com.moviehub.dto.MovieCard;
import com.moviehub.dto.PageResult;
import com.moviehub.util.MediaUrlUtil;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit tests for the catalog use cases (003-movie-catalog): query validation, paging rules,
 * LIKE escaping, media URL safety and per-session view counting.
 */
public class MovieServiceTest {

    private StubMovieDAO movieDAO;
    private StubCategoryDAO categoryDAO;
    private MovieService service;

    @Before
    public void setUp() {
        movieDAO = new StubMovieDAO();
        categoryDAO = new StubCategoryDAO();
        categoryDAO.activeIds.add(3L);
        service = new MovieService(movieDAO, categoryDAO, Clock.fixed(Instant.parse("2026-10-25T10:00:00Z"), ZoneOffset.UTC));
    }

    // ---- query parsing ------------------------------------------------------------

    @Test
    public void parseQuery_Defaults() {
        CatalogQuery q = service.parseQuery(null, null, null, null, null);
        assertTrue(q.isValid());
        assertEquals("", q.getQ());
        assertNull(q.getCategoryId());
        assertNull(q.getYear());
        assertEquals("newest", q.getSort());
        assertEquals(1, q.getPage());
    }

    @Test
    public void parseQuery_TrimsAndNormalizesToNfc() {
        // "e" + combining acute accent must become the single precomposed character
        CatalogQuery q = service.parseQuery("  Cafe\u0301  ", null, null, null, null);
        assertEquals("Caf\u00e9", q.getQ());
    }

    @Test
    public void parseQuery_SingleCharacterIsValid() {
        assertTrue(service.parseQuery("a", null, null, null, null).isValid());
    }

    @Test
    public void parseQuery_Length200Valid_201Rejected() {
        assertTrue(service.parseQuery("a".repeat(200), null, null, null, null).isValid());
        CatalogQuery q = service.parseQuery("a".repeat(201), null, null, null, null);
        assertFalse(q.isValid());
        assertNotNull(q.getErrors().get("q"));
        assertEquals("a".repeat(201), q.getQ()); // never silently truncated
    }

    @Test
    public void parseQuery_LengthCountsCodePoints() {
        String emoji200 = "\uD83C\uDFAC".repeat(200); // 200 code points, 400 UTF-16 units
        assertTrue(service.parseQuery(emoji200, null, null, null, null).isValid());
    }

    @Test
    public void parseQuery_UnknownSortFallsBackToNewest() {
        assertEquals("newest", service.parseQuery(null, null, null, "title; drop table", null).getSort());
        assertEquals("rating", service.parseQuery(null, null, null, "rating", null).getSort());
    }

    @Test
    public void parseQuery_CategoryMustExistAndBeActive() {
        assertEquals(Long.valueOf(3), service.parseQuery(null, "3", null, null, null).getCategoryId());
        for (String bad : new String[]{"99", "abc", "-1", "0", "3.5", "99999999999999999999"}) {
            CatalogQuery q = service.parseQuery(null, bad, null, null, null);
            assertFalse("category " + bad, q.isValid());
            assertNotNull(q.getErrors().get("category"));
            assertNull(q.getCategoryId());
        }
    }

    @Test
    public void parseQuery_YearRange() {
        assertEquals(Integer.valueOf(1888), service.parseQuery(null, null, "1888", null, null).getYear());
        assertEquals(Integer.valueOf(2028), service.parseQuery(null, null, "2028", null, null).getYear()); // 2026 + 2
        for (String bad : new String[]{"1887", "2029", "abc", "20x5", "-2000", "20 25"}) {
            CatalogQuery q = service.parseQuery(null, null, bad, null, null);
            assertFalse("year " + bad, q.isValid());
            assertNotNull(q.getErrors().get("year"));
        }
    }

    @Test
    public void parseQuery_BlankFiltersMeanNoFilter() {
        CatalogQuery q = service.parseQuery("  ", "  ", "", "newest", "1");
        assertTrue(q.isValid());
        assertNull(q.getCategoryId());
        assertNull(q.getYear());
    }

    // ---- page normalisation (SYS-03) -----------------------------------------------

    @Test
    public void parsePage_InvalidValuesBecomeOne() {
        assertEquals(1, MovieService.parsePage(null));
        assertEquals(1, MovieService.parsePage("abc"));
        assertEquals(1, MovieService.parsePage("0"));
        assertEquals(1, MovieService.parsePage("-4"));
        assertEquals(1, MovieService.parsePage("99999999999999999999"));
        assertEquals(1, MovieService.parsePage("2.5"));
        assertEquals(7, MovieService.parsePage(" 7 "));
    }

    @Test
    public void paging_TwentyThreeMoviesGiveThreePages() {
        assertEquals(3, PageResult.totalPagesFor(23));
        assertEquals(0, PageResult.totalPagesFor(0));
        assertEquals(1, PageResult.totalPagesFor(10));
        assertEquals(2, PageResult.totalPagesFor(11));
    }

    @Test
    public void search_ClampsPageBeyondLastToLast() {
        movieDAO.total = 23;
        movieDAO.ids = List.of(21L, 22L, 23L);
        CatalogQuery q = service.parseQuery(null, null, null, null, "50");
        PageResult<MovieCard> result = service.search(q);
        assertEquals(3, result.getPage());
        assertEquals(3, result.getTotalPages());
        assertEquals(20, movieDAO.lastOffset);
        assertEquals(10, movieDAO.lastLimit);
        assertFalse(result.isHasNext());
        assertTrue(result.isHasPrevious());
    }

    @Test
    public void search_EmptyResultIsPageOneZeroPagesNoLinks() {
        movieDAO.total = 0;
        PageResult<MovieCard> result = service.search(service.parseQuery("zzz", null, null, null, "4"));
        assertEquals(1, result.getPage());
        assertEquals(0, result.getTotalPages());
        assertEquals(0, result.getTotal());
        assertFalse(result.isHasPrevious());
        assertFalse(result.isHasNext());
        assertFalse(movieDAO.findIdsCalled);
    }

    @Test(expected = IllegalArgumentException.class)
    public void search_RejectsInvalidQuery() {
        service.search(service.parseQuery("a".repeat(201), null, null, null, null));
    }

    @Test
    public void search_PassesEscapedLowercasePatternToDao() {
        movieDAO.total = 1;
        movieDAO.ids = List.of(1L);
        service.search(service.parseQuery("100%_[A]!", null, null, null, null));
        assertEquals("%100!%!_![a]!!%", movieDAO.lastPattern);
    }

    // ---- LIKE escaping ------------------------------------------------------------

    @Test
    public void likePattern_EscapesWildcardsAndEscapeCharacter() {
        assertEquals("%abc%", MovieDAO.toLikePattern("abc"));
        assertEquals("%a!%b%", MovieDAO.toLikePattern("a%b"));
        assertEquals("%a!_b%", MovieDAO.toLikePattern("a_b"));
        assertEquals("%a![b%", MovieDAO.toLikePattern("a[b"));
        assertEquals("%a!!b%", MovieDAO.toLikePattern("a!b"));
        assertEquals("%o'brien\\%", MovieDAO.toLikePattern("o'brien\\"));
    }

    // ---- media URL safety --------------------------------------------------------------

    @Test
    public void mediaUrls_OnlyHttpMp4Accepted() {
        assertEquals("https://x.test/a/b.mp4", MediaUrlUtil.safeMp4Url(" https://x.test/a/b.mp4 "));
        assertEquals("https://x.test/a/b.MP4?token=1", MediaUrlUtil.safeMp4Url("https://x.test/a/b.MP4?token=1"));
        assertNull(MediaUrlUtil.safeMp4Url("https://x.test/a/b.webm"));
        assertNull(MediaUrlUtil.safeMp4Url("https://www.youtube.com/watch?v=abc"));
        assertNull(MediaUrlUtil.safeMp4Url("javascript:alert(1)//.mp4"));
        assertNull(MediaUrlUtil.safeMp4Url("ftp://x.test/a.mp4"));
        assertNull(MediaUrlUtil.safeMp4Url("https://user:pw@x.test/a.mp4"));
        assertNull(MediaUrlUtil.safeMp4Url(""));
        assertNull(MediaUrlUtil.safeMp4Url(null));
    }

    @Test
    public void imageUrls_RejectNonHttp() {
        assertEquals("https://img.test/p.jpg", MediaUrlUtil.safeImageUrl("https://img.test/p.jpg"));
        assertNull(MediaUrlUtil.safeImageUrl("data:image/png;base64,AAAA"));
        assertNull(MediaUrlUtil.safeImageUrl("javascript:alert(1)"));
        assertNull(MediaUrlUtil.safeImageUrl(null));
    }

    // ---- rating presentation ----------------------------------------------------------

    @Test
    public void card_NoReviewsHasNullRatingNotZero() {
        MovieCard card = new MovieCard(1L, "t", 2020, null, 0L, 0.0, 0);
        assertNull(card.getAverageRating());
        assertFalse(card.isRated());
        assertEquals("", card.getRatingText());
    }

    @Test
    public void card_RatingRoundsHalfUpToOneDecimal() {
        assertEquals("4.3", new MovieCard(1L, "t", 2020, null, 0L, 4.25, 4).getRatingText());
        assertEquals("3.7", new MovieCard(1L, "t", 2020, null, 0L, 3.6666666, 3).getRatingText());
    }

    // ---- view counting (SYS-07) ---------------------------------------------------------

    @Test
    public void viewDue_BoundaryIsThirtyMinutes() {
        Instant first = Instant.parse("2026-10-25T10:00:00Z");
        assertTrue(MovieService.isViewDue(null, first));
        assertFalse(MovieService.isViewDue(first, first.plusSeconds(29 * 60 + 59)));
        assertTrue(MovieService.isViewDue(first, first.plusSeconds(30 * 60)));
    }

    @Test
    public void recordView_CountsOncePerWindowAndStoresTimestampAfterSuccess() {
        Map<Long, Instant> views = new HashMap<>();
        assertTrue(service.recordViewIfDue(5L, views));
        assertFalse(service.recordViewIfDue(5L, views));
        assertEquals(1, movieDAO.increments);
        assertTrue(views.containsKey(5L));
    }

    @Test
    public void recordView_FailedWriteLeavesNoTimestampSoNextRequestRetries() {
        Map<Long, Instant> views = new HashMap<>();
        movieDAO.failIncrement = true;
        try {
            service.recordViewIfDue(5L, views);
            fail("expected failure");
        } catch (IllegalStateException expected) {
            // swallowed by the servlet; detail still renders
        }
        assertFalse(views.containsKey(5L));
        movieDAO.failIncrement = false;
        assertTrue(service.recordViewIfDue(5L, views));
    }

    @Test
    public void recordView_NonPublicMovieNotCounted() {
        Map<Long, Instant> views = new HashMap<>();
        movieDAO.incrementResult = false;
        assertFalse(service.recordViewIfDue(9L, views));
        assertTrue(views.isEmpty());
    }

    @Test
    public void recordView_ConcurrentRequestsOfOneSessionIncrementOnce() throws Exception {
        final Map<Long, Instant> views = new HashMap<>();
        movieDAO.incrementDelayMs = 50;
        Thread[] threads = new Thread[8];
        for (int i = 0; i < threads.length; i++) {
            threads[i] = new Thread(() -> service.recordViewIfDue(7L, views));
            threads[i].start();
        }
        for (Thread t : threads) {
            t.join();
        }
        assertEquals(1, movieDAO.increments);
    }

    @Test
    public void recordView_DifferentSessionsCountSeparately() {
        assertTrue(service.recordViewIfDue(5L, new HashMap<Long, Instant>()));
        assertTrue(service.recordViewIfDue(5L, new HashMap<Long, Instant>()));
        assertEquals(2, movieDAO.increments);
    }

    // ---- stubs ------------------------------------------------------------------------------

    static class StubMovieDAO extends MovieDAO {
        long total;
        List<Long> ids = new ArrayList<>();
        int lastOffset = -1;
        int lastLimit = -1;
        String lastPattern;
        boolean findIdsCalled;
        int increments;
        boolean failIncrement;
        boolean incrementResult = true;
        long incrementDelayMs;

        @Override
        public long countFiltered(String likePattern, Long categoryId, Integer year) {
            lastPattern = likePattern;
            return total;
        }

        @Override
        public List<Long> findFilteredIds(String likePattern, Long categoryId, Integer year,
                                          String sort, int offset, int limit) {
            findIdsCalled = true;
            lastOffset = offset;
            lastLimit = limit;
            return ids;
        }

        @Override
        public List<MovieCard> findCardsByIds(List<Long> wanted) {
            List<MovieCard> cards = new ArrayList<>();
            for (Long id : wanted) {
                cards.add(new MovieCard(id, "Phim " + id, 2020, null, 0L, null, 0));
            }
            return cards;
        }

        @Override
        public synchronized boolean incrementViewCount(Long movieId) {
            if (failIncrement) {
                throw new IllegalStateException("db down");
            }
            if (incrementDelayMs > 0) {
                try {
                    Thread.sleep(incrementDelayMs);
                } catch (InterruptedException ignored) {
                    Thread.currentThread().interrupt();
                }
            }
            if (incrementResult) {
                increments++;
            }
            return incrementResult;
        }
    }

    static class StubCategoryDAO extends CategoryDAO {
        final java.util.Set<Long> activeIds = new java.util.HashSet<>();

        @Override
        public boolean existsActive(Long id) {
            return activeIds.contains(id);
        }
    }
}
