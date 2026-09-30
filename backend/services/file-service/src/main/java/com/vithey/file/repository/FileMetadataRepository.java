package com.vithey.file.repository;

import com.vithey.file.entity.FileMetadata;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FileMetadataRepository extends JpaRepository<FileMetadata, UUID> {

  Optional<FileMetadata> findByIdAndDeletedAtIsNull(UUID id);
}
