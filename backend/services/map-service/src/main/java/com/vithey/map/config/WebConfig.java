package com.vithey.map.config;

import com.vithey.map.security.CurrentUserArgumentResolver;
import java.util.List;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer { // resolves @param CurrentUser

  private final CurrentUserArgumentResolver currentUserArgumentResolver;

  public WebConfig(CurrentUserArgumentResolver currentUserArgumentResolver) {
    this.currentUserArgumentResolver = currentUserArgumentResolver;
  }

  @Override
  public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
    resolvers.add(currentUserArgumentResolver);
  }
}
