package com.vithey.auth.security;

import com.vithey.auth.entity.Role;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

  private final JwtProvider jwtProvider;

  public JwtAuthenticationFilter(JwtProvider jwtProvider) {
    this.jwtProvider = jwtProvider;
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
      filterChain.doFilter(request, response);
    } catch (JwtException | IllegalArgumentException exception) {
      SecurityContextHolder.clearContext();
      filterChain.doFilter(request, response);
      return;
    }
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

    String email = request.getHeader("X-User-Email");
    String rolesHeader = request.getHeader("X-User-Roles");
    List<String> roles = StringUtils.hasText(rolesHeader)
        ? Arrays.stream(rolesHeader.split(",")).map(String::trim).filter(StringUtils::hasText).toList()
        : List.of(Role.USER.name());

    return new CurrentUser(UUID.fromString(gatewayUserId), email, roles);
  }
}
