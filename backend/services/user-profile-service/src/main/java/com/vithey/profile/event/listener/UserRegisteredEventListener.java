package com.vithey.profile.event.listener;

import com.vithey.profile.config.RabbitMqConfig;
import com.vithey.profile.event.payload.UserRegisteredEvent;
import com.vithey.profile.service.ProfileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class UserRegisteredEventListener {

  private static final Logger log = LoggerFactory.getLogger(UserRegisteredEventListener.class);

  private final ProfileService profileService;

  public UserRegisteredEventListener(ProfileService profileService) {
    this.profileService = profileService;
  }

  @RabbitListener(queues = RabbitMqConfig.USER_REGISTERED_QUEUE)
  public void handleUserRegistered(UserRegisteredEvent event) {
    log.info("Creating profile for registered user {}", event.userId());
    profileService.createFromRegistration(event);
  }
}
