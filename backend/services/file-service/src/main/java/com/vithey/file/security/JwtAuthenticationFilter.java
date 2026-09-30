package com.vithey.file.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.vithey.file.exception.ErrorCode;
import com.vithey.file.util.ApiResponseWrapper;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

  private final JwtProvider jwtProvider;
  private final ObjectMapper objectMapper;

  public JwtAuthenticationFilter(JwtProvider jwtProvider, ObjectMapper objectMapper) {
    this.jwtProvider = jwtProvider;
    this.objectMapper = objectMapper;
  }

  @Override
  protected boolean shouldNotFilter(HttpServletRequest request) {
    String path = request.getRequestURI();
    return path.startsWith("/actuator")
        || path.startsWith("/swagger-ui")
        || path.startsWith("/v3/api-docs")
        || path.equals("/error");
  }

  @Override
  protected void doFilterInternal(
      HttpServletRequest request,
      HttpServletResponse response,
      FilterChain filterChain
  ) throws ServletException, IOException {
    try {
      CurrentUser currentUser = resolveCurrentUser(request);
      if (currentUser != null) {
        List<SimpleGrantedAuthority> authorities = currentUser.roles().stream()
            .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
            .toList();
        UsernamePasswordAuthenticationToken authentication =
            new UsernamePasswordAuthenticationToken(currentUser, null, authorities);
        SecurityContextHolder.getContext().setAuthentication(authentication);
      }
    } catch (JwtException | IllegalArgumentException exception) {
      SecurityContextHolder.clearContext();
      writeUnauthorized(response);
      return;
    }

    filterChain.doFilter(request, response);
  }

  private void writeUnauthorized(HttpServletResponse response) throws IOException {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    objectMapper.writeValue(
        response.getOutputStream(),
        ApiResponseWrapper.error(ErrorCode.UNAUTHORIZED.name(), ErrorCode.UNAUTHORIZED.defaultMessage())
    );
  }

  private CurrentUser resolveCurrentUser(HttpServletRequest request) {
    String authorization = request.getHeader("Authorization");
    if (StringUtils.hasText(authorization) && authorization.startsWith("Bearer ")) {
      return jwtProvider.parseAccessToken(authorization.substring(7));
    }

    String gatewayUserId = request.getHeader("X-User-Id");
    if (!StringUtils.hasText(gatewayUserId)) {
      return null;
    }

    return jwtProvider.fromGatewayHeaders(
        gatewayUserId,
        request.getHeader("X-User-Email"),
        request.getHeader("X-User-Roles")
    );
  }
}
