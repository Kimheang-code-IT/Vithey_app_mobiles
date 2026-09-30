package com.vithey.test.support;

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

public abstract class AbstractInMemoryContextTestBase {

  @DynamicPropertySource
  static void registerProperties(DynamicPropertyRegistry registry) {
    InMemoryContextTestProperties.apply(registry);
  }
}
