package com.vithey.profile.dto.response;

import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public record MeProfileResponse(
    UUID userId,
    String fullName,
    String bio,
    String avatarUrl,
    String telegramLink,
    String facebookLink,
    String university,
    String major,
    Integer graduationYear,
    String location,
    LocalDate dateOfBirth,
    String workplace,
    String portfolioUrl,
    String phone,
    String email,
    List<ProfileSkillResponse> skills,
    List<String> education,
    Map<String, String> fieldVisibility,
    AppLanguage language,
    AppTheme theme
) {
}
