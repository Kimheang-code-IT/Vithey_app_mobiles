package com.vithey.file;

import com.vithey.test.support.AbstractPostgresMinioSmokeTestBase;
import com.vithey.test.support.HealthAssertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class FileServiceSmokeIT extends AbstractPostgresMinioSmokeTestBase {

  @Autowired
  private TestRestTemplate restTemplate;

  @Test
  void applicationStartsAndHealthIsUp() {
    HealthAssertions.assertActuatorHealthUp(restTemplate);
  }
}
