package com.vithey.profile.dto.response;

import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import java.util.Map;
import java.util.UUID;

public record SettingsResponse(
    UUID userId,
    AppLanguage language,
    AppTheme theme,
    Map<String, Object> notifications,
    Map<String, Object> privacy,
    String fcmToken
) {
}
