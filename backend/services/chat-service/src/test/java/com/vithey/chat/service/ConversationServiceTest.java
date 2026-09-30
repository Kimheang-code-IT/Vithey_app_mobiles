package com.vithey.chat.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verifyNoInteractions;

import com.vithey.chat.dto.request.MessageRequestDto;
import com.vithey.chat.event.publisher.ChatEventPublisher;
import com.vithey.chat.exception.ApiException;
import com.vithey.chat.exception.ErrorCode;
import com.vithey.chat.repository.BlockRepository;
import com.vithey.chat.repository.ConversationParticipantRepository;
import com.vithey.chat.repository.ConversationRepository;
import com.vithey.chat.repository.MessageRepository;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class ConversationServiceTest {

  @Mock
  private ConversationRepository conversationRepository;

  @Mock
  private ConversationParticipantRepository participantRepository;

  @Mock
  private MessageRepository messageRepository;

  @Mock
  private BlockRepository blockRepository;

  @Mock
  private ConversationAccessService accessService;

  @Mock
  private ParticipantProfileService participantProfileService;

  @Mock
  private ChatEventPublisher chatEventPublisher;

  @Mock
  private PresenceService presenceService;

  @InjectMocks
  private ConversationService conversationService;

  @Test
  void createRequest_rejectsSelfMessage() {
    UUID userId = UUID.randomUUID();
    MessageRequestDto request = new MessageRequestDto(userId, "Hello");

    ApiException exception = assertThrows(
        ApiException.class,
        () -> conversationService.createRequest(userId, request)
    );

    assertEquals(ErrorCode.BUSINESS_RULE_VIOLATION, exception.getErrorCode());
    verifyNoInteractions(conversationRepository, chatEventPublisher);
  }
}
