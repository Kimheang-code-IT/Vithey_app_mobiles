package com.vithey.notification.repository;

import com.vithey.notification.entity.DeviceToken;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeviceTokenRepository extends JpaRepository<DeviceToken, UUID> {

  Optional<DeviceToken> findByFcmToken(String fcmToken);

  List<DeviceToken> findByUserId(UUID userId);

  void deleteByFcmTokenAndUserId(String fcmToken, UUID userId);
}
