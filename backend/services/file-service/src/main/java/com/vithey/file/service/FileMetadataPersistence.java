package com.vithey.file.service;

import com.vithey.file.entity.FileMetadata;
import com.vithey.file.entity.StoredFileType;
import com.vithey.file.exception.ApiException;
import com.vithey.file.exception.ErrorCode;
import com.vithey.file.repository.FileMetadataRepository;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FileMetadataPersistence {

  private final FileMetadataRepository fileMetadataRepository;

  public FileMetadataPersistence(FileMetadataRepository fileMetadataRepository) {
    this.fileMetadataRepository = fileMetadataRepository;
  }

  @Transactional(readOnly = true)
  public FileMetadata requireActiveMetadata(UUID fileId) {
    return fileMetadataRepository.findByIdAndDeletedAtIsNull(fileId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
  }

  @Transactional
  public FileMetadata saveNew(
      UUID fileId,
      UUID ownerUserId,
      String safeFileName,
      StoredFileType fileType,
      String mimeType,
      long sizeBytes,
      String objectKey
  ) {
    FileMetadata metadata = new FileMetadata();
    metadata.setId(fileId);
    metadata.setOwnerUserId(ownerUserId);
    metadata.setFileName(safeFileName);
    metadata.setFileType(fileType);
    metadata.setMimeType(mimeType);
    metadata.setSizeBytes(sizeBytes);
    metadata.setBucket(fileType.bucket());
    metadata.setObjectKey(objectKey);
    return fileMetadataRepository.save(metadata);
  }

  @Transactional
  public FileMetadata softDeleteOwned(UUID fileId, UUID ownerUserId) {
    FileMetadata metadata = requireActiveMetadata(fileId);
    if (!metadata.getOwnerUserId().equals(ownerUserId)) {
      throw new ApiException(ErrorCode.FORBIDDEN);
    }
    metadata.setDeletedAt(OffsetDateTime.now());
    return fileMetadataRepository.save(metadata);
  }
}
