package com.vithey.career.controller;

import com.vithey.career.dto.request.ApplyJobRequest;
import com.vithey.career.dto.request.UpdateApplicationStatusRequest;
import com.vithey.career.dto.response.CvPreviewResponse;
import com.vithey.career.dto.response.JobApplicationResponse;
import com.vithey.career.security.CurrentUserProvider;
import com.vithey.career.service.JobApplicationService;
import com.vithey.career.util.ApiResponseWrapper;
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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/job-applications")
public class JobApplicationController {

  private final JobApplicationService jobApplicationService;
  private final CurrentUserProvider currentUserProvider;

  public JobApplicationController(
      JobApplicationService jobApplicationService,
      CurrentUserProvider currentUserProvider
  ) {
    this.jobApplicationService = jobApplicationService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping
  ResponseEntity<ApiResponseWrapper<JobApplicationResponse>> apply(
      @Valid @RequestBody ApplyJobRequest request,
      @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey
  ) {
    UUID applicantId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(jobApplicationService.apply(applicantId, request, idempotencyKey)));
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<List<JobApplicationResponse>>> listApplications(
      @RequestParam(required = false) UUID jobPostId,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    UUID currentUserId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(jobApplicationService.listApplications(currentUserId, jobPostId, page, limit));
  }

  @GetMapping("/{applicationId}")
  ResponseEntity<ApiResponseWrapper<JobApplicationResponse>> getApplication(
      @PathVariable UUID applicationId
  ) {
    UUID currentUserId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(
        jobApplicationService.getApplication(applicationId, currentUserId)
    ));
  }

  @GetMapping("/{applicationId}/cv-preview")
  ResponseEntity<ApiResponseWrapper<CvPreviewResponse>> getCvPreview(
      @PathVariable UUID applicationId
  ) {
    UUID currentUserId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(
        jobApplicationService.getCvPreview(applicationId, currentUserId)
    ));
  }

  @PatchMapping("/{applicationId}/status")
  ResponseEntity<ApiResponseWrapper<JobApplicationResponse>> updateStatus(
      @PathVariable UUID applicationId,
      @Valid @RequestBody UpdateApplicationStatusRequest request
  ) {
    UUID currentUserId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(
        jobApplicationService.updateStatus(applicationId, currentUserId, request)
    ));
  }
}
