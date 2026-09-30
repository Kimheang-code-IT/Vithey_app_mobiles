package com.vithey.chat.client;

import com.vithey.chat.dto.response.ProfileResponse;
import com.vithey.chat.util.ApiResponseWrapper;
import java.util.UUID;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "user-profile-service")
public interface UserProfileClient {

  @GetMapping("/api/v1/users/{userId}")
  ApiResponseWrapper<ProfileResponse> getProfile(@PathVariable("userId") UUID userId);
}
