package com.vithey.career;

import com.vithey.test.support.AbstractPostgresRabbitSmokeTestBase;
import com.vithey.test.support.HealthAssertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class CareerServiceSmokeIT extends AbstractPostgresRabbitSmokeTestBase {

  @Autowired
  private TestRestTemplate restTemplate;

  @Test
  void applicationStartsAndHealthIsUp() {
    HealthAssertions.assertActuatorHealthUp(restTemplate);
  }
}
