package com.vithey.career.service;

import com.vithey.career.dto.request.ApplyJobRequest;
import com.vithey.career.dto.request.UpdateApplicationStatusRequest;
import com.vithey.career.dto.response.CvPreviewResponse;
import com.vithey.career.dto.response.JobApplicationResponse;
import com.vithey.career.entity.ApplicationStatus;
import com.vithey.career.entity.JobApplication;
import com.vithey.career.event.payload.JobApplicationStatusChangedEvent;
import com.vithey.career.event.payload.JobApplicationSubmittedEvent;
import com.vithey.career.event.publisher.JobApplicationEventPublisher;
import com.vithey.career.exception.ApiException;
import com.vithey.career.exception.ErrorCode;
import com.vithey.career.repository.JobApplicationRepository;
import com.vithey.career.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class JobApplicationService {

  private static final int MAX_LIMIT = 50;

  private final JobApplicationRepository jobApplicationRepository;
  private final UpstreamValidationService upstreamValidationService;
  private final JobApplicationResponseBuilder responseBuilder;
  private final JobApplicationEventPublisher eventPublisher;

  public JobApplicationService(
      JobApplicationRepository jobApplicationRepository,
      UpstreamValidationService upstreamValidationService,
      JobApplicationResponseBuilder responseBuilder,
      JobApplicationEventPublisher eventPublisher
  ) {
    this.jobApplicationRepository = jobApplicationRepository;
    this.upstreamValidationService = upstreamValidationService;
    this.responseBuilder = responseBuilder;
    this.eventPublisher = eventPublisher;
  }

  @Transactional
  public JobApplicationResponse apply(UUID applicantId, ApplyJobRequest request, String idempotencyKey) {
    if (StringUtils.hasText(idempotencyKey)) {
      Optional<JobApplication> existingByKey = jobApplicationRepository
          .findByApplicantIdAndIdempotencyKey(applicantId, idempotencyKey.trim());
      if (existingByKey.isPresent()) {
        return responseBuilder.build(existingByKey.get());
      }
    }

    upstreamValidationService.requireJobPost(request.jobPostId());
    upstreamValidationService.requireCvFile(request.cvFileId());

    if (jobApplicationRepository.existsByJobPostIdAndApplicantId(request.jobPostId(), applicantId)) {
      throw new ApiException(ErrorCode.CONFLICT, "You have already applied to this job");
    }

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    JobApplication application = new JobApplication();
    application.setId(UUID.randomUUID());
    application.setJobPostId(request.jobPostId());
    application.setApplicantId(applicantId);
    application.setCvFileId(request.cvFileId());
    application.setCoverNote(request.coverNote());
    application.setStatus(ApplicationStatus.PENDING);
    application.setAppliedAt(now);
    application.setUpdatedAt(now);
    if (StringUtils.hasText(idempotencyKey)) {
      application.setIdempotencyKey(idempotencyKey.trim());
    }

    JobApplication saved = jobApplicationRepository.save(application);
    eventPublisher.publishSubmitted(new JobApplicationSubmittedEvent(
        saved.getId(),
        saved.getJobPostId(),
        saved.getApplicantId(),
        saved.getCvFileId(),
        saved.getStatus(),
        saved.getAppliedAt()
    ));
    return responseBuilder.build(saved);
  }

  public ApiResponseWrapper<List<JobApplicationResponse>> listApplications(
      UUID currentUserId,
      UUID jobPostId,
      int page,
      int limit
  ) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<JobApplication> applications = resolveApplicationsPage(currentUserId, jobPostId, pageable);

    List<JobApplicationResponse> content = applications.getContent().stream()
        .map(responseBuilder::build)
        .toList();

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, applications.getTotalElements(), applications.getTotalPages())
    );
  }

  @Transactional(readOnly = true)
  public JobApplicationResponse getApplication(UUID applicationId, UUID currentUserId) {
    JobApplication application = requireApplication(applicationId);
    assertCanView(application, currentUserId);
    return responseBuilder.build(application);
  }

  @Transactional(readOnly = true)
  public CvPreviewResponse getCvPreview(UUID applicationId, UUID currentUserId) {
    JobApplication application = requireApplication(applicationId);
    assertCanView(application, currentUserId);
    return responseBuilder.buildCvPreview(application);
  }

  @Transactional
  public JobApplicationResponse updateStatus(
      UUID applicationId,
      UUID currentUserId,
      UpdateApplicationStatusRequest request
  ) {
    JobApplication application = requireApplication(applicationId);
    upstreamValidationService.requireJobPoster(application.getJobPostId(), currentUserId);

    ApplicationStatus previousStatus = application.getStatus();
    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    ApplicationStatus nextStatus = request.status();

    if (nextStatus == ApplicationStatus.REVIEWED && application.getReviewStartedAt() == null) {
      application.setReviewStartedAt(now);
    }
    if ((nextStatus == ApplicationStatus.ACCEPTED || nextStatus == ApplicationStatus.REJECTED)
        && application.getDecidedAt() == null) {
      application.setDecidedAt(now);
    }
    if (StringUtils.hasText(request.reviewerNote())) {
      application.setReviewerNote(request.reviewerNote().trim());
    }

    application.setStatus(nextStatus);
    application.setUpdatedAt(now);
    JobApplication saved = jobApplicationRepository.save(application);

    eventPublisher.publishStatusChanged(new JobApplicationStatusChangedEvent(
        saved.getId(),
        saved.getJobPostId(),
        saved.getApplicantId(),
        previousStatus,
        saved.getStatus(),
        currentUserId,
        saved.getUpdatedAt()
    ));
    return responseBuilder.build(saved);
  }

  private Page<JobApplication> resolveApplicationsPage(
      UUID currentUserId,
      UUID jobPostId,
      PageRequest pageable
  ) {
    if (jobPostId == null) {
      return jobApplicationRepository.findByApplicantIdOrderByAppliedAtDesc(currentUserId, pageable);
    }
    if (upstreamValidationService.isJobPoster(jobPostId, currentUserId)) {
      return jobApplicationRepository.findByJobPostIdOrderByAppliedAtDesc(jobPostId, pageable);
    }
    return jobApplicationRepository.findByJobPostIdAndApplicantIdOrderByAppliedAtDesc(
        jobPostId,
        currentUserId,
        pageable
    );
  }

  private JobApplication requireApplication(UUID applicationId) {
    return jobApplicationRepository.findById(applicationId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
  }

  private void assertCanView(JobApplication application, UUID currentUserId) {
    if (application.getApplicantId().equals(currentUserId)) {
      return;
    }
    try {
      upstreamValidationService.requireJobPoster(application.getJobPostId(), currentUserId);
    } catch (ApiException exception) {
      if (exception.getErrorCode() == ErrorCode.FORBIDDEN) {
        throw new ApiException(ErrorCode.FORBIDDEN);
      }
      throw exception;
    }
  }
}
