package com.vithey.chat.controller;

import com.vithey.chat.dto.request.MessageRequestDto;
import com.vithey.chat.dto.response.ConversationResponse;
import com.vithey.chat.security.CurrentUserProvider;
import com.vithey.chat.service.ConversationService;
import com.vithey.chat.util.ApiResponseWrapper;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/conversations")
public class ConversationController {

  private final ConversationService conversationService;
  private final CurrentUserProvider currentUserProvider;

  public ConversationController(
      ConversationService conversationService,
      CurrentUserProvider currentUserProvider
  ) {
    this.conversationService = conversationService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<List<ConversationResponse>>> listConversations(
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(conversationService.listConversations(userId, page, limit));
  }

  @PostMapping("/start")
  ResponseEntity<ApiResponseWrapper<ConversationResponse>> createRequest(
      @Valid @RequestBody MessageRequestDto request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(conversationService.createRequest(userId, request)));
  }

  @PostMapping("/{conversationId}/accept")
  ResponseEntity<ApiResponseWrapper<ConversationResponse>> accept(
      @PathVariable UUID conversationId
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(conversationService.acceptRequest(conversationId, userId)));
  }

  @PostMapping("/{conversationId}/decline")
  ResponseEntity<ApiResponseWrapper<ConversationResponse>> decline(
      @PathVariable UUID conversationId
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(conversationService.declineRequest(conversationId, userId)));
  }

  @PostMapping("/{conversationId}/block")
  ResponseEntity<ApiResponseWrapper<ConversationResponse>> block(
      @PathVariable UUID conversationId
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(conversationService.blockConversation(conversationId, userId)));
  }

  @GetMapping("/{conversationId}/presence")
  ResponseEntity<ApiResponseWrapper<com.vithey.chat.dto.response.PresenceResponse>> presence(
      @PathVariable UUID conversationId
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(conversationService.partnerPresence(conversationId, userId)));
  }
}
