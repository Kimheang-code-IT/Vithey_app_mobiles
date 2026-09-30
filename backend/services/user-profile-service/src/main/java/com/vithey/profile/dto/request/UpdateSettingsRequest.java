package com.vithey.profile.dto.request;

import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Size;
import java.util.Map;

@Schema(name = "UpdateSettingsRequest", example = """
    {
      "language": "km",
      "theme": "dark",
      "notifications": {
        "likes": true,
        "comments": true,
        "chat": true,
        "payments": true
      },
      "privacy": {
        "profile_visible": true,
        "show_activity": true
      },
      "fcm_token": "optional-device-token"
    }
    """)
public record UpdateSettingsRequest(
    @Schema(example = "km", allowableValues = {"km", "en"}) AppLanguage language,
    @Schema(example = "dark", allowableValues = {"light", "dark", "system"}) AppTheme theme,
    @Schema(example = "{\"likes\":true,\"comments\":true,\"chat\":true,\"payments\":true}")
    Map<String, Object> notifications,
    @Schema(example = "{\"profile_visible\":true,\"show_activity\":true}")
    Map<String, Object> privacy,
    @Schema(example = "optional-device-token", maxLength = 512) @Size(max = 512) String fcmToken
) {
}
