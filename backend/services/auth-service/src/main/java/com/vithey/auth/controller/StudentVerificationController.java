package com.vithey.auth.controller;

import com.vithey.auth.dto.request.StudentVerifyRequest;
import com.vithey.auth.dto.response.StudentVerificationResponse;
import com.vithey.auth.security.CurrentUserProvider;
import com.vithey.auth.service.StudentVerificationService;
import com.vithey.auth.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/students")
@Tag(name = "Student Verification", description = "AUB student verification")
public class StudentVerificationController {

  private final StudentVerificationService studentVerificationService;
  private final CurrentUserProvider currentUserProvider;

  public StudentVerificationController(
      StudentVerificationService studentVerificationService,
      CurrentUserProvider currentUserProvider
  ) {
    this.studentVerificationService = studentVerificationService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping("/verify")
  @Operation(summary = "Verify AUB student", description = "Promotes a valid AUB student account to STUDENT role.")
  public ResponseEntity<ApiResponseWrapper<StudentVerificationResponse>> verify(
      @Valid @RequestBody StudentVerifyRequest request
  ) {
    return ResponseEntity.ok(ApiResponseWrapper.success(
        studentVerificationService.verify(currentUserProvider.requireCurrentUser().userId(), request)
    ));
  }
}
