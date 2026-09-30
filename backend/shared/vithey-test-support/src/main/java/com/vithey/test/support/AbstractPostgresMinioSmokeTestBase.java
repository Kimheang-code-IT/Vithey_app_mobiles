package com.vithey.test.support;

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

@Testcontainers(disabledWithoutDocker = true)
public abstract class AbstractPostgresMinioSmokeTestBase {

  @Container
  protected static final PostgreSQLContainer<?> POSTGRES =
      new PostgreSQLContainer<>("postgres:16-alpine");

  @Container
  protected static final GenericContainer<?> MINIO = new GenericContainer<>(
      DockerImageName.parse("minio/minio:latest")
  )
      .withEnv("MINIO_ROOT_USER", "minioadmin")
      .withEnv("MINIO_ROOT_PASSWORD", "minioadmin")
      .withCommand("server", "/data")
      .withExposedPorts(9000);

  @DynamicPropertySource
  static void registerProperties(DynamicPropertyRegistry registry) {
    IntegrationTestProperties.applyCommon(registry);
    IntegrationTestProperties.applyPostgres(registry, POSTGRES);
    IntegrationTestProperties.applyMinio(registry, MINIO);
  }
}
