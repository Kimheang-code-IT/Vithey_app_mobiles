package com.vithey.career.dto.response;

import java.time.LocalDate;
import java.util.UUID;

public record PostSummaryResponse(
    UUID postId,
    String type,
    String content,
    AuthorSummaryResponse author,
    JobMetaResponse jobMeta
) {

  public record AuthorSummaryResponse(
      UUID userId,
      String fullName
  ) {
  }

  public record JobMetaResponse(
      String title,
      String description,
      String requirement,
      LocalDate deadline
  ) {
  }
}
