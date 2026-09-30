package com.vithey.eureka;

import com.vithey.test.support.HealthAssertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class EurekaServerSmokeIT {

  @Autowired
  private TestRestTemplate restTemplate;

  @Test
  void applicationStartsAndHealthIsUp() {
    HealthAssertions.assertActuatorHealthUp(restTemplate);
  }
}
