package com.vithey.chat.service;

import com.vithey.chat.client.FileServiceClient;
import com.vithey.chat.dto.response.FileMetadataResponse;
import com.vithey.chat.entity.MessageType;
import com.vithey.chat.exception.ApiException;
import com.vithey.chat.exception.ErrorCode;
import feign.FeignException;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class ChatFileValidationService {

  private static final String CHAT_ATTACHMENT = "CHAT_ATTACHMENT";

  private final FileServiceClient fileServiceClient;

  public ChatFileValidationService(FileServiceClient fileServiceClient) {
    this.fileServiceClient = fileServiceClient;
  }

  public FileMetadataResponse requireOwnedChatFile(UUID fileId, UUID ownerUserId, MessageType messageType) {
    if (fileId == null) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "file_id is required for media messages");
    }
    if (messageType == MessageType.TEXT) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "file_id is only valid for media messages");
    }

    FileMetadataResponse metadata = loadMetadata(fileId);
    if (metadata.ownerUserId() != null && !metadata.ownerUserId().equals(ownerUserId)) {
      throw new ApiException(ErrorCode.FORBIDDEN, "File does not belong to sender");
    }
    if (metadata.type() != null && !CHAT_ATTACHMENT.equals(metadata.type())) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "File must be uploaded as CHAT_ATTACHMENT");
    }
    if (messageType == MessageType.IMAGE && metadata.mimeType() != null && !metadata.mimeType().startsWith("image/")) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "IMAGE messages require an image file");
    }
    return metadata;
  }

  private FileMetadataResponse loadMetadata(UUID fileId) {
    try {
      var response = fileServiceClient.getFile(fileId);
      if (response.data() == null) {
        throw new ApiException(ErrorCode.NOT_FOUND, "File not found");
      }
      return response.data();
    } catch (FeignException.NotFound exception) {
      throw new ApiException(ErrorCode.NOT_FOUND, "File not found");
    } catch (FeignException exception) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "Unable to validate file");
    }
  }
}
