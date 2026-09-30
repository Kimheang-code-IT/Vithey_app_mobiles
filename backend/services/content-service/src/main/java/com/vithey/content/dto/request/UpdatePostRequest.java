package com.vithey.content.dto.request;

import com.vithey.content.dto.request.CreatePostRequest.JobMetaRequest;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;

@Schema(
    name = "UpdatePostRequest",
    example = """
        {
          "content": "Updated post text",
          "job_meta": {
            "title": "Flutter Intern (updated)",
            "description": "Build mobile features",
            "requirement": "Year 3+ CS",
            "deadline": "2026-09-01"
          }
        }
        """
)
public record UpdatePostRequest(
    @Schema(example = "Updated post text") String content,
    @Valid JobMetaRequest jobMeta
) {
}
