package com.vithey.profile.service;

import com.vithey.profile.dto.request.UpdateSettingsRequest;
import com.vithey.profile.dto.response.SettingsResponse;
import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import com.vithey.profile.entity.UserSettings;
import com.vithey.profile.exception.ApiException;
import com.vithey.profile.exception.ErrorCode;
import com.vithey.profile.mapper.SettingsMapper;
import com.vithey.profile.repository.UserSettingsRepository;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SettingsService {

  private final UserSettingsRepository userSettingsRepository;
  private final SettingsMapper settingsMapper;

  public SettingsService(UserSettingsRepository userSettingsRepository, SettingsMapper settingsMapper) {
    this.userSettingsRepository = userSettingsRepository;
    this.settingsMapper = settingsMapper;
  }

  @Transactional(readOnly = true)
  public SettingsResponse getSettings(UUID userId) {
    return settingsMapper.toResponse(requireSettings(userId));
  }

  @Transactional
  public SettingsResponse updateSettings(UUID userId, UpdateSettingsRequest request) {
    UserSettings settings = requireSettings(userId);
    boolean changed = false;

    if (request.language() != null && request.language() != settings.getLanguage()) {
      settings.setLanguage(request.language());
      changed = true;
    }
    if (request.theme() != null && request.theme() != settings.getTheme()) {
      settings.setTheme(request.theme());
      changed = true;
    }
    if (request.notifications() != null
        && !Objects.equals(settings.getNotificationPrefs(), request.notifications())) {
      settings.setNotificationPrefs(new HashMap<>(request.notifications()));
      changed = true;
    }
    if (request.privacy() != null
        && !Objects.equals(settings.getPrivacyPrefs(), request.privacy())) {
      settings.setPrivacyPrefs(new HashMap<>(request.privacy()));
      changed = true;
    }
    if (request.fcmToken() != null && !Objects.equals(request.fcmToken(), settings.getFcmToken())) {
      settings.setFcmToken(request.fcmToken());
      changed = true;
    }

    if (!changed) {
      return settingsMapper.toResponse(settings);
    }
    return settingsMapper.toResponse(userSettingsRepository.save(settings));
  }

  @Transactional
  public UserSettings createDefaultSettings(UUID userId) {
    if (userSettingsRepository.existsById(userId)) {
      return requireSettings(userId);
    }

    UserSettings settings = new UserSettings();
    settings.setUserId(userId);
    settings.setLanguage(AppLanguage.en);
    settings.setTheme(AppTheme.system);
    settings.setNotificationPrefs(defaultNotificationPrefs());
    settings.setPrivacyPrefs(defaultPrivacyPrefs());
    return userSettingsRepository.save(settings);
  }

  UserSettings requireSettings(UUID userId) {
    return userSettingsRepository.findById(userId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Settings not found"));
  }

  private Map<String, Object> defaultNotificationPrefs() {
    Map<String, Object> prefs = new HashMap<>();
    prefs.put("likes", true);
    prefs.put("comments", true);
    prefs.put("chat", true);
    prefs.put("payments", true);
    return prefs;
  }

  private Map<String, Object> defaultPrivacyPrefs() {
    Map<String, Object> prefs = new HashMap<>();
    prefs.put("profile_visible", true);
    prefs.put("show_activity", true);
    return prefs;
  }
}
