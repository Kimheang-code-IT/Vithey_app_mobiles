package com.vithey.gateway;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.redis.core.ReactiveStringRedisTemplate;
import org.springframework.test.context.ActiveProfiles;

// Config Server import is disabled for tests so the context is deterministic
// regardless of whether a local config-server is running (see issue #37). The
// `spring.config.import` override must be supplied via @SpringBootTest
// properties; profile-specific application-test.yml cannot disable the import.
@SpringBootTest(
    properties = {
      "spring.config.import=",
      "spring.cloud.config.enabled=false"
    })
@ActiveProfiles("test")
class ApiGatewayContextTest {

  @MockBean
  private ReactiveStringRedisTemplate reactiveStringRedisTemplate;

  @Test
  void contextLoads() {}
}
