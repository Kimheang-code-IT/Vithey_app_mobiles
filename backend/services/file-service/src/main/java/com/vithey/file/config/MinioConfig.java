package com.vithey.file.config;

import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import java.util.Arrays;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Configuration
public class MinioConfig {

  @Bean
  @Qualifier("minioStorageClient")
  MinioClient minioStorageClient(
      @Value("${vithey.minio.endpoint}") String endpoint,
      @Value("${vithey.minio.access-key}") String accessKey,
      @Value("${vithey.minio.secret-key}") String secretKey
  ) {
    return MinioClient.builder()
        .endpoint(endpoint)
        .credentials(accessKey, secretKey)
        .region("us-east-1")
        .build();
  }

  @Bean
  @Qualifier("minioPresignClient")
  MinioClient minioPresignClient(
      @Value("${vithey.minio.endpoint}") String endpoint,
      @Value("${vithey.minio.public-endpoint:}") String publicEndpoint,
      @Value("${vithey.minio.access-key}") String accessKey,
      @Value("${vithey.minio.secret-key}") String secretKey
  ) {
    String presignEndpoint = StringUtils.hasText(publicEndpoint) ? publicEndpoint : endpoint;
    return MinioClient.builder()
        .endpoint(presignEndpoint)
        .credentials(accessKey, secretKey)
        .region("us-east-1")
        .build();
  }

  @Component
  static class MinioBucketInitializer {

    private static final Logger log = LoggerFactory.getLogger(MinioBucketInitializer.class);

    private final MinioClient minioClient;
    private final String buckets;

    MinioBucketInitializer(
        @Qualifier("minioStorageClient") MinioClient minioClient,
        @Value("${vithey.minio.buckets}") String buckets
    ) {
      this.minioClient = minioClient;
      this.buckets = buckets;
    }

    @EventListener(ApplicationReadyEvent.class)
    void ensureBuckets() {
      List<String> bucketNames = Arrays.stream(buckets.split(","))
          .map(String::trim)
          .filter(value -> !value.isBlank())
          .toList();

      for (String bucket : bucketNames) {
        try {
          boolean exists = minioClient.bucketExists(BucketExistsArgs.builder().bucket(bucket).build());
          if (!exists) {
            minioClient.makeBucket(MakeBucketArgs.builder().bucket(bucket).build());
            log.info("Created MinIO bucket {}", bucket);
          }
        } catch (Exception exception) {
          log.warn("Unable to ensure MinIO bucket {} exists", bucket, exception);
        }
      }
    }
  }
}
