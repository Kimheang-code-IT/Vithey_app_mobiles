package com.vithey.career.dto.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record ApplyJobRequest(
    @NotNull UUID jobPostId,
    @NotNull UUID cvFileId,
    @JsonAlias({"application_note", "cover_note"})
    String coverNote
) {
}
