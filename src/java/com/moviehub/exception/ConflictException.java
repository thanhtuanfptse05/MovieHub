package com.moviehub.exception;

/**
 * Thrown when an operation conflicts with the current state of a resource (maps to HTTP 409).
 */
public class ConflictException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public ConflictException(String message) {
        super(message);
    }
}
