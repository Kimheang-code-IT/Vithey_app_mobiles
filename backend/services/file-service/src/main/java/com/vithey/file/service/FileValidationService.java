package com.vithey.file.service;

import com.vithey.file.entity.StoredFileType;
import com.vithey.file.exception.ApiException;
import com.vithey.file.exception.ErrorCode;
import java.util.Map;
import java.util.Set;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
public class FileValidationService {

  private static final Map<StoredFileType, Set<String>> ALLOWED_MIME_TYPES = Map.ofEntries(
      Map.entry(StoredFileType.AVATAR, Set.of("image/jpeg", "image/png", "image/webp")),
      Map.entry(StoredFileType.CV, Set.of(
          "application/pdf",
          "application/msword",
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
          "image/jpeg",
          "image/png"
      )),
      Map.entry(StoredFileType.POSTER, Set.of("image/jpeg", "image/png", "image/webp")),
      Map.entry(StoredFileType.VIDEO, Set.of("video/mp4", "video/quicktime")),
      Map.entry(StoredFileType.CHAT_ATTACHMENT, Set.of(
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/gif",
          "application/pdf",
          "application/msword",
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      ))
  );

  public void validateUpload(StoredFileType fileType, String mimeType, long sizeBytes) {
    if (fileType == null) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "File type is required");
    }
    if (!StringUtils.hasText(mimeType)) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "MIME type is required");
    }
    if (!ALLOWED_MIME_TYPES.getOrDefault(fileType, Set.of()).contains(mimeType)) {
      throw new ApiException(ErrorCode.INVALID_FILE_TYPE);
    }
    if (sizeBytes <= 0) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "File is empty");
    }
    if (sizeBytes > fileType.maxSizeBytes()) {
      throw new ApiException(ErrorCode.FILE_TOO_LARGE);
    }
  }

  public String sanitizeFileName(String originalName) {
    if (!StringUtils.hasText(originalName)) {
      return "upload.bin";
    }
    String baseName = originalName.replace('\\', '/');
    int slash = baseName.lastIndexOf('/');
    if (slash >= 0) {
      baseName = baseName.substring(slash + 1);
    }
    String sanitized = baseName.replaceAll("[^a-zA-Z0-9._-]", "_");
    sanitized = sanitized.replace("..", "_");
    if (!StringUtils.hasText(sanitized) || sanitized.equals(".") || sanitized.equals("_")) {
      return "upload.bin";
    }
    return sanitized.length() > 200 ? sanitized.substring(0, 200) : sanitized;
  }
}
