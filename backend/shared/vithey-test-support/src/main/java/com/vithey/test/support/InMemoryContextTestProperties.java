package com.vithey.test.support;

import org.springframework.test.context.DynamicPropertyRegistry;

/**
 * Lightweight context tests without Docker — use embedded H2 instead of PostgreSQL.
 * Flyway is disabled; schema is not migrated (context wiring only).
 */
public final class InMemoryContextTestProperties {

  private InMemoryContextTestProperties() {}

  public static void apply(DynamicPropertyRegistry registry) {
    IntegrationTestProperties.applyCommon(registry);
    registry.add("spring.datasource.url", () -> "jdbc:h2:mem:vithey-test;MODE=PostgreSQL;DB_CLOSE_DELAY=-1");
    registry.add("spring.datasource.username", () -> "sa");
    registry.add("spring.datasource.password", () -> "");
    registry.add("spring.datasource.driver-class-name", () -> "org.h2.Driver");
    registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
    registry.add("spring.flyway.enabled", () -> "false");
  }
}
