package com.moviehub.exception;

/**
 * Thrown when a requested resource is not found or not visible (maps to HTTP 404).
 */
public class NotFoundException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public NotFoundException(String message) {
        super(message);
    }
}
