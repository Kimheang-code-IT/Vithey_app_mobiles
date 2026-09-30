package com.vithey.notification.mapper;

import com.vithey.notification.dto.response.DeviceTokenResponse;
import com.vithey.notification.dto.response.NotificationResponse;
import com.vithey.notification.entity.DeviceToken;
import com.vithey.notification.entity.Notification;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface NotificationMapper {

  @Mapping(target = "id", source = "id")
  @Mapping(target = "notificationId", source = "id")
  @Mapping(target = "isRead", source = "read")
  @Mapping(target = "actor", expression = "java(toActor(notification))")
  NotificationResponse toResponse(Notification notification);

  default NotificationResponse.ActorDto toActor(Notification notification) {
    if (notification.getActorId() == null) {
      return null;
    }
    return new NotificationResponse.ActorDto(
        notification.getActorId(),
        notification.getActorName(),
        notification.getActorAvatarUrl()
    );
  }

  @Mapping(target = "deviceId", source = "id")
  @Mapping(target = "platform", expression = "java(deviceToken.getPlatform().name())")
  DeviceTokenResponse toDeviceResponse(DeviceToken deviceToken);
}
