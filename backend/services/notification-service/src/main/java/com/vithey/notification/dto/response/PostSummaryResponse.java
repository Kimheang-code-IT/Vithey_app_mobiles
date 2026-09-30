package com.vithey.notification.dto.response;

import java.util.UUID;

public record PostSummaryResponse(
    UUID postId,
    AuthorSummaryResponse author
) {

  public record AuthorSummaryResponse(UUID userId) {
  }
}
