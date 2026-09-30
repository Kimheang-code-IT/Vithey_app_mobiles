package com.vithey.content.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verifyNoInteractions;

import com.vithey.content.event.publisher.ContentEventPublisher;
import com.vithey.content.exception.ApiException;
import com.vithey.content.exception.ErrorCode;
import com.vithey.content.repository.FollowRepository;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class FollowServiceTest {

  @Mock
  private FollowRepository followRepository;

  @Mock
  private PostEnrichmentService postEnrichmentService;

  @Mock
  private ContentEventPublisher contentEventPublisher;

  @InjectMocks
  private FollowService followService;

  @Test
  void follow_rejectsSelfFollow() {
    UUID userId = UUID.randomUUID();

    ApiException exception = assertThrows(ApiException.class, () -> followService.follow(userId, userId));

    assertEquals(ErrorCode.BUSINESS_RULE_VIOLATION, exception.getErrorCode());
    verifyNoInteractions(followRepository, contentEventPublisher);
  }
}
