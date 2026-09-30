package com.vithey.auth.repository;

import com.vithey.auth.entity.StudentVerification;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentVerificationRepository extends JpaRepository<StudentVerification, UUID> {

  Optional<StudentVerification> findByUserId(UUID userId);
}
