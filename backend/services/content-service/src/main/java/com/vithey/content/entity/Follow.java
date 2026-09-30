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
@Table(name = "follows")
@Getter
@Setter
public class Follow {

  @Id
  private UUID id;

  @Column(name = "follower_id", nullable = false)
  private UUID followerId;

  @Column(name = "following_id", nullable = false)
  private UUID followingId;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;
}
