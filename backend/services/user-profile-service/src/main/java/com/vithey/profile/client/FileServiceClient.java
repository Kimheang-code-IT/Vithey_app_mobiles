package com.vithey.profile.client;

import com.vithey.profile.dto.response.FileMetadataResponse;
import com.vithey.profile.util.ApiResponseWrapper;
import java.util.UUID;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "file-service")
public interface FileServiceClient {

  @GetMapping("/api/v1/files/{fileId}")
  ApiResponseWrapper<FileMetadataResponse> getFile(@PathVariable("fileId") UUID fileId);
}
