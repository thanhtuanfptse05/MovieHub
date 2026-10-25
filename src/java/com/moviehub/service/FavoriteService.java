package com.moviehub.service;

import com.moviehub.dao.FavoriteDAO;
import com.moviehub.dao.MovieDAO;
import com.moviehub.dto.FavoritePage;
import com.moviehub.dto.MovieCard;
import com.moviehub.entity.Movie;
import com.moviehub.exception.NotFoundException;
import java.util.Collections;
import java.util.List;

/**
 * Service encapsulating business rules for user favorites (004-favorites).
 * Enforces EARS acceptance criteria FAV-AC-01 through FAV-AC-09.
 */
public class FavoriteService {

    public static final int PAGE_SIZE = 10;

    private final FavoriteDAO favoriteDAO;
    private final MovieDAO movieDAO;

    public FavoriteService() {
        this(new FavoriteDAO(), new MovieDAO());
    }

    public FavoriteService(FavoriteDAO favoriteDAO, MovieDAO movieDAO) {
        this.favoriteDAO = favoriteDAO;
        this.movieDAO = movieDAO;
    }

    /**
     * Checks whether the movie is currently in the user's active favorites list.
     */
    public boolean isFavorited(Long userId, Long movieId) {
        if (userId == null || movieId == null) {
            return false;
        }
        return favoriteDAO.isFavorited(userId, movieId);
    }

    /**
     * Adds movie to user's favorites, or restores if previously removed (FAV-AC-03).
     *
     * @throws IllegalArgumentException if userId or movieId is null
     * @throws NotFoundException if movie does not exist, is soft-deleted, or is not PUBLISHED (FAV-AC-04)
     */
    public void addFavorite(Long userId, Long movieId) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID không được để trống");
        }
        if (movieId == null) {
            throw new IllegalArgumentException("Movie ID không được để trống");
        }

        Movie movie = movieDAO.findById(movieId);
        if (movie == null || !Movie.STATUS_PUBLISHED.equals(movie.getStatus())) {
            throw new NotFoundException("Phim không tồn tại hoặc không ở trạng thái công khai");
        }

        favoriteDAO.addOrRestore(userId, movieId);
    }

    /**
     * Soft-removes movie from user's favorites (FAV-AC-05).
     *
     * @throws IllegalArgumentException if userId or movieId is null
     * @throws NotFoundException if movie does not exist in the database
     */
    public void removeFavorite(Long userId, Long movieId) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID không được để trống");
        }
        if (movieId == null) {
            throw new IllegalArgumentException("Movie ID không được để trống");
        }

        Movie movie = movieDAO.findById(movieId);
        if (movie == null) {
            throw new NotFoundException("Phim không tồn tại");
        }

        favoriteDAO.softRemove(userId, movieId);
    }

    /**
     * Retrieves paginated active favorites for the user (FAV-AC-06).
     * Only movies currently PUBLISHED and active are returned.
     * Order: createdAt DESC, id DESC.
     *
     * @param userId user identifier
     * @param requestedPage 1-based page number
     * @return paginated FavoritePage DTO
     */
    public FavoritePage getFavorites(Long userId, int requestedPage) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID không được để trống");
        }

        long totalCount = favoriteDAO.countActiveByUser(userId);
        int totalPages = totalCount == 0 ? 0 : (int) ((totalCount + PAGE_SIZE - 1) / PAGE_SIZE);

        int page = requestedPage < 1 ? 1 : requestedPage;
        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }

        int offset = (page - 1) * PAGE_SIZE;

        List<Long> movieIds = (totalCount == 0)
                ? Collections.emptyList()
                : favoriteDAO.findActiveMovieIdsByUser(userId, offset, PAGE_SIZE);

        List<MovieCard> items = movieIds.isEmpty()
                ? Collections.emptyList()
                : movieDAO.findCardsByIds(movieIds);

        return new FavoritePage(items, page, totalPages, totalCount);
    }
}
