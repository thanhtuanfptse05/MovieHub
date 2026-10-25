package com.moviehub.service;

import com.moviehub.dao.AnalyticsDAO;
import com.moviehub.dto.AdminDashboardDTO;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service orchestrating Admin Analytics calculations and dashboard aggregation (008-admin-analytics).
 * Enforces business rules ANA-AC-01 through ANA-AC-10.
 */
public class AnalyticsService {

    private static final Logger LOGGER = Logger.getLogger(AnalyticsService.class.getName());

    private final AnalyticsDAO analyticsDAO;

    public AnalyticsService() {
        this(new AnalyticsDAO());
    }

    public AnalyticsService(AnalyticsDAO analyticsDAO) {
        this.analyticsDAO = analyticsDAO;
    }

    /**
     * Retrieves the complete dashboard metrics snapshot (ANA-AC-02, ANA-AC-09).
     *
     * @return populated AdminDashboardDTO
     * @throws RuntimeException if database access fails (ANA-AC-08: do NOT return fake zeros).
     */
    public AdminDashboardDTO getDashboardData() {
        try {
            AdminDashboardDTO dto = analyticsDAO.fetchDashboardMetrics();
            if (dto == null) {
                throw new IllegalStateException("Analytics DAO returned null metrics");
            }
            return dto;
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Failed to load admin dashboard analytics metrics", ex);
            throw new RuntimeException("Database error loading admin dashboard metrics", ex);
        }
    }
}
