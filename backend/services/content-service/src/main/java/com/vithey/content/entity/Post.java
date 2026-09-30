package com.vithey.content.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "posts")
@Getter
@Setter
public class Post {

  @Id
  private UUID id;

  @Column(name = "author_id", nullable = false)
  private UUID authorId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 32)
  private PostType type;

  @Column(columnDefinition = "TEXT")
  private String content;

  @Column(name = "media_file_id")
  private UUID mediaFileId;

  @Column(name = "job_title", length = 180)
  private String jobTitle;

  @Column(name = "job_description", columnDefinition = "TEXT")
  private String jobDescription;

  @Column(name = "job_requirement", columnDefinition = "TEXT")
  private String jobRequirement;

  @Column(name = "job_deadline")
  private LocalDate jobDeadline;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @Column(name = "deleted_at")
  private OffsetDateTime deletedAt;
}
