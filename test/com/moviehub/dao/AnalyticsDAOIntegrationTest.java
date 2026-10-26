package com.moviehub.dao;

import com.moviehub.dto.AdminDashboardDTO;
import com.moviehub.dto.CategoryStatDTO;
import com.moviehub.dto.TopMovieDTO;
import com.moviehub.util.JPAUtil;
import jakarta.persistence.EntityManager;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Integration test verifying AnalyticsDAO against the active SQL Server database (008-admin-analytics).
 * Verifies real JPQL queries, aggregation accuracy, and non-null metrics.
 */
public class AnalyticsDAOIntegrationTest {

    @Test
    public void testFetchDashboardMetrics_LiveDatabase_ReturnsValidAggregations() {
        AnalyticsDAO dao = new AnalyticsDAO();
        EntityManager em = JPAUtil.getEntityManager();
        try {
            AdminDashboardDTO dto = dao.fetchDashboardMetrics(em);

            assertNotNull("Dashboard DTO must not be null", dto);
            assertTrue("Total movies should be >= 0", dto.getTotalMovies() >= 0);
            assertTrue("Published movies should be <= total movies", dto.getPublishedMovies() <= dto.getTotalMovies());
            assertTrue("Total users should be >= 0", dto.getTotalUsers() >= 0);
            assertTrue("Total reviews should be >= 0", dto.getTotalReviews() >= 0);
            assertTrue("Total views should be >= 0", dto.getTotalViews() >= 0);
            assertTrue("Total pending should equal sum of parts",
                    dto.getTotalPending() == (dto.getPendingReviews() + dto.getPendingQuestions() + dto.getPendingAnswers()));

            // Top movies count must be at most 5
            assertNotNull("Top movies list must not be null", dto.getTopMovies());
            assertTrue("Top movies should contain at most 5 items", dto.getTopMovies().size() <= 5);

            // If top movies exist, verify they are non-increasing by view count
            long prevViews = Long.MAX_VALUE;
            for (TopMovieDTO m : dto.getTopMovies()) {
                assertTrue("Top movies must be sorted by view count descending", m.getViewCount() <= prevViews);
                prevViews = m.getViewCount();
                assertNotNull("Title must not be null", m.getTitle());
            }

            // Category stats must not be null
            assertNotNull("Category stats list must not be null", dto.getCategoryStats());
            long prevCatCount = Long.MAX_VALUE;
            for (CategoryStatDTO cat : dto.getCategoryStats()) {
                assertTrue("Category count should be non-negative", cat.getMovieCount() >= 0);
                assertTrue("Category stats must be sorted by count descending", cat.getMovieCount() <= prevCatCount);
                prevCatCount = cat.getMovieCount();
                assertNotNull("Category name must not be null", cat.getName());
            }

            // Verify KPI-06 max/min consistency
            if (dto.getTotalMovies() > 0) {
                assertNotNull("Max views must be present when movies exist", dto.getMaxViews());
                assertNotNull("Min views must be present when movies exist", dto.getMinViews());
                assertTrue("Max views must be >= Min views", dto.getMaxViews() >= dto.getMinViews());
            } else {
                assertNull("Max views must be null on empty movies", dto.getMaxViews());
                assertNull("Min views must be null on empty movies", dto.getMinViews());
            }

            // Verify KPI-07 average rating formatting
            if (dto.getAverageRating() != null) {
                assertTrue("Average rating must be between 1.0 and 5.0",
                        dto.getAverageRating() >= 1.0 && dto.getAverageRating() <= 5.0);
                assertFalse("Rating text must not be N/A when averageRating exists",
                        "N/A".equals(dto.getAverageRatingText()));
            } else {
                assertEquals("Rating text must be N/A when no approved reviews exist",
                        "N/A", dto.getAverageRatingText());
            }
        } finally {
            em.close();
        }
    }
}
