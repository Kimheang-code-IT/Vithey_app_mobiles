package com.vithey.profile.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "user_settings")
@Getter
@Setter
public class UserSettings {

  @Id
  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Enumerated(EnumType.STRING)
  @Column(name = "language", nullable = false, length = 8)
  private AppLanguage language = AppLanguage.en;

  @Enumerated(EnumType.STRING)
  @Column(name = "theme", nullable = false, length = 16)
  private AppTheme theme = AppTheme.system;

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(name = "notification_prefs", nullable = false, columnDefinition = "jsonb")
  private Map<String, Object> notificationPrefs = new HashMap<>();

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(name = "privacy_prefs", nullable = false, columnDefinition = "jsonb")
  private Map<String, Object> privacyPrefs = new HashMap<>();

  @Column(name = "fcm_token")
  private String fcmToken;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @PrePersist
  void onCreate() {
    updatedAt = OffsetDateTime.now();
  }

  @PreUpdate
  void onUpdate() {
    updatedAt = OffsetDateTime.now();
  }
}
