package com.moviehub.util;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * JPA Utility managing EntityManagerFactory singleton and EntityManager instances.
 */
public final class JPAUtil {

    private static final Logger LOGGER = Logger.getLogger(JPAUtil.class.getName());
    private static final String PERSISTENCE_UNIT_NAME = "MovieHubPU";
    private static volatile EntityManagerFactory emf;

    private JPAUtil() {
        // Utility class
    }

    public static EntityManagerFactory getEntityManagerFactory() {
        if (emf == null) {
            synchronized (JPAUtil.class) {
                if (emf == null) {
                    try {
                        Map<String, Object> configOverrides = new HashMap<>();
                        
                        String dbUrl = System.getenv("DB_URL");
                        if (dbUrl != null && !dbUrl.trim().isEmpty()) {
                            configOverrides.put("jakarta.persistence.jdbc.url", dbUrl.trim());
                        }

                        String dbUser = System.getenv("DB_USER");
                        if (dbUser != null && !dbUser.trim().isEmpty()) {
                            configOverrides.put("jakarta.persistence.jdbc.user", dbUser.trim());
                        }

                        String dbPassword = System.getenv("DB_PASSWORD");
                        if (dbPassword != null) {
                            configOverrides.put("jakarta.persistence.jdbc.password", dbPassword);
                        }

                        emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME, configOverrides);
                        LOGGER.info("EntityManagerFactory initialized successfully for unit: " + PERSISTENCE_UNIT_NAME);
                    } catch (Exception ex) {
                        LOGGER.log(Level.SEVERE, "Initial EntityManagerFactory creation failed: " + ex.getMessage(), ex);
                        throw new ExceptionInInitializerError(ex);
                    }
                }
            }
        }
        return emf;
    }

    public static EntityManager getEntityManager() {
        return getEntityManagerFactory().createEntityManager();
    }

    public static void shutdown() {
        if (emf != null && emf.isOpen()) {
            emf.close();
            LOGGER.info("EntityManagerFactory closed.");
        }
    }
}
