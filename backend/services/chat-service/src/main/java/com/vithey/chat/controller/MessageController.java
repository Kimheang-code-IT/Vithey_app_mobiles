package com.vithey.chat.controller;

import com.vithey.chat.dto.request.BatchReadRequest;
import com.vithey.chat.dto.request.SendMessageRequest;
import com.vithey.chat.dto.response.MessageResponse;
import com.vithey.chat.security.CurrentUserProvider;
import com.vithey.chat.service.MessageService;
import com.vithey.chat.util.ApiResponseWrapper;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MessageController {

  private final MessageService messageService;
  private final CurrentUserProvider currentUserProvider;

  public MessageController(MessageService messageService, CurrentUserProvider currentUserProvider) {
    this.messageService = messageService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping("/api/v1/conversations/{conversationId}/messages")
  ResponseEntity<ApiResponseWrapper<List<MessageResponse>>> listMessages(
      @PathVariable UUID conversationId,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(messageService.listMessages(conversationId, userId, page, limit));
  }

  @PostMapping("/api/v1/conversations/{conversationId}/messages")
  ResponseEntity<ApiResponseWrapper<MessageResponse>> sendMessage(
      @PathVariable UUID conversationId,
      @Valid @RequestBody SendMessageRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(messageService.sendMessage(conversationId, userId, request)));
  }

  @PostMapping("/api/v1/conversations/{conversationId}/messages/read")
  ResponseEntity<ApiResponseWrapper<List<MessageResponse>>> markReadBatch(
      @PathVariable UUID conversationId,
      @Valid @RequestBody BatchReadRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(
        ApiResponseWrapper.success(messageService.markReadBatch(conversationId, userId, request))
    );
  }

  @PatchMapping("/api/v1/messages/{messageId}/read")
  ResponseEntity<ApiResponseWrapper<MessageResponse>> markRead(@PathVariable UUID messageId) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(messageService.markRead(messageId, userId)));
  }
}
