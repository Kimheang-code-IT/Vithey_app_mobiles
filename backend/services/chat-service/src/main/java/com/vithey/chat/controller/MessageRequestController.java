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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/message-requests")
public class MessageRequestController {

  private final ConversationService conversationService;
  private final CurrentUserProvider currentUserProvider;

  public MessageRequestController(
      ConversationService conversationService,
      CurrentUserProvider currentUserProvider
  ) {
    this.conversationService = conversationService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<List<ConversationResponse>>> listPendingRequests() {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(conversationService.listPendingRequests(userId)));
  }

  /**
   * Create a pending message request (preferred path).
   * Prefer this over {@code POST /conversations/request}, which can 401 under Spring Security
   * path matching with {@code /{conversationId}/**} routes on some deployments.
   */
  @PostMapping
  ResponseEntity<ApiResponseWrapper<ConversationResponse>> createRequest(
      @Valid @RequestBody MessageRequestDto request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(conversationService.createRequest(userId, request)));
  }
}
