package com.vithey.career.service;

import com.vithey.career.client.ContentServiceClient;
import com.vithey.career.client.FileServiceClient;
import com.vithey.career.client.UserProfileClient;
import com.vithey.career.dto.response.ApplicantSummaryResponse;
import com.vithey.career.dto.response.CvPreviewResponse;
import com.vithey.career.dto.response.FileMetadataResponse;
import com.vithey.career.dto.response.JobApplicationResponse;
import com.vithey.career.dto.response.PostSummaryResponse;
import com.vithey.career.entity.JobApplication;
import com.vithey.career.exception.ApiException;
import com.vithey.career.exception.ErrorCode;
import com.vithey.career.mapper.JobApplicationMapper;
import feign.FeignException;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class JobApplicationResponseBuilder {

  private final JobApplicationMapper jobApplicationMapper;
  private final UserProfileClient userProfileClient;
  private final FileServiceClient fileServiceClient;
  private final ContentServiceClient contentServiceClient;

  public JobApplicationResponseBuilder(
      JobApplicationMapper jobApplicationMapper,
      UserProfileClient userProfileClient,
      FileServiceClient fileServiceClient,
      ContentServiceClient contentServiceClient
  ) {
    this.jobApplicationMapper = jobApplicationMapper;
    this.userProfileClient = userProfileClient;
    this.fileServiceClient = fileServiceClient;
    this.contentServiceClient = contentServiceClient;
  }

  public JobApplicationResponse build(JobApplication application) {
    JobApplicationResponse base = jobApplicationMapper.toBaseResponse(application);
    ApplicantSummaryResponse applicant = resolveApplicant(application.getApplicantId());
    String cvFileName = resolveCvFileName(application.getCvFileId());
    PostSummaryResponse post = resolveJobPost(application.getJobPostId());
    String jobTitle = resolveJobTitle(post);
    String organization = resolveOrganization(post);
    return new JobApplicationResponse(
        base.applicationId(),
        base.jobPostId(),
        jobTitle,
        organization,
        applicant,
        base.cvFileId(),
        cvFileName,
        base.status(),
        base.coverNote(),
        base.appliedAt(),
        base.reviewStartedAt(),
        base.decidedAt(),
        base.reviewerNote()
    );
  }

  /**
   * Builds the CV preview payload for an application. Resolves the download URL
   * and file name via file-service. Throws 404 if the CV file is gone.
   */
  public CvPreviewResponse buildCvPreview(JobApplication application) {
    FileMetadataResponse file = requireCvFile(application.getCvFileId());
    return new CvPreviewResponse(
        application.getId(),
        application.getCvFileId(),
        file.fileName(),
        file.url()
    );
  }

  private FileMetadataResponse requireCvFile(UUID cvFileId) {
    try {
      var response = fileServiceClient.getFile(cvFileId);
      if (response != null && response.data() != null) {
        return response.data();
      }
    } catch (FeignException.NotFound exception) {
      throw new ApiException(ErrorCode.NOT_FOUND, "CV file not found");
    }
    throw new ApiException(ErrorCode.NOT_FOUND, "CV file not found");
  }

  private ApplicantSummaryResponse resolveApplicant(UUID applicantId) {
    var response = userProfileClient.getProfile(applicantId);
    if (response.data() == null) {
      return new ApplicantSummaryResponse(applicantId, "Unknown User");
    }
    return new ApplicantSummaryResponse(response.data().userId(), response.data().fullName());
  }

  private String resolveCvFileName(UUID cvFileId) {
    try {
      var response = fileServiceClient.getFile(cvFileId);
      if (response != null && response.data() != null) {
        return response.data().fileName();
      }
    } catch (FeignException exception) {
      return null;
    }
    return null;
  }

  private PostSummaryResponse resolveJobPost(UUID jobPostId) {
    try {
      var response = contentServiceClient.getPost(jobPostId);
      if (response != null && response.data() != null) {
        return response.data();
      }
    } catch (FeignException exception) {
      return null;
    }
    return null;
  }

  private String resolveJobTitle(PostSummaryResponse post) {
    if (post == null) {
      return "Job";
    }
    if (post.jobMeta() != null && post.jobMeta().title() != null && !post.jobMeta().title().isBlank()) {
      return post.jobMeta().title();
    }
    if (post.content() != null && !post.content().isBlank()) {
      return post.content();
    }
    return "Job";
  }

  private String resolveOrganization(PostSummaryResponse post) {
    if (post == null || post.author() == null) {
      return null;
    }
    return post.author().fullName();
  }
}
