package com.moviehub.service;

import com.moviehub.dao.CategoryDAO;
import com.moviehub.dao.MovieDAO;
import com.moviehub.dto.CatalogQuery;
import com.moviehub.dto.CategoryOption;
import com.moviehub.dto.HomeData;
import com.moviehub.dto.MovieCard;
import com.moviehub.dto.MovieDetail;
import com.moviehub.dto.PageResult;
import com.moviehub.entity.Movie;
import com.moviehub.util.MediaUrlUtil;
import java.text.Normalizer;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/**
 * Public catalog use cases: Home groups, search/filter/sort/paging, detail, similar movies, view counting.
 */
public class MovieService {

    public static final int MAX_QUERY_CODE_POINTS = 200;
    public static final int MIN_YEAR = 1888;
    public static final int HOME_GROUP_SIZE = 10;
    public static final int SIMILAR_LIMIT = 6;
    public static final Duration VIEW_WINDOW = Duration.ofMinutes(30);
    public static final ZoneId APP_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private static final Set<String> SORTS = Set.of(
            CatalogQuery.SORT_NEWEST, CatalogQuery.SORT_VIEWS, CatalogQuery.SORT_RATING, CatalogQuery.SORT_TITLE);

    private final MovieDAO movieDAO;
    private final CategoryDAO categoryDAO;
    private final Clock clock;

    public MovieService() {
        this(new MovieDAO(), new CategoryDAO(), Clock.systemUTC());
    }

    public MovieService(MovieDAO movieDAO, CategoryDAO categoryDAO, Clock clock) {
        this.movieDAO = movieDAO;
        this.categoryDAO = categoryDAO;
        this.clock = clock;
    }

    // ---------------------------------------------------------------- query parsing

    /** Validates raw request parameters; invalid q/category/year are reported, never silently dropped. */
    public CatalogQuery parseQuery(String q, String category, String year, String sort, String page) {
        CatalogQuery query = new CatalogQuery();

        String normalized = q == null ? "" : Normalizer.normalize(q.trim(), Normalizer.Form.NFC).trim();
        query.setQ(normalized);
        if (normalized.codePointCount(0, normalized.length()) > MAX_QUERY_CODE_POINTS) {
            query.addError("q", "Từ khóa tối đa " + MAX_QUERY_CODE_POINTS + " ký tự.");
        }

        String rawCategory = category == null ? "" : category.trim();
        query.setRawCategory(rawCategory);
        if (!rawCategory.isEmpty()) {
            Long categoryId = parsePositiveLong(rawCategory);
            if (categoryId == null || !categoryDAO.existsActive(categoryId)) {
                query.addError("category", "Thể loại không hợp lệ.");
            } else {
                query.setCategoryId(categoryId);
            }
        }

        String rawYear = year == null ? "" : year.trim();
        query.setRawYear(rawYear);
        if (!rawYear.isEmpty()) {
            Integer parsedYear = parseYear(rawYear);
            if (parsedYear == null) {
                query.addError("year", "Năm phát hành phải từ " + MIN_YEAR + " đến " + (currentYear() + 2) + ".");
            } else {
                query.setYear(parsedYear);
            }
        }

        query.setSort(sort != null && SORTS.contains(sort) ? sort : CatalogQuery.SORT_NEWEST);
        query.setPage(parsePage(page));
        return query;
    }

    int currentYear() {
        return LocalDate.now(clock.withZone(APP_ZONE)).getYear();
    }

    private Integer parseYear(String raw) {
        if (!raw.matches("[0-9]{1,5}")) {
            return null;
        }
        int value = Integer.parseInt(raw);
        return (value >= MIN_YEAR && value <= currentYear() + 2) ? value : null;
    }

    private static Long parsePositiveLong(String raw) {
        if (!raw.matches("[0-9]{1,18}")) {
            return null;
        }
        long value = Long.parseLong(raw);
        return value > 0 ? value : null;
    }

    /** SYS-03: missing, non-integer, below 1 or overflowing page numbers become 1. */
    public static int parsePage(String raw) {
        if (raw == null) {
            return 1;
        }
        String trimmed = raw.trim();
        if (!trimmed.matches("[0-9]{1,9}")) {
            return 1;
        }
        int value = Integer.parseInt(trimmed);
        return value < 1 ? 1 : value;
    }

    // ---------------------------------------------------------------- list

    /** Runs a validated query. Page is clamped to the last page; the resolved page is returned. */
    public PageResult<MovieCard> search(CatalogQuery query) {
        if (!query.isValid()) {
            throw new IllegalArgumentException("Invalid catalog query");
        }
        String pattern = query.getQ().isEmpty()
                ? null : MovieDAO.toLikePattern(query.getQ().toLowerCase(Locale.ROOT));

        long total = movieDAO.countFiltered(pattern, query.getCategoryId(), query.getYear());
        int totalPages = PageResult.totalPagesFor(total);
        int page = PageResult.clampPage(query.getPage(), totalPages);
        if (total == 0) {
            return new PageResult<>(new ArrayList<MovieCard>(), 0, 1, 0);
        }
        List<Long> ids = movieDAO.findFilteredIds(pattern, query.getCategoryId(), query.getYear(),
                query.getSort(), (page - 1) * PageResult.PAGE_SIZE, PageResult.PAGE_SIZE);
        return new PageResult<>(cards(ids), total, page, totalPages);
    }

    public List<CategoryOption> listCategories() {
        return categoryDAO.findAllActive();
    }

    public List<Integer> listYears() {
        return movieDAO.findPublicYears();
    }

    // ---------------------------------------------------------------- home

    public HomeData getHome() {
        List<MovieCard> featured = cards(movieDAO.findFeaturedIds(1));
        return new HomeData(
                featured.isEmpty() ? null : featured.get(0),
                cards(movieDAO.findNewestIds(HOME_GROUP_SIZE)),
                cards(movieDAO.findMostViewedIds(HOME_GROUP_SIZE)),
                cards(movieDAO.findTopRatedIds(HOME_GROUP_SIZE)));
    }

    // ---------------------------------------------------------------- detail

    /** Public detail, or null when the id is not a PUBLISHED movie. */
    public MovieDetail getPublicDetail(Long id) {
        Movie movie = movieDAO.findPublishedById(id);
        if (movie == null) {
            return null;
        }
        Object[] rating = movieDAO.findRatingSummary(id);
        return new MovieDetail(movie.getId(), movie.getTitle(), movie.getDescription(), movie.getReleaseYear(),
                movie.getDurationMinutes(), MediaUrlUtil.safeImageUrl(movie.getPosterUrl()),
                MediaUrlUtil.safeMp4Url(movie.getVideoUrl()), MediaUrlUtil.safeMp4Url(movie.getTrailerUrl()),
                movie.getViewCount(), (Double) rating[0], (Long) rating[1],
                movieDAO.findActiveCategories(id));
    }

    public List<MovieCard> getSimilar(Long id) {
        return cards(movieDAO.findSimilarIds(id, SIMILAR_LIMIT));
    }

    // ---------------------------------------------------------------- views (SYS-07)

    /** True when no view was counted yet or the last counted view is at least 30 minutes old. */
    public static boolean isViewDue(Instant lastCounted, Instant now) {
        return lastCounted == null || !now.isBefore(lastCounted.plus(VIEW_WINDOW));
    }

    /**
     * Counts one view for the session's view map when due. The map is the per-session record of the last
     * successful count; concurrent requests of one session serialize on it so only one increments.
     * A failed write leaves the map untouched so the next request retries.
     *
     * @return true when the view counter was incremented
     */
    public boolean recordViewIfDue(Long movieId, Map<Long, Instant> sessionViews) {
        synchronized (sessionViews) {
            Instant now = clock.instant();
            if (!isViewDue(sessionViews.get(movieId), now)) {
                return false;
            }
            if (movieDAO.incrementViewCount(movieId)) {
                sessionViews.put(movieId, now);
                return true;
            }
            return false;
        }
    }

    // ---------------------------------------------------------------- helpers

    private List<MovieCard> cards(List<Long> ids) {
        List<MovieCard> raw = movieDAO.findCardsByIds(ids);
        List<MovieCard> safe = new ArrayList<>(raw.size());
        for (MovieCard c : raw) {
            safe.add(new MovieCard(c.getId(), c.getTitle(), c.getReleaseYear(),
                    MediaUrlUtil.safeImageUrl(c.getPosterUrl()), c.getViewCount(),
                    c.getAverageRating(), c.getReviewCount()));
        }
        return safe;
    }
}
