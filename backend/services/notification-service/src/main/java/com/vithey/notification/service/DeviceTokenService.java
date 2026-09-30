package com.vithey.notification.service;

import com.vithey.notification.dto.request.RegisterDeviceRequest;
import com.vithey.notification.dto.response.DeviceTokenResponse;
import com.vithey.notification.entity.DeviceToken;
import com.vithey.notification.exception.ApiException;
import com.vithey.notification.exception.ErrorCode;
import com.vithey.notification.mapper.NotificationMapper;
import com.vithey.notification.repository.DeviceTokenRepository;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class DeviceTokenService {

  private final DeviceTokenRepository deviceTokenRepository;
  private final NotificationMapper notificationMapper;

  public DeviceTokenService(DeviceTokenRepository deviceTokenRepository, NotificationMapper notificationMapper) {
    this.deviceTokenRepository = deviceTokenRepository;
    this.notificationMapper = notificationMapper;
  }

  @Transactional
  public DeviceTokenResponse registerDevice(UUID userId, RegisterDeviceRequest request) {
    if (!StringUtils.hasText(request.fcmToken())) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "FCM token is required");
    }

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    DeviceToken deviceToken = deviceTokenRepository.findByFcmToken(request.fcmToken()).orElseGet(DeviceToken::new);
    if (deviceToken.getId() == null) {
      deviceToken.setId(UUID.randomUUID());
      deviceToken.setCreatedAt(now);
    }
    deviceToken.setUserId(userId);
    deviceToken.setFcmToken(request.fcmToken());
    deviceToken.setPlatform(request.platform());
    deviceToken.setUpdatedAt(now);
    return notificationMapper.toDeviceResponse(deviceTokenRepository.save(deviceToken));
  }

  @Transactional
  public void removeDevice(UUID userId, String fcmToken) {
    deviceTokenRepository.deleteByFcmTokenAndUserId(fcmToken, userId);
  }

  @Transactional(readOnly = true)
  public List<String> findTokensForUser(UUID userId) {
    return deviceTokenRepository.findByUserId(userId).stream()
        .map(DeviceToken::getFcmToken)
        .toList();
  }
}
