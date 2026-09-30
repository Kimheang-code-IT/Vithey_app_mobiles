package com.vithey.chat.service;

import com.vithey.chat.dto.request.ReportUserRequest;
import com.vithey.chat.dto.response.ReportResponse;
import com.vithey.chat.entity.UserReport;
import com.vithey.chat.exception.ApiException;
import com.vithey.chat.exception.ErrorCode;
import com.vithey.chat.mapper.ChatMapper;
import com.vithey.chat.repository.UserReportRepository;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReportService {

  private final UserReportRepository userReportRepository;
  private final ChatMapper chatMapper;

  public ReportService(UserReportRepository userReportRepository, ChatMapper chatMapper) {
    this.userReportRepository = userReportRepository;
    this.chatMapper = chatMapper;
  }

  @Transactional
  public ReportResponse reportUser(UUID reporterId, UUID reportedId, ReportUserRequest request) {
    if (reporterId.equals(reportedId)) {
      throw new ApiException(ErrorCode.BUSINESS_RULE_VIOLATION, "You cannot report yourself");
    }

    UserReport report = new UserReport();
    report.setId(UUID.randomUUID());
    report.setReporterId(reporterId);
    report.setReportedId(reportedId);
    report.setReason(request.reason());
    report.setCreatedAt(OffsetDateTime.now(ZoneOffset.UTC));
    return chatMapper.toReportResponse(userReportRepository.save(report));
  }
}
