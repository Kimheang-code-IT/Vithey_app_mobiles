package com.vithey.career.service;

import com.vithey.career.dto.request.SetCvRequest;
import com.vithey.career.dto.response.FileMetadataResponse;
import com.vithey.career.dto.response.UserCvResponse;
import com.vithey.career.entity.UserCv;
import com.vithey.career.exception.ApiException;
import com.vithey.career.exception.ErrorCode;
import com.vithey.career.mapper.JobApplicationMapper;
import com.vithey.career.repository.UserCvRepository;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserCvService {

  private final UserCvRepository userCvRepository;
  private final JobApplicationMapper jobApplicationMapper;
  private final UpstreamValidationService upstreamValidationService;

  public UserCvService(
      UserCvRepository userCvRepository,
      JobApplicationMapper jobApplicationMapper,
      UpstreamValidationService upstreamValidationService
  ) {
    this.userCvRepository = userCvRepository;
    this.jobApplicationMapper = jobApplicationMapper;
    this.upstreamValidationService = upstreamValidationService;
  }

  @Transactional(readOnly = true)
  public UserCvResponse getUserCv(UUID userId) {
    return userCvRepository.findById(userId)
        .map(jobApplicationMapper::toResponse)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Saved CV not found"));
  }

  @Transactional
  public UserCvResponse setUserCv(UUID userId, SetCvRequest request) {
    FileMetadataResponse file = upstreamValidationService.requireCvFile(request.cvFileId());
    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);

    UserCv userCv = userCvRepository.findById(userId).orElseGet(UserCv::new);
    userCv.setUserId(userId);
    userCv.setCvFileId(file.fileId());
    userCv.setFileName(file.fileName());
    userCv.setUpdatedAt(now);

    return jobApplicationMapper.toResponse(userCvRepository.save(userCv));
  }
}
