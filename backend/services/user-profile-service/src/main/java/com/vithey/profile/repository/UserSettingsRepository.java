package com.vithey.profile.repository;

import com.vithey.profile.entity.UserSettings;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserSettingsRepository extends JpaRepository<UserSettings, UUID> {

  @Query("""
      SELECT settings.language AS language, settings.theme AS theme
      FROM UserSettings settings
      WHERE settings.userId = :userId
      """)
  Optional<LanguageThemeProjection> findLanguageThemeByUserId(@Param("userId") UUID userId);
}
