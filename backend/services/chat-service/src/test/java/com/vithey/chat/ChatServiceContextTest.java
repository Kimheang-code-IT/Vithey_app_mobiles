package com.vithey.chat;

import com.vithey.test.support.AbstractInMemoryContextTestBase;
import com.vithey.test.support.WithMockMessaging;
import com.vithey.test.support.WithMockRedis;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(properties = "spring.main.allow-bean-definition-overriding=true")
@ActiveProfiles("test")
@WithMockMessaging
@WithMockRedis
class ChatServiceContextTest extends AbstractInMemoryContextTestBase {

  @Test
  void contextLoads() {}
}
