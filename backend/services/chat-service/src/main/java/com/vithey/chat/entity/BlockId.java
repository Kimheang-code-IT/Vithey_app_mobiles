package com.vithey.chat.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.UUID;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

@Embeddable
@Getter
@Setter
@EqualsAndHashCode
public class BlockId implements Serializable {

  @Column(name = "blocker_id")
  private UUID blockerId;

  @Column(name = "blocked_id")
  private UUID blockedId;
}
