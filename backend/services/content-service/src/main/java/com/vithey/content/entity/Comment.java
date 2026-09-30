package com.vithey.content.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "comments")
@Getter
@Setter
public class Comment {

  @Id
  private UUID id;

  @Column(name = "post_id", nullable = false)
  private UUID postId;

  @Column(name = "author_id", nullable = false)
  private UUID authorId;

  @Column(nullable = false, columnDefinition = "TEXT")
  private String text;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;
}
