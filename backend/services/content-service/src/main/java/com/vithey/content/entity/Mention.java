package com.vithey.content.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "mentions")
@Getter
@Setter
public class Mention {

  @Id
  private UUID id;

  @Column(name = "comment_id", nullable = false)
  private UUID commentId;

  @Column(name = "mentioned_user_id", nullable = false)
  private UUID mentionedUserId;
}
