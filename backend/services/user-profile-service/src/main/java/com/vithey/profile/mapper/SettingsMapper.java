package com.vithey.profile.mapper;

import com.vithey.profile.dto.response.SettingsResponse;
import com.vithey.profile.entity.UserSettings;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface SettingsMapper {

  @Mapping(target = "notifications", source = "notificationPrefs")
  @Mapping(target = "privacy", source = "privacyPrefs")
  SettingsResponse toResponse(UserSettings settings);
}
