package com.moviehub.exception;

/**
 * Thrown when an actor is forbidden from accessing or mutating a resource (maps to HTTP 403).
 */
public class ForbiddenException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public ForbiddenException(String message) {
        super(message);
    }
}
