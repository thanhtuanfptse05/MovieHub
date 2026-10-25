package com.moviehub.service;

import com.moviehub.dao.FavoriteDAO;
import com.moviehub.dao.MovieDAO;
import com.moviehub.dto.FavoritePage;
import com.moviehub.dto.MovieCard;
import com.moviehub.entity.Favorite;
import com.moviehub.entity.Movie;
import com.moviehub.entity.User;
import com.moviehub.exception.NotFoundException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit tests for 004-favorites module (FavoriteService).
 * Covers FAV-AC-01 through FAV-AC-09, edge cases, soft-delete, and pagination.
 */
public class FavoriteServiceTest {

    private StubFavoriteDAO favoriteDAO;
    private StubMovieDAO movieDAO;
    private FavoriteService service;

    @Before
    public void setUp() {
        favoriteDAO = new StubFavoriteDAO();
        movieDAO = new StubMovieDAO();
        service = new FavoriteService(favoriteDAO, movieDAO);

        // Seed some test movies
        Movie m1 = createMovie(1L, "Inception", Movie.STATUS_PUBLISHED);
        Movie m2 = createMovie(2L, "Interstellar", Movie.STATUS_PUBLISHED);
        Movie m3 = createMovie(3L, "The Dark Knight", Movie.STATUS_HIDDEN);
        Movie m4 = createMovie(4L, "Tenet", Movie.STATUS_DRAFT);

        movieDAO.saveMovie(m1);
        movieDAO.saveMovie(m2);
        movieDAO.saveMovie(m3);
        movieDAO.saveMovie(m4);
    }

    private Movie createMovie(Long id, String title, String status) {
        Movie m = new Movie();
        m.setId(id);
        m.setTitle(title);
        m.setStatus(status);
        m.setReleaseYear(2020);
        m.setViewCount(100L);
        return m;
    }

    // ---- addFavorite tests --------------------------------------------------------

    @Test
    public void addFavorite_Success_PublishedMovie() {
        service.addFavorite(10L, 1L);
        assertTrue(service.isFavorited(10L, 1L));
    }

    @Test
    public void addFavorite_Idempotent_AlreadyActive() {
        service.addFavorite(10L, 1L);
        service.addFavorite(10L, 1L); // Second add should be a no-op
        assertTrue(service.isFavorited(10L, 1L));
        assertEquals(1, favoriteDAO.countActiveByUser(10L));
    }

    @Test
    public void addFavorite_RestoresSoftDeleted() {
        service.addFavorite(10L, 1L);
        service.removeFavorite(10L, 1L);
        assertFalse(service.isFavorited(10L, 1L));

        // Re-adding restores the row
        service.addFavorite(10L, 1L);
        assertTrue(service.isFavorited(10L, 1L));
        assertEquals(1, favoriteDAO.countActiveByUser(10L));
    }

    @Test(expected = NotFoundException.class)
    public void addFavorite_ThrowsNotFound_NonExistentMovie() {
        service.addFavorite(10L, 999L);
    }

    @Test(expected = NotFoundException.class)
    public void addFavorite_ThrowsNotFound_HiddenMovie() {
        service.addFavorite(10L, 3L);
    }

    @Test(expected = NotFoundException.class)
    public void addFavorite_ThrowsNotFound_DraftMovie() {
        service.addFavorite(10L, 4L);
    }

    @Test(expected = IllegalArgumentException.class)
    public void addFavorite_ThrowsIllegalArgument_NullUserId() {
        service.addFavorite(null, 1L);
    }

    @Test(expected = IllegalArgumentException.class)
    public void addFavorite_ThrowsIllegalArgument_NullMovieId() {
        service.addFavorite(10L, null);
    }

    // ---- removeFavorite tests -----------------------------------------------------

    @Test
    public void removeFavorite_Success_ActiveFavorite() {
        service.addFavorite(10L, 1L);
        assertTrue(service.isFavorited(10L, 1L));

        service.removeFavorite(10L, 1L);
        assertFalse(service.isFavorited(10L, 1L));
    }

    @Test
    public void removeFavorite_Idempotent_AlreadyRemoved() {
        service.addFavorite(10L, 1L);
        service.removeFavorite(10L, 1L);
        service.removeFavorite(10L, 1L); // No-op, should not throw
        assertFalse(service.isFavorited(10L, 1L));
    }

    @Test
    public void removeFavorite_Idempotent_NeverFavorited() {
        service.removeFavorite(10L, 1L); // No-op
        assertFalse(service.isFavorited(10L, 1L));
    }

    @Test
    public void removeFavorite_Succeeds_ForHiddenMovie() {
        // User is allowed to remove a movie even if it recently became HIDDEN
        service.removeFavorite(10L, 3L);
        assertFalse(service.isFavorited(10L, 3L));
    }

    @Test(expected = NotFoundException.class)
    public void removeFavorite_ThrowsNotFound_NonExistentMovie() {
        service.removeFavorite(10L, 999L);
    }

    @Test(expected = IllegalArgumentException.class)
    public void removeFavorite_ThrowsIllegalArgument_NullUserId() {
        service.removeFavorite(null, 1L);
    }

    @Test(expected = IllegalArgumentException.class)
    public void removeFavorite_ThrowsIllegalArgument_NullMovieId() {
        service.removeFavorite(10L, null);
    }

    // ---- isFavorited tests --------------------------------------------------------

    @Test
    public void isFavorited_NullSafe() {
        assertFalse(service.isFavorited(null, 1L));
        assertFalse(service.isFavorited(10L, null));
    }

    // ---- getFavorites / pagination tests ------------------------------------------

    @Test
    public void getFavorites_EmptyState() {
        FavoritePage page = service.getFavorites(10L, 1);
        assertNotNull(page);
        assertTrue(page.getItems().isEmpty());
        assertEquals(0, page.getTotalCount());
        assertEquals(0, page.getTotalPages());
        assertEquals(1, page.getPage());
        assertFalse(page.isHasItems());
        assertFalse(page.isHasPrevious());
        assertFalse(page.isHasNext());
    }

    @Test
    public void getFavorites_OnlyReturnsPublishedMovies() {
        service.addFavorite(10L, 1L);
        service.addFavorite(10L, 2L);

        FavoritePage page = service.getFavorites(10L, 1);
        assertEquals(2, page.getTotalCount());
        assertEquals(1, page.getTotalPages());
        assertEquals(2, page.getItems().size());
    }

    @Test
    public void getFavorites_Pagination_Page1AndPage2() {
        // Create 15 published movies and favorite them for user 10
        for (long i = 100L; i < 115L; i++) {
            Movie m = createMovie(i, "Movie " + i, Movie.STATUS_PUBLISHED);
            movieDAO.saveMovie(m);
            service.addFavorite(10L, i);
        }

        FavoritePage page1 = service.getFavorites(10L, 1);
        assertEquals(15, page1.getTotalCount());
        assertEquals(2, page1.getTotalPages());
        assertEquals(1, page1.getPage());
        assertEquals(10, page1.getItems().size());
        assertFalse(page1.isHasPrevious());
        assertTrue(page1.isHasNext());

        FavoritePage page2 = service.getFavorites(10L, 2);
        assertEquals(15, page2.getTotalCount());
        assertEquals(2, page2.getTotalPages());
        assertEquals(2, page2.getPage());
        assertEquals(5, page2.getItems().size());
        assertTrue(page2.isHasPrevious());
        assertFalse(page2.isHasNext());
    }

    @Test
    public void getFavorites_NormalizesNegativeOrZeroPage() {
        service.addFavorite(10L, 1L);
        FavoritePage page = service.getFavorites(10L, 0);
        assertEquals(1, page.getPage());

        FavoritePage pageNeg = service.getFavorites(10L, -5);
        assertEquals(1, pageNeg.getPage());
    }

    @Test
    public void getFavorites_NormalizesPageExceedingTotal() {
        service.addFavorite(10L, 1L);
        FavoritePage page = service.getFavorites(10L, 99);
        assertEquals(1, page.getPage());
    }

    @Test
    public void getFavorites_IsolatesUsers() {
        service.addFavorite(10L, 1L);
        service.addFavorite(20L, 2L);

        FavoritePage pageUser10 = service.getFavorites(10L, 1);
        assertEquals(1, pageUser10.getTotalCount());
        assertEquals("Inception", pageUser10.getItems().get(0).getTitle());

        FavoritePage pageUser20 = service.getFavorites(20L, 1);
        assertEquals(1, pageUser20.getTotalCount());
        assertEquals("Interstellar", pageUser20.getItems().get(0).getTitle());
    }

    // ---- Stubs --------------------------------------------------------------------

    static class StubFavoriteDAO extends FavoriteDAO {
        private final Map<String, Favorite> store = new HashMap<>();

        private String key(Long userId, Long movieId) {
            return userId + ":" + movieId;
        }

        @Override
        public boolean isFavorited(Long userId, Long movieId) {
            if (userId == null || movieId == null) return false;
            Favorite fav = store.get(key(userId, movieId));
            return fav != null && fav.getDeletedAt() == null;
        }

        @Override
        public Optional<Favorite> findByUserAndMovie(Long userId, Long movieId) {
            if (userId == null || movieId == null) return Optional.empty();
            Favorite fav = store.get(key(userId, movieId));
            return Optional.ofNullable(fav);
        }

        @Override
        public void addOrRestore(Long userId, Long movieId) {
            Favorite fav = store.get(key(userId, movieId));
            if (fav != null) {
                if (fav.getDeletedAt() != null) {
                    fav.setDeletedAt(null);
                    fav.setCreatedAt(Instant.now());
                }
            } else {
                User u = new User();
                u.setId(userId);
                Movie m = new Movie();
                m.setId(movieId);
                fav = new Favorite(u, m);
                fav.setId((long) (store.size() + 1));
                store.put(key(userId, movieId), fav);
            }
        }

        @Override
        public boolean softRemove(Long userId, Long movieId) {
            Favorite fav = store.get(key(userId, movieId));
            if (fav != null && fav.getDeletedAt() == null) {
                fav.setDeletedAt(Instant.now());
                return true;
            }
            return false;
        }

        @Override
        public List<Long> findActiveMovieIdsByUser(Long userId, int offset, int limit) {
            List<Long> result = new ArrayList<>();
            for (Favorite fav : store.values()) {
                if (fav.getUser().getId().equals(userId) && fav.getDeletedAt() == null) {
                    result.add(fav.getMovie().getId());
                }
            }
            int toIndex = Math.min(offset + limit, result.size());
            if (offset >= result.size()) {
                return new ArrayList<>();
            }
            return result.subList(offset, toIndex);
        }

        @Override
        public long countActiveByUser(Long userId) {
            long count = 0;
            for (Favorite fav : store.values()) {
                if (fav.getUser().getId().equals(userId) && fav.getDeletedAt() == null) {
                    count++;
                }
            }
            return count;
        }
    }

    static class StubMovieDAO extends MovieDAO {
        private final Map<Long, Movie> movies = new HashMap<>();

        public void saveMovie(Movie m) {
            movies.put(m.getId(), m);
        }

        @Override
        public Movie findById(Long id) {
            if (id == null) return null;
            return movies.get(id);
        }

        @Override
        public Movie findPublishedById(Long id) {
            Movie m = findById(id);
            if (m != null && Movie.STATUS_PUBLISHED.equals(m.getStatus())) {
                return m;
            }
            return null;
        }

        @Override
        public List<MovieCard> findCardsByIds(List<Long> ids) {
            List<MovieCard> cards = new ArrayList<>();
            if (ids == null) return cards;
            for (Long id : ids) {
                Movie m = findById(id);
                if (m != null && Movie.STATUS_PUBLISHED.equals(m.getStatus())) {
                    cards.add(new MovieCard(m.getId(), m.getTitle(), m.getReleaseYear(),
                            m.getPosterUrl(), m.getViewCount(), 4.5, 10));
                }
            }
            return cards;
        }
    }
}
