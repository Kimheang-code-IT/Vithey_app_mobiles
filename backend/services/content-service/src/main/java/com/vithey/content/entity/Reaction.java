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
@Table(name = "reactions")
@Getter
@Setter
public class Reaction {

  @Id
  private UUID id;

  @Column(name = "post_id", nullable = false)
  private UUID postId;

  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;
}
