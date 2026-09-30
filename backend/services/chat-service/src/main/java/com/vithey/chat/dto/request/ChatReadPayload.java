package com.vithey.chat.dto.request;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record ChatReadPayload(
    @NotNull UUID conversationId,
    @NotNull UUID messageId
) {
}
