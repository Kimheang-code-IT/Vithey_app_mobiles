package com.vithey.file.mapper;

import com.vithey.file.dto.response.FileMetadataResponse;
import com.vithey.file.dto.response.FileUploadResponse;
import com.vithey.file.entity.FileMetadata;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface FileMapper {

  @Mapping(target = "fileId", source = "metadata.id")
  @Mapping(target = "fileName", source = "metadata.fileName")
  @Mapping(target = "fileType", source = "metadata.fileType")
  @Mapping(target = "mimeType", source = "metadata.mimeType")
  @Mapping(target = "sizeBytes", source = "metadata.sizeBytes")
  @Mapping(target = "createdAt", source = "metadata.createdAt")
  @Mapping(target = "url", source = "accessUrl")
  FileMetadataResponse toMetadataResponse(FileMetadata metadata, String accessUrl);

  @Mapping(target = "fileId", source = "metadata.id")
  @Mapping(target = "fileName", source = "metadata.fileName")
  @Mapping(target = "fileType", source = "metadata.fileType")
  @Mapping(target = "mimeType", source = "metadata.mimeType")
  @Mapping(target = "sizeBytes", source = "metadata.sizeBytes")
  @Mapping(target = "createdAt", source = "metadata.createdAt")
  @Mapping(target = "url", source = "accessUrl")
  FileUploadResponse toUploadResponse(FileMetadata metadata, String accessUrl);
}
