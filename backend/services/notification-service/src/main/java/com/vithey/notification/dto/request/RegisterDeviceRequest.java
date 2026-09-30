package com.vithey.notification.dto.request;

import com.vithey.notification.entity.DevicePlatform;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record RegisterDeviceRequest(
    @NotBlank String fcmToken,
    @NotNull DevicePlatform platform
) {
}
