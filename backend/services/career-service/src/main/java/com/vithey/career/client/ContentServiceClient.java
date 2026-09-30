package com.vithey.career.client;

import com.vithey.career.dto.response.PostSummaryResponse;
import com.vithey.career.util.ApiResponseWrapper;
import java.util.UUID;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "content-service")
public interface ContentServiceClient {

  @GetMapping("/api/v1/posts/{postId}")
  ApiResponseWrapper<PostSummaryResponse> getPost(@PathVariable("postId") UUID postId);
}
