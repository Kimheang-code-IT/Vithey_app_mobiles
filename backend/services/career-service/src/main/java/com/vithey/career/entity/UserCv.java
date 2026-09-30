package com.vithey.career.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "user_cvs")
@Getter
@Setter
public class UserCv {

  @Id
  @Column(name = "user_id")
  private UUID userId;

  @Column(name = "cv_file_id", nullable = false)
  private UUID cvFileId;

  @Column(name = "file_name", nullable = false)
  private String fileName;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;
}
