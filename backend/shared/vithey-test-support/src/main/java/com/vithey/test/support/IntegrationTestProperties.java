package com.vithey.test.support;

import org.springframework.test.context.DynamicPropertyRegistry;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.RabbitMQContainer;
import org.testcontainers.containers.PostgreSQLContainer;

public final class IntegrationTestProperties {

  public static final String TEST_JWT_SECRET =
      "test-secret-with-at-least-256-bits-for-jjwt-integration";

  private IntegrationTestProperties() {}

  public static void applyCommon(DynamicPropertyRegistry registry) {
    registry.add("eureka.client.enabled", () -> "false");
    registry.add("spring.cloud.config.enabled", () -> "false");
    registry.add("spring.cloud.discovery.enabled", () -> "false");
    registry.add("vithey.jwt.secret", () -> TEST_JWT_SECRET);
  }

  public static void applyPostgres(
      DynamicPropertyRegistry registry,
      PostgreSQLContainer<?> postgres
  ) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);
    registry.add("spring.datasource.username", postgres::getUsername);
    registry.add("spring.datasource.password", postgres::getPassword);
  }

  public static void applyRabbit(
      DynamicPropertyRegistry registry,
      RabbitMQContainer rabbit
  ) {
    registry.add("spring.rabbitmq.host", rabbit::getHost);
    registry.add("spring.rabbitmq.port", rabbit::getAmqpPort);
    registry.add("spring.rabbitmq.username", rabbit::getAdminUsername);
    registry.add("spring.rabbitmq.password", rabbit::getAdminPassword);
  }

  public static void applyRedis(
      DynamicPropertyRegistry registry,
      GenericContainer<?> redis
  ) {
    registry.add("spring.data.redis.host", redis::getHost);
    registry.add("spring.data.redis.port", () -> redis.getMappedPort(6379));
  }

  public static void applyMinio(
      DynamicPropertyRegistry registry,
      GenericContainer<?> minio
  ) {
    String endpoint = "http://" + minio.getHost() + ":" + minio.getMappedPort(9000);
    registry.add("vithey.minio.endpoint", () -> endpoint);
    registry.add("vithey.minio.access-key", () -> "minioadmin");
    registry.add("vithey.minio.secret-key", () -> "minioadmin");
    registry.add("vithey.minio.buckets", () -> "avatars,cvs");
  }
}
