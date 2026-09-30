package com.vithey.gateway;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.redis.core.ReactiveStringRedisTemplate;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class ApiGatewayContextTest {

  @MockBean
  private ReactiveStringRedisTemplate reactiveStringRedisTemplate;

  @Test
  void contextLoads() {}
}
