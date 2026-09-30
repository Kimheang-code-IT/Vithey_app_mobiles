package com.vithey.career.dto.request;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record SetCvRequest(
    @NotNull UUID cvFileId
) {
}
