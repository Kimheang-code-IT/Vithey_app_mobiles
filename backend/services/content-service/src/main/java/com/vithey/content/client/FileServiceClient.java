package com.vithey.content.client;

import com.vithey.content.dto.response.FileMetadataResponse;
import com.vithey.content.util.ApiResponseWrapper;
import java.util.UUID;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "file-service")
public interface FileServiceClient {

  @GetMapping("/api/v1/files/{fileId}")
  ApiResponseWrapper<FileMetadataResponse> getFile(@PathVariable("fileId") UUID fileId);
}
