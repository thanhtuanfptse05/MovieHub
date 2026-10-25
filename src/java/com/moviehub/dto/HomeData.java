package com.moviehub.dto;

import java.io.Serializable;
import java.util.List;

/**
 * The four Home groups. Empty groups are hidden by the view.
 */
public class HomeData implements Serializable {

    private static final long serialVersionUID = 1L;

    private final MovieCard featured;
    private final List<MovieCard> newest;
    private final List<MovieCard> mostViewed;
    private final List<MovieCard> topRated;

    public HomeData(MovieCard featured, List<MovieCard> newest, List<MovieCard> mostViewed, List<MovieCard> topRated) {
        this.featured = featured;
        this.newest = newest;
        this.mostViewed = mostViewed;
        this.topRated = topRated;
    }

    public MovieCard getFeatured() {
        return featured;
    }

    public List<MovieCard> getNewest() {
        return newest;
    }

    public List<MovieCard> getMostViewed() {
        return mostViewed;
    }

    public List<MovieCard> getTopRated() {
        return topRated;
    }

    public boolean isNoMovies() {
        return featured == null && newest.isEmpty() && mostViewed.isEmpty() && topRated.isEmpty();
    }
}
