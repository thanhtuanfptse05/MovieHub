package com.moviehub.service;

import com.moviehub.dao.AnalyticsDAO;
import com.moviehub.dto.AdminDashboardDTO;
import com.moviehub.dto.CategoryStatDTO;
import com.moviehub.dto.TopMovieDTO;
import jakarta.persistence.EntityManager;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit test suite for AnalyticsService (008-admin-analytics).
 * Validates business logic, KPI metrics aggregation, empty states, formatting, and error handling.
 */
public class AnalyticsServiceTest {

    private MockAnalyticsDAO mockDAO;
    private AnalyticsService analyticsService;

    @Before
    public void setUp() {
        mockDAO = new MockAnalyticsDAO();
        analyticsService = new AnalyticsService(mockDAO);
    }

    @Test
    public void testGetDashboardData_NormalDataset_ComputesAllKPIsCorrectly() {
        AdminDashboardDTO fixture = new AdminDashboardDTO();
        fixture.setTotalMovies(3);
        fixture.setPublishedMovies(2);
        fixture.setTotalUsers(5);
        fixture.setTotalReviews(8);
        fixture.setTotalViews(200);
        fixture.setMaxViews(100L);
        fixture.setMinViews(40L);
        fixture.setAverageRating(3.0);
        fixture.setPendingReviews(2);
        fixture.setPendingQuestions(1);
        fixture.setPendingAnswers(3);
        fixture.setTotalPending(6);

        List<TopMovieDTO> top = Arrays.asList(
                new TopMovieDTO(1L, "Movie A", 2024, "PUBLISHED", 100),
                new TopMovieDTO(2L, "Movie B", 2023, "PUBLISHED", 60),
                new TopMovieDTO(3L, "Movie C", 2022, "DRAFT", 40)
        );
        fixture.setTopMovies(top);

        List<CategoryStatDTO> cats = Arrays.asList(
                new CategoryStatDTO(10L, "Hành Động", 2),
                new CategoryStatDTO(20L, "Tâm Lý", 1),
                new CategoryStatDTO(30L, "Hài Hước", 0)
        );
        fixture.setCategoryStats(cats);

        mockDAO.dtoToReturn = fixture;

        AdminDashboardDTO result = analyticsService.getDashboardData();
        assertNotNull(result);
        assertEquals(3, result.getTotalMovies());
        assertEquals(2, result.getPublishedMovies());
        assertEquals(5, result.getTotalUsers());
        assertEquals(8, result.getTotalReviews());
        assertEquals(200, result.getTotalViews());
        assertEquals(Long.valueOf(100), result.getMaxViews());
        assertEquals(Long.valueOf(40), result.getMinViews());
        assertEquals("100", result.getMaxViewsText());
        assertEquals("40", result.getMinViewsText());
        assertEquals(Double.valueOf(3.0), result.getAverageRating());
        assertEquals("3.0", result.getAverageRatingText());

        assertEquals(2, result.getPendingReviews());
        assertEquals(1, result.getPendingQuestions());
        assertEquals(3, result.getPendingAnswers());
        assertEquals(6, result.getTotalPending());

        assertEquals(3, result.getTopMovies().size());
        assertEquals("Movie A", result.getTopMovies().get(0).getTitle());
        assertEquals(3, result.getCategoryStats().size());
        assertEquals("Hành Động", result.getCategoryStats().get(0).getName());
    }

    @Test
    public void testGetDashboardData_EmptyDataset_ReturnsZerosAndNA() {
        AdminDashboardDTO emptyFixture = new AdminDashboardDTO();
        emptyFixture.setTotalMovies(0);
        emptyFixture.setPublishedMovies(0);
        emptyFixture.setTotalUsers(0);
        emptyFixture.setTotalReviews(0);
        emptyFixture.setTotalViews(0);
        emptyFixture.setMaxViews(null);
        emptyFixture.setMinViews(null);
        emptyFixture.setAverageRating(null);
        emptyFixture.setPendingReviews(0);
        emptyFixture.setPendingQuestions(0);
        emptyFixture.setPendingAnswers(0);
        emptyFixture.setTotalPending(0);
        emptyFixture.setTopMovies(new ArrayList<>());
        emptyFixture.setCategoryStats(new ArrayList<>());

        mockDAO.dtoToReturn = emptyFixture;

        AdminDashboardDTO result = analyticsService.getDashboardData();
        assertNotNull(result);
        assertEquals(0, result.getTotalMovies());
        assertEquals(0, result.getPublishedMovies());
        assertEquals(0, result.getTotalUsers());
        assertEquals(0, result.getTotalReviews());
        assertEquals(0, result.getTotalViews());
        assertNull(result.getMaxViews());
        assertNull(result.getMinViews());
        assertEquals("N/A", result.getMaxViewsText());
        assertEquals("N/A", result.getMinViewsText());
        assertNull(result.getAverageRating());
        assertEquals("N/A", result.getAverageRatingText());
        assertEquals(0, result.getTotalPending());
        assertTrue(result.getTopMovies().isEmpty());
        assertTrue(result.getCategoryStats().isEmpty());
    }

    @Test
    public void testGetDashboardData_ZeroViewsMovies_ReturnsZeroNotNA() {
        AdminDashboardDTO fixture = new AdminDashboardDTO();
        fixture.setTotalMovies(1);
        fixture.setMaxViews(0L);
        fixture.setMinViews(0L);
        mockDAO.dtoToReturn = fixture;

        AdminDashboardDTO result = analyticsService.getDashboardData();
        assertEquals("0", result.getMaxViewsText());
        assertEquals("0", result.getMinViewsText());
    }

    @Test
    public void testAverageRatingFormatting_RoundsToOneDecimal() {
        AdminDashboardDTO fixture = new AdminDashboardDTO();
        fixture.setAverageRating(4.33333333);
        mockDAO.dtoToReturn = fixture;
        assertEquals("4.3", analyticsService.getDashboardData().getAverageRatingText());

        fixture.setAverageRating(4.66666667);
        assertEquals("4.7", analyticsService.getDashboardData().getAverageRatingText());
    }

    @Test(expected = RuntimeException.class)
    public void testGetDashboardData_DatabaseFailure_ThrowsRuntimeExceptionWithoutFakeZeros() {
        mockDAO.throwException = new RuntimeException("SQL Server Connection Timeout");
        analyticsService.getDashboardData();
    }

    @Test(expected = RuntimeException.class)
    public void testGetDashboardData_NullDto_ThrowsRuntimeException() {
        mockDAO.dtoToReturn = null;
        analyticsService.getDashboardData();
    }

    private static class MockAnalyticsDAO extends AnalyticsDAO {
        AdminDashboardDTO dtoToReturn;
        RuntimeException throwException;

        @Override
        public AdminDashboardDTO fetchDashboardMetrics() {
            if (throwException != null) {
                throw throwException;
            }
            return dtoToReturn;
        }

        @Override
        public AdminDashboardDTO fetchDashboardMetrics(EntityManager em) {
            return fetchDashboardMetrics();
        }
    }
}
