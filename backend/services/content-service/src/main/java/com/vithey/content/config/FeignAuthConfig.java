package com.vithey.content.config;

import feign.RequestInterceptor;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Configuration
public class FeignAuthConfig {

  private static final String[] FORWARD_HEADERS = {
      "Authorization",
      "X-User-Id",
      "X-User-Email",
      "X-User-Roles"
  };

  @Bean
  RequestInterceptor authHeaderForwardingInterceptor() {
    return template -> {
      if (!(RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes attributes)) {
        return;
      }

      HttpServletRequest request = attributes.getRequest();
      for (String header : FORWARD_HEADERS) {
        String value = request.getHeader(header);
        if (StringUtils.hasText(value)) {
          template.header(header, value);
        }
      }
    };
  }
}
