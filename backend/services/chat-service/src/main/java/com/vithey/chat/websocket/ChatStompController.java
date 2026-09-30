package com.vithey.chat.websocket;

import com.vithey.chat.dto.request.ChatReadPayload;
import com.vithey.chat.dto.request.ChatSendPayload;
import com.vithey.chat.dto.request.TypingRequest;
import com.vithey.chat.dto.response.MessageResponse;
import com.vithey.chat.exception.ApiException;
import com.vithey.chat.exception.ErrorCode;
import com.vithey.chat.security.CurrentUser;
import com.vithey.chat.security.StompUser;
import com.vithey.chat.service.MessageService;
import com.vithey.chat.service.PresenceService;
import com.vithey.chat.service.TypingService;
import java.security.Principal;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Controller;

@Controller
public class ChatStompController {

  private final MessageService messageService;
  private final TypingService typingService;
  private final PresenceService presenceService;

  public ChatStompController(
      MessageService messageService,
      TypingService typingService,
      PresenceService presenceService
  ) {
    this.messageService = messageService;
    this.typingService = typingService;
    this.presenceService = presenceService;
  }

  @MessageMapping("/chat.send")
  public MessageResponse send(ChatSendPayload payload, Principal principal) {
    CurrentUser currentUser = requireCurrentUser(principal);
    return messageService.sendMessage(
        payload.conversationId(),
        currentUser.userId(),
        payload.toSendMessageRequest()
    );
  }

  @MessageMapping("/chat.typing")
  public void typing(TypingRequest payload, Principal principal) {
    CurrentUser currentUser = requireCurrentUser(principal);
    typingService.handleTyping(payload.conversationId(), currentUser.userId(), payload.isTyping());
  }

  @MessageMapping("/chat.heartbeat")
  public void heartbeat(Principal principal) {
    CurrentUser currentUser = requireCurrentUser(principal);
    presenceService.refreshHeartbeat(currentUser.userId());
  }

  @MessageMapping("/chat.read")
  public MessageResponse read(ChatReadPayload payload, Principal principal) {
    CurrentUser currentUser = requireCurrentUser(principal);
    return messageService.markRead(payload.messageId(), currentUser.userId());
  }

  private CurrentUser requireCurrentUser(Principal principal) {
    if (principal instanceof UsernamePasswordAuthenticationToken auth
        && auth.getPrincipal() instanceof StompUser stompUser) {
      return stompUser.currentUser();
    }
    throw new ApiException(ErrorCode.UNAUTHORIZED);
  }
}
