package com.vithey.notification.dto.response;

import java.util.UUID;

public record DeviceTokenResponse(
    UUID deviceId,
    String fcmToken,
    String platform
) {
}
