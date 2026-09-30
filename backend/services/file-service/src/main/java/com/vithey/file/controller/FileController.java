package com.vithey.file.controller;

import com.vithey.file.dto.response.FileMetadataResponse;
import com.vithey.file.dto.response.FileUploadResponse;
import com.vithey.file.entity.StoredFileType;
import com.vithey.file.security.CurrentUserProvider;
import com.vithey.file.service.FileMetadataService;
import com.vithey.file.service.FileMetadataService.DownloadPayload;
import com.vithey.file.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.UUID;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/files")
@Tag(name = "Files", description = "Upload, metadata, download, and soft-delete files in MinIO")
public class FileController {

  private final FileMetadataService fileMetadataService;
  private final CurrentUserProvider currentUserProvider;

  public FileController(FileMetadataService fileMetadataService, CurrentUserProvider currentUserProvider) {
    this.fileMetadataService = fileMetadataService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  @Operation(
      summary = "Upload a file",
      description = "Multipart upload. `file` and `type` (AVATAR|CV|POSTER|VIDEO) are required. Returns metadata and a 1-hour presigned URL. Requires JWT."
  )
  @ApiResponse(responseCode = "201", description = "Uploaded")
  @ApiResponse(responseCode = "400", description = "Validation / MIME / size error")
  @ApiResponse(responseCode = "401", description = "Missing or invalid JWT")
  ResponseEntity<ApiResponseWrapper<FileUploadResponse>> upload(
      @Parameter(description = "Binary file part", required = true)
      @RequestPart("file") MultipartFile file,
      @Parameter(
          description = "Stored file type",
          required = true,
          schema = @Schema(allowableValues = {"AVATAR", "CV", "POSTER", "VIDEO"}, example = "AVATAR")
      )
      @RequestParam("type") StoredFileType type
  ) {
    UUID ownerUserId = currentUserProvider.requireCurrentUser().userId();
    FileUploadResponse response = fileMetadataService.upload(file, type, ownerUserId);
    return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponseWrapper.success(response));
  }

  @GetMapping("/{fileId}")
  @Operation(
      summary = "Get file metadata",
      description = "Returns metadata and a fresh 1-hour presigned URL for an active (not soft-deleted) file. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Found")
  @ApiResponse(responseCode = "404", description = "File not found or deleted")
  ResponseEntity<ApiResponseWrapper<FileMetadataResponse>> getFile(
      @Parameter(description = "File UUID", example = "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54")
      @PathVariable UUID fileId
  ) {
    return ResponseEntity.ok(ApiResponseWrapper.success(fileMetadataService.getMetadata(fileId)));
  }

  @GetMapping("/{fileId}/download")
  @Operation(
      summary = "Download file bytes",
      description = "Streams the binary object. CV downloads are owner-only; AVATAR/POSTER/VIDEO are allowed for any authenticated user. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Binary stream", content = @Content(mediaType = "application/octet-stream"))
  @ApiResponse(responseCode = "403", description = "Non-owner downloading a CV")
  @ApiResponse(responseCode = "404", description = "File not found")
  ResponseEntity<InputStreamResource> download(
      @Parameter(description = "File UUID", example = "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54")
      @PathVariable UUID fileId
  ) {
    UUID requesterUserId = currentUserProvider.requireCurrentUser().userId();
    DownloadPayload payload = fileMetadataService.download(fileId, requesterUserId);
    ContentDisposition disposition = ContentDisposition.attachment()
        .filename(payload.fileName())
        .build();
    return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
        .contentType(MediaType.parseMediaType(payload.mimeType()))
        .contentLength(payload.sizeBytes())
        .body(new InputStreamResource(payload.inputStream()));
  }

  @DeleteMapping("/{fileId}")
  @Operation(
      summary = "Soft-delete owned file",
      description = "Owner-only. Soft-deletes metadata then removes the MinIO object. Requires JWT."
  )
  @ApiResponse(responseCode = "204", description = "Deleted")
  @ApiResponse(responseCode = "403", description = "Not the owner")
  @ApiResponse(responseCode = "404", description = "File not found or already deleted")
  ResponseEntity<Void> delete(
      @Parameter(description = "File UUID", example = "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54")
      @PathVariable UUID fileId
  ) {
    UUID ownerUserId = currentUserProvider.requireCurrentUser().userId();
    fileMetadataService.delete(fileId, ownerUserId);
    return ResponseEntity.noContent().build();
  }
}
