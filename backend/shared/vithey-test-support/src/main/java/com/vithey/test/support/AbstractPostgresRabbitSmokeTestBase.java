package com.vithey.test.support;

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.containers.RabbitMQContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers(disabledWithoutDocker = true)
public abstract class AbstractPostgresRabbitSmokeTestBase {

  @Container
  protected static final PostgreSQLContainer<?> POSTGRES =
      new PostgreSQLContainer<>("postgres:16-alpine");

  @Container
  protected static final RabbitMQContainer RABBIT =
      new RabbitMQContainer("rabbitmq:3.13-management-alpine");

  @DynamicPropertySource
  static void registerProperties(DynamicPropertyRegistry registry) {
    IntegrationTestProperties.applyCommon(registry);
    IntegrationTestProperties.applyPostgres(registry, POSTGRES);
    IntegrationTestProperties.applyRabbit(registry, RABBIT);
  }
}
