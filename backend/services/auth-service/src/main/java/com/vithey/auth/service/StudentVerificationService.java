package com.vithey.auth.service;

import com.vithey.auth.dto.request.StudentVerifyRequest;
import com.vithey.auth.dto.response.StudentVerificationResponse;
import com.vithey.auth.entity.Role;
import com.vithey.auth.entity.StudentVerification;
import com.vithey.auth.entity.StudentVerificationStatus;
import com.vithey.auth.entity.User;
import com.vithey.auth.event.payload.StudentVerifiedEvent;
import com.vithey.auth.event.publisher.StudentVerifiedEventPublisher;
import com.vithey.auth.exception.ApiException;
import com.vithey.auth.exception.ErrorCode;
import com.vithey.auth.repository.StudentVerificationRepository;
import com.vithey.auth.repository.UserRepository;
import java.time.OffsetDateTime;
import java.util.Locale;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StudentVerificationService {

  private static final String AUB_EMAIL_DOMAIN = "@aub.edu.kh";

  private final UserRepository userRepository;
  private final StudentVerificationRepository studentVerificationRepository;
  private final StudentVerifiedEventPublisher studentVerifiedEventPublisher;

  public StudentVerificationService(
      UserRepository userRepository,
      StudentVerificationRepository studentVerificationRepository,
      StudentVerifiedEventPublisher studentVerifiedEventPublisher
  ) {
    this.userRepository = userRepository;
    this.studentVerificationRepository = studentVerificationRepository;
    this.studentVerifiedEventPublisher = studentVerifiedEventPublisher;
  }

  @Transactional
  public StudentVerificationResponse verify(UUID userId, StudentVerifyRequest request) {
    String universityEmail = request.universityEmail().trim().toLowerCase(Locale.ROOT);
    if (!universityEmail.endsWith(AUB_EMAIL_DOMAIN)) {
      throw new ApiException(ErrorCode.BUSINESS_RULE_VIOLATION, "University email must use the AUB domain");
    }

    User user = userRepository.findById(userId)
        .filter(candidate -> candidate.getDeletedAt() == null && candidate.isActive())
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "User not found"));

    OffsetDateTime now = OffsetDateTime.now();
    StudentVerification verification = studentVerificationRepository.findByUserId(userId)
        .orElseGet(StudentVerification::new);
    verification.setUser(user);
    verification.setStudentId(request.studentId());
    verification.setUniversityEmail(universityEmail);
    verification.setStatus(StudentVerificationStatus.VERIFIED);
    verification.setVerifiedAt(now);

    user.setRole(Role.STUDENT);
    user.setStudentVerified(true);
    userRepository.save(user);
    StudentVerification savedVerification = studentVerificationRepository.save(verification);

    studentVerifiedEventPublisher.publish(new StudentVerifiedEvent(user.getId(), savedVerification.getStudentId(), now));

    return new StudentVerificationResponse(
        user.getId(),
        savedVerification.getStudentId(),
        savedVerification.getUniversityEmail(),
        user.getRole(),
        user.isStudentVerified(),
        savedVerification.getStatus(),
        savedVerification.getVerifiedAt()
    );
  }
}
