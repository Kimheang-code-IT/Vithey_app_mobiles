package com.vithey.career.service;

import com.vithey.career.client.ContentServiceClient;
import com.vithey.career.client.FileServiceClient;
import com.vithey.career.dto.response.FileMetadataResponse;
import com.vithey.career.dto.response.PostSummaryResponse;
import com.vithey.career.exception.ApiException;
import com.vithey.career.exception.ErrorCode;
import com.vithey.career.util.ApiResponseWrapper;
import feign.FeignException;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class UpstreamValidationService {

  private final ContentServiceClient contentServiceClient;
  private final FileServiceClient fileServiceClient;

  public UpstreamValidationService(
      ContentServiceClient contentServiceClient,
      FileServiceClient fileServiceClient
  ) {
    this.contentServiceClient = contentServiceClient;
    this.fileServiceClient = fileServiceClient;
  }

  public PostSummaryResponse requireJobPost(UUID jobPostId) {
    try {
      ApiResponseWrapper<PostSummaryResponse> response = contentServiceClient.getPost(jobPostId);
      if (response == null || response.data() == null) {
        throw new ApiException(ErrorCode.NOT_FOUND, "Job post not found");
      }
      if (!"JOB".equalsIgnoreCase(response.data().type())) {
        throw new ApiException(ErrorCode.NOT_FOUND, "Job post not found");
      }
      return response.data();
    } catch (FeignException.NotFound exception) {
      throw new ApiException(ErrorCode.NOT_FOUND, "Job post not found");
    } catch (FeignException exception) {
      throw new ApiException(ErrorCode.UPSTREAM_ERROR);
    }
  }

  public void requireJobPoster(UUID jobPostId, UUID userId) {
    if (!isJobPoster(jobPostId, userId)) {
      throw new ApiException(ErrorCode.FORBIDDEN);
    }
  }

  public boolean isJobPoster(UUID jobPostId, UUID userId) {
    PostSummaryResponse post = requireJobPost(jobPostId);
    return post.author() != null && userId.equals(post.author().userId());
  }

  public FileMetadataResponse requireCvFile(UUID cvFileId) {
    try {
      ApiResponseWrapper<FileMetadataResponse> response = fileServiceClient.getFile(cvFileId);
      if (response == null || response.data() == null) {
        throw new ApiException(ErrorCode.INVALID_FILE);
      }
      if (!"CV".equalsIgnoreCase(response.data().fileType())) {
        throw new ApiException(ErrorCode.INVALID_FILE, "File type must be CV");
      }
      return response.data();
    } catch (FeignException.NotFound exception) {
      throw new ApiException(ErrorCode.INVALID_FILE);
    } catch (FeignException exception) {
      throw new ApiException(ErrorCode.UPSTREAM_ERROR);
    }
  }
}
