package com.moviehub.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility for BCrypt password hashing and verification.
 * Enforces BCrypt work factor (log rounds) >= 12 according to Layer 1 Rule SEC-01.
 */
public final class PasswordUtil {

    public static final int BCRYPT_LOG_ROUNDS = 12;

    private PasswordUtil() {
        // Utility class
    }

    /**
     * Hashes password using BCrypt with work factor 12.
     *
     * @param plainPassword plaintext password
     * @return BCrypt hash string
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_LOG_ROUNDS));
    }

    /**
     * Verifies plain password against stored BCrypt hash.
     *
     * @param plainPassword candidate password
     * @param hashedPassword stored BCrypt hash
     * @return true if password matches hash, false otherwise
     */
    public static boolean verifyPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null || hashedPassword.isEmpty()) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }
}
