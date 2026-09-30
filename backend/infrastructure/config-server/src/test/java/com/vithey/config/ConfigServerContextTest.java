package com.vithey.config;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles({"test", "native"})
class ConfigServerContextTest {

  @Test
  void contextLoads() {}
}
