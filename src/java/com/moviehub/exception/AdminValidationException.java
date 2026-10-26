package com.moviehub.exception;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/** Validation failures keyed by submitted field (HTTP 400). */
public class AdminValidationException extends IllegalArgumentException {
    private static final long serialVersionUID = 1L;
    private final Map<String, String> errors;
    public AdminValidationException(Map<String, String> errors) {
        super(errors.isEmpty() ? "Dữ liệu không hợp lệ." : errors.values().iterator().next());
        this.errors = Collections.unmodifiableMap(new LinkedHashMap<>(errors));
    }
    public Map<String, String> getErrors() { return errors; }
}
