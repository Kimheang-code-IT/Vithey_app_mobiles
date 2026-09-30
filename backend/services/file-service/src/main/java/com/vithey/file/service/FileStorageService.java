package com.vithey.file.service;

import com.vithey.file.entity.FileMetadata;
import com.vithey.file.entity.StoredFileType;
import com.vithey.file.exception.ApiException;
import com.vithey.file.exception.ErrorCode;
import io.minio.GetObjectArgs;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import io.minio.http.Method;
import java.io.InputStream;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class FileStorageService {

  private static final Logger log = LoggerFactory.getLogger(FileStorageService.class);

  private final MinioClient minioStorageClient;
  private final MinioClient minioPresignClient;
  private final FileMetadataPersistence fileMetadataPersistence;
  private final FileValidationService fileValidationService;

  public FileStorageService(
      @Qualifier("minioStorageClient") MinioClient minioStorageClient,
      @Qualifier("minioPresignClient") MinioClient minioPresignClient,
      FileMetadataPersistence fileMetadataPersistence,
      FileValidationService fileValidationService
  ) {
    this.minioStorageClient = minioStorageClient;
    this.minioPresignClient = minioPresignClient;
    this.fileMetadataPersistence = fileMetadataPersistence;
    this.fileValidationService = fileValidationService;
  }

  public FileMetadata upload(MultipartFile file, StoredFileType fileType, UUID ownerUserId) {
    if (file == null || file.isEmpty()) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "File is required");
    }

    String mimeType = file.getContentType();
    long sizeBytes = file.getSize();
    fileValidationService.validateUpload(fileType, mimeType, sizeBytes);

    UUID fileId = UUID.randomUUID();
    String safeFileName = fileValidationService.sanitizeFileName(file.getOriginalFilename());
    String objectKey = ownerUserId + "/" + fileId + "/" + safeFileName;

    try (InputStream inputStream = file.getInputStream()) {
      minioStorageClient.putObject(
          PutObjectArgs.builder()
              .bucket(fileType.bucket())
              .object(objectKey)
              .stream(inputStream, sizeBytes, -1)
              .contentType(mimeType)
              .build()
      );
    } catch (Exception exception) {
      throw new ApiException(ErrorCode.INTERNAL_ERROR, "Unable to upload file");
    }

    try {
      return fileMetadataPersistence.saveNew(
          fileId,
          ownerUserId,
          safeFileName,
          fileType,
          mimeType,
          sizeBytes,
          objectKey
      );
    } catch (RuntimeException exception) {
      deleteObjectQuietly(fileType.bucket(), objectKey);
      throw exception;
    }
  }

  public FileMetadata requireActiveMetadata(UUID fileId) {
    return fileMetadataPersistence.requireActiveMetadata(fileId);
  }

  public String createPresignedUrl(FileMetadata metadata) {
    try {
      return minioPresignClient.getPresignedObjectUrl(
          GetPresignedObjectUrlArgs.builder()
              .method(Method.GET)
              .bucket(metadata.getBucket())
              .object(metadata.getObjectKey())
              .expiry(1, TimeUnit.HOURS)
              .build()
      );
    } catch (Exception exception) {
      log.error("Failed to create MinIO presigned URL for object {}", metadata.getObjectKey(), exception);
      throw new ApiException(ErrorCode.INTERNAL_ERROR, "Unable to create file URL");
    }
  }

  public InputStream openDownloadStream(FileMetadata metadata) {
    try {
      return minioStorageClient.getObject(
          GetObjectArgs.builder()
              .bucket(metadata.getBucket())
              .object(metadata.getObjectKey())
              .build()
      );
    } catch (Exception exception) {
      throw new ApiException(ErrorCode.NOT_FOUND, "File not found in storage");
    }
  }

  public void deleteOwnedFile(UUID fileId, UUID ownerUserId) {
    FileMetadata metadata = fileMetadataPersistence.softDeleteOwned(fileId, ownerUserId);
    try {
      minioStorageClient.removeObject(
          RemoveObjectArgs.builder()
              .bucket(metadata.getBucket())
              .object(metadata.getObjectKey())
              .build()
      );
    } catch (Exception exception) {
      throw new ApiException(ErrorCode.INTERNAL_ERROR, "Unable to delete file from storage");
    }
  }

  private void deleteObjectQuietly(String bucket, String objectKey) {
    try {
      minioStorageClient.removeObject(
          RemoveObjectArgs.builder()
              .bucket(bucket)
              .object(objectKey)
              .build()
      );
    } catch (Exception ignored) {
      // Best-effort cleanup of orphaned MinIO object after metadata save failure.
    }
  }
}
