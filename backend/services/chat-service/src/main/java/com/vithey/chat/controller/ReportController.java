package com.vithey.chat.controller;

import com.vithey.chat.dto.request.ReportUserRequest;
import com.vithey.chat.dto.response.ReportResponse;
import com.vithey.chat.security.CurrentUserProvider;
import com.vithey.chat.service.ReportService;
import com.vithey.chat.util.ApiResponseWrapper;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/{userId}/report")
public class ReportController {

  private final ReportService reportService;
  private final CurrentUserProvider currentUserProvider;

  public ReportController(ReportService reportService, CurrentUserProvider currentUserProvider) {
    this.reportService = reportService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping
  ResponseEntity<ApiResponseWrapper<ReportResponse>> reportUser(
      @PathVariable UUID userId,
      @Valid @RequestBody ReportUserRequest request
  ) {
    UUID reporterId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(reportService.reportUser(reporterId, userId, request)));
  }
}
