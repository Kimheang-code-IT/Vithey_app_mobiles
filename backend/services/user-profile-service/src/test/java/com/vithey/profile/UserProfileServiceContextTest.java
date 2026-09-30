package com.vithey.profile;

import com.vithey.test.support.AbstractInMemoryContextTestBase;
import com.vithey.test.support.WithMockMessaging;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
@WithMockMessaging
class UserProfileServiceContextTest extends AbstractInMemoryContextTestBase {

  @Test
  void contextLoads() {}
}
