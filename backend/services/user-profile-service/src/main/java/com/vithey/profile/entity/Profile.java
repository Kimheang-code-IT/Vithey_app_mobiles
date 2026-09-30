package com.vithey.profile.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "profiles")
@Getter
@Setter
public class Profile {

  @Id
  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Column(name = "full_name", nullable = false, length = 160)
  private String fullName;

  @Column(name = "bio")
  private String bio;

  @Column(name = "avatar_file_id")
  private UUID avatarFileId;

  @Column(name = "avatar_url")
  private String avatarUrl;

  @Column(name = "telegram_link")
  private String telegramLink;

  @Column(name = "facebook_link")
  private String facebookLink;

  @Column(name = "university", length = 160)
  private String university;

  @Column(name = "major", length = 160)
  private String major;

  @Column(name = "graduation_year")
  private Integer graduationYear;

  @Column(name = "location", length = 160)
  private String location;

  @Column(name = "date_of_birth")
  private LocalDate dateOfBirth;

  @Column(name = "workplace", length = 160)
  private String workplace;

  @Column(name = "portfolio_url")
  private String portfolioUrl;

  @Column(name = "phone", length = 32)
  private String phone;

  @Column(name = "email", length = 160)
  private String email;

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(name = "skills", nullable = false, columnDefinition = "jsonb")
  private List<ProfileSkillEntry> skills = new ArrayList<>();

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(name = "education", nullable = false, columnDefinition = "jsonb")
  private List<String> education = new ArrayList<>();

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(name = "field_visibility", nullable = false, columnDefinition = "jsonb")
  private Map<String, String> fieldVisibility = new HashMap<>();

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @PrePersist
  void onCreate() {
    OffsetDateTime now = OffsetDateTime.now();
    createdAt = now;
    updatedAt = now;
    if (skills == null) {
      skills = new ArrayList<>();
    }
    if (education == null) {
      education = new ArrayList<>();
    }
    if (fieldVisibility == null) {
      fieldVisibility = new HashMap<>();
    }
  }

  @PreUpdate
  void onUpdate() {
    updatedAt = OffsetDateTime.now();
  }
}
