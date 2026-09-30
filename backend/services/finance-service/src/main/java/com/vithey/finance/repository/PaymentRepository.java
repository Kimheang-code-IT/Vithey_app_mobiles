package com.vithey.finance.repository;

import com.vithey.finance.entity.Payment;
import com.vithey.finance.entity.PaymentStatus;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {

  Page<Payment> findByUserIdOrderByDueDateAscCreatedAtDesc(UUID userId, Pageable pageable);

  boolean existsByUserId(UUID userId);

  @Query("""
      SELECT p FROM Payment p
      WHERE p.status <> com.vithey.finance.entity.PaymentStatus.PAID
        AND p.dueDate IS NOT NULL
        AND p.dueDate < :today
      """)
  List<Payment> findOverdueCandidates(@Param("today") LocalDate today);

  @Query("""
      SELECT p FROM Payment p
      WHERE p.status <> com.vithey.finance.entity.PaymentStatus.PAID
        AND p.dueDate IS NOT NULL
        AND p.dueDate >= :today
        AND p.dueDate <= :dueUntil
      """)
  List<Payment> findDueSoonCandidates(
      @Param("today") LocalDate today,
      @Param("dueUntil") LocalDate dueUntil
  );

  List<Payment> findByUserIdAndStatusNotOrderByDueDateAsc(UUID userId, PaymentStatus status);
}
