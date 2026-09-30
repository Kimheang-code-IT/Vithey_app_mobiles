package com.vithey.file.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "file_metadata")
@Getter
@Setter
public class FileMetadata {

  @Id
  private UUID id;

  @Column(name = "owner_user_id", nullable = false)
  private UUID ownerUserId;

  @Column(name = "file_name", nullable = false)
  private String fileName;

  @Enumerated(EnumType.STRING)
  @Column(name = "file_type", nullable = false, length = 32)
  private StoredFileType fileType;

  @Column(name = "mime_type", nullable = false, length = 160)
  private String mimeType;

  @Column(name = "size_bytes", nullable = false)
  private long sizeBytes;

  @Column(name = "bucket", nullable = false, length = 64)
  private String bucket;

  @Column(name = "object_key", nullable = false, unique = true)
  private String objectKey;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "deleted_at")
  private OffsetDateTime deletedAt;

  @PrePersist
  void onCreate() {
    if (createdAt == null) {
      createdAt = OffsetDateTime.now();
    }
  }

  public boolean isDeleted() {
    return deletedAt != null;
  }
}
