package com.vithey.content.dto.request;

import com.vithey.content.entity.PostType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.UUID;

@Schema(
    name = "CreatePostRequest",
    example = """
        {
          "type": "JOB",
          "content": "We are hiring",
          "job_meta": {
            "title": "Flutter Intern",
            "description": "Build mobile features",
            "requirement": "Year 3+ CS",
            "deadline": "2026-08-01"
          }
        }
        """
)
public record CreatePostRequest(
    @NotNull
    @Schema(example = "POSTER", allowableValues = {"VIDEO", "POSTER", "JOB"})
    PostType type,
    @Schema(example = "Check out my project poster") String content,
    @Schema(example = "f6efaa58-4dbd-4a08-8a6c-7bb59b15f589") UUID mediaFileId,
    @Valid JobMetaRequest jobMeta
) {

  @Schema(name = "JobMetaRequest")
  public record JobMetaRequest(
      @Schema(example = "Flutter Intern") String title,
      @Schema(example = "Build mobile features") String description,
      @Schema(example = "Year 3+ CS") String requirement,
      @Schema(example = "2026-08-01") LocalDate deadline
  ) {
  }
}
