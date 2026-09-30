package com.vithey.file.service;

import com.vithey.file.dto.response.FileMetadataResponse;
import com.vithey.file.dto.response.FileUploadResponse;
import com.vithey.file.entity.FileMetadata;
import com.vithey.file.entity.StoredFileType;
import com.vithey.file.mapper.FileMapper;
import java.io.InputStream;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class FileMetadataService {

  private final FileStorageService fileStorageService;
  private final FileMapper fileMapper;

  public FileMetadataService(FileStorageService fileStorageService, FileMapper fileMapper) {
    this.fileStorageService = fileStorageService;
    this.fileMapper = fileMapper;
  }

  public FileUploadResponse upload(MultipartFile file, StoredFileType fileType, UUID ownerUserId) {
    FileMetadata metadata = fileStorageService.upload(file, fileType, ownerUserId);
    String url = fileStorageService.createPresignedUrl(metadata);
    return fileMapper.toUploadResponse(metadata, url);
  }

  public FileMetadataResponse getMetadata(UUID fileId) {
    FileMetadata metadata = fileStorageService.requireActiveMetadata(fileId);
    String url = fileStorageService.createPresignedUrl(metadata);
    return fileMapper.toMetadataResponse(metadata, url);
  }

  public DownloadPayload download(UUID fileId, UUID requesterUserId) {
    FileMetadata metadata = fileStorageService.requireActiveMetadata(fileId);
    if (metadata.getFileType() == StoredFileType.CV && !metadata.getOwnerUserId().equals(requesterUserId)) {
      throw new com.vithey.file.exception.ApiException(com.vithey.file.exception.ErrorCode.FORBIDDEN);
    }
    InputStream inputStream = fileStorageService.openDownloadStream(metadata);
    return new DownloadPayload(metadata.getFileName(), metadata.getMimeType(), metadata.getSizeBytes(), inputStream);
  }

  public void delete(UUID fileId, UUID ownerUserId) {
    fileStorageService.deleteOwnedFile(fileId, ownerUserId);
  }

  public record DownloadPayload(String fileName, String mimeType, long sizeBytes, InputStream inputStream) {
  }
}
