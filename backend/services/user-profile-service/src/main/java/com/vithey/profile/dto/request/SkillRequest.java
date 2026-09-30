package com.vithey.profile.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SkillRequest(
    @NotBlank @Size(max = 80) String name,
    @Min(0) @Max(100) int proficiency
) {
}
