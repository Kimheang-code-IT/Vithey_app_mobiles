package com.vithey.notification.client;

import com.vithey.notification.dto.response.PostSummaryResponse;
import com.vithey.notification.util.ApiResponseWrapper;
import java.util.UUID;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "content-service")
public interface ContentServiceClient {

  @GetMapping("/api/v1/posts/{postId}")
  ApiResponseWrapper<PostSummaryResponse> getPost(@PathVariable("postId") UUID postId);
}
