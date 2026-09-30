package com.vithey.gateway.util;

import java.util.List;
import org.springframework.http.server.PathContainer;
import org.springframework.stereotype.Component;
import org.springframework.web.util.pattern.PathPattern;
import org.springframework.web.util.pattern.PathPatternParser;

@Component
public class PublicPathMatcher {

  private final List<PathPattern> publicPatterns;

  public PublicPathMatcher() {
    PathPatternParser parser = new PathPatternParser();
    this.publicPatterns = List.of(
        parser.parse("/api/v1/auth/register"),
        parser.parse("/api/v1/auth/login"),
        parser.parse("/api/v1/auth/google"),
        parser.parse("/api/v1/auth/refresh"),
        parser.parse("/api/v1/auth/forgot-password"),
        parser.parse("/api/v1/auth/reset-password"),
        parser.parse("/api/v1/auth/verify-email"),
        parser.parse("/actuator/**"),
        parser.parse("/swagger-ui.html"),
        parser.parse("/swagger-ui/**"),
        parser.parse("/v3/api-docs/**")
    );
  }

  public boolean isPublic(String path) {
    PathContainer pathContainer = PathContainer.parsePath(path);
    return publicPatterns.stream().anyMatch(pattern -> pattern.matches(pathContainer));
  }
}
