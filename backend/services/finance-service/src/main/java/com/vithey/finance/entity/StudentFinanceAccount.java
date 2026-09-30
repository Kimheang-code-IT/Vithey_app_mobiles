package com.vithey.finance.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "student_finance_accounts")
@Getter
@Setter
public class StudentFinanceAccount {

  @Id
  @Column(name = "user_id")
  private UUID userId;

  @Column(name = "student_id", nullable = false, length = 64)
  private String studentId;

  @Column(name = "linked_at", nullable = false)
  private OffsetDateTime linkedAt;
}
