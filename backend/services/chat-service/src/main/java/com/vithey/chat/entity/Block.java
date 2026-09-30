package com.vithey.chat.entity;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "blocks")
@Getter
@Setter
public class Block {

  @EmbeddedId
  private BlockId id;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;
}
