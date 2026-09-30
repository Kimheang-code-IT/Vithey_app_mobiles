package com.vithey.chat.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "user_reports")
@Getter
@Setter
public class UserReport {

  @Id
  private UUID id;

  @Column(name = "reporter_id", nullable = false)
  private UUID reporterId;

  @Column(name = "reported_id", nullable = false)
  private UUID reportedId;

  @Column(nullable = false, columnDefinition = "TEXT")
  private String reason;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;
}
