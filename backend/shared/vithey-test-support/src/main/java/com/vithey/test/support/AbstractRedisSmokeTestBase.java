package com.vithey.test.support;

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

@Testcontainers(disabledWithoutDocker = true)
public abstract class AbstractRedisSmokeTestBase {

  @Container
  protected static final GenericContainer<?> REDIS = new GenericContainer<>(
      DockerImageName.parse("redis:7-alpine")
  ).withExposedPorts(6379);

  @DynamicPropertySource
  static void registerProperties(DynamicPropertyRegistry registry) {
    IntegrationTestProperties.applyCommon(registry);
    IntegrationTestProperties.applyRedis(registry, REDIS);
  }
}
