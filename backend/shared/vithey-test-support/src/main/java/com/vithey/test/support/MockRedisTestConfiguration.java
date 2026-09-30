package com.vithey.test.support;

import static org.mockito.Mockito.mock;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.data.redis.core.StringRedisTemplate;

@TestConfiguration
public class MockRedisTestConfiguration {

  @Bean
  @Primary
  StringRedisTemplate stringRedisTemplate() {
    return mock(StringRedisTemplate.class);
  }
}
