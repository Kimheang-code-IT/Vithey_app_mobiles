package com.vithey.profile.service;

import com.vithey.profile.dto.response.ProfileResponse;
import com.vithey.profile.dto.response.ProfileSkillResponse;
import com.vithey.profile.entity.FieldVisibility;
import com.vithey.profile.entity.Profile;
import com.vithey.profile.entity.ProfileSkillEntry;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class ProfileVisibilityService {

  public ProfileResponse toPublicResponse(Profile profile) {
    Map<String, String> visibility = profile.getFieldVisibility() == null ? Map.of() : profile.getFieldVisibility();
    return new ProfileResponse(
        profile.getUserId(),
        profile.getFullName(),
        profile.getBio(),
        profile.getAvatarUrl(),
        profile.getTelegramLink(),
        profile.getFacebookLink(),
        profile.getUniversity(),
        profile.getMajor(),
        profile.getGraduationYear(),
        profile.getLocation(),
        profile.getDateOfBirth(),
        profile.getWorkplace(),
        profile.getPortfolioUrl(),
        visibleContact(profile.getPhone(), visibility.get("phone")),
        visibleContact(profile.getEmail(), visibility.get("email")),
        mapSkills(profile.getSkills()),
        profile.getEducation(),
        null
    );
  }

  public ProfileResponse toOwnerResponse(Profile profile) {
    return new ProfileResponse(
        profile.getUserId(),
        profile.getFullName(),
        profile.getBio(),
        profile.getAvatarUrl(),
        profile.getTelegramLink(),
        profile.getFacebookLink(),
        profile.getUniversity(),
        profile.getMajor(),
        profile.getGraduationYear(),
        profile.getLocation(),
        profile.getDateOfBirth(),
        profile.getWorkplace(),
        profile.getPortfolioUrl(),
        profile.getPhone(),
        profile.getEmail(),
        mapSkills(profile.getSkills()),
        profile.getEducation(),
        profile.getFieldVisibility()
    );
  }

  private String visibleContact(String value, String visibility) {
    if (value == null || value.isBlank()) {
      return null;
    }
    return FieldVisibility.isPublic(visibility) ? value : null;
  }

  public List<ProfileSkillResponse> mapSkills(List<ProfileSkillEntry> skills) {
    if (skills == null || skills.isEmpty()) {
      return List.of();
    }
    return skills.stream()
        .map(skill -> new ProfileSkillResponse(skill.name(), skill.proficiency()))
        .toList();
  }
}
