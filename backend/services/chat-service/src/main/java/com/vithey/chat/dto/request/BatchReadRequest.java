package com.vithey.chat.dto.request;

import jakarta.validation.constraints.NotEmpty;
import java.util.List;
import java.util.UUID;

public record BatchReadRequest(
    @NotEmpty List<UUID> messageIds
) {
}
