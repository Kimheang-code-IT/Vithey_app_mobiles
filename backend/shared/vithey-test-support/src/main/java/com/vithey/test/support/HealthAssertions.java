package com.vithey.test.support;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Map;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.web.reactive.server.WebTestClient;

public final class HealthAssertions {

  private HealthAssertions() {}

  @SuppressWarnings("unchecked")
  public static void assertActuatorHealthUp(TestRestTemplate restTemplate) {
    ResponseEntity<Map> response = restTemplate.getForEntity("/actuator/health", Map.class);
    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().get("status")).isEqualTo("UP");
  }

  public static void assertActuatorHealthUp(WebTestClient webTestClient) {
    webTestClient.get()
        .uri("/actuator/health")
        .exchange()
        .expectStatus().isOk()
        .expectBody()
        .jsonPath("$.status").isEqualTo("UP");
  }
}
