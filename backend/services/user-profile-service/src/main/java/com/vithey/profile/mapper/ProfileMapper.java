package com.vithey.profile.mapper;

import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileSkillResponse;
import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import com.vithey.profile.entity.Profile;
import com.vithey.profile.entity.ProfileSkillEntry;
import java.util.List;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ProfileMapper {

  @Mapping(target = "userId", source = "profile.userId")
  @Mapping(target = "fullName", source = "profile.fullName")
  @Mapping(target = "bio", source = "profile.bio")
  @Mapping(target = "avatarUrl", source = "profile.avatarUrl")
  @Mapping(target = "telegramLink", source = "profile.telegramLink")
  @Mapping(target = "facebookLink", source = "profile.facebookLink")
  @Mapping(target = "university", source = "profile.university")
  @Mapping(target = "major", source = "profile.major")
  @Mapping(target = "graduationYear", source = "profile.graduationYear")
  @Mapping(target = "location", source = "profile.location")
  @Mapping(target = "dateOfBirth", source = "profile.dateOfBirth")
  @Mapping(target = "workplace", source = "profile.workplace")
  @Mapping(target = "portfolioUrl", source = "profile.portfolioUrl")
  @Mapping(target = "phone", source = "profile.phone")
  @Mapping(target = "email", source = "profile.email")
  @Mapping(target = "skills", expression = "java(mapSkillEntries(profile.getSkills()))")
  @Mapping(target = "education", source = "profile.education")
  @Mapping(target = "fieldVisibility", source = "profile.fieldVisibility")
  @Mapping(target = "language", source = "language")
  @Mapping(target = "theme", source = "theme")
  MeProfileResponse toMeResponse(Profile profile, AppLanguage language, AppTheme theme);

  default List<ProfileSkillResponse> mapSkillEntries(List<ProfileSkillEntry> skills) {
    if (skills == null || skills.isEmpty()) {
      return List.of();
    }
    return skills.stream()
        .map(skill -> new ProfileSkillResponse(skill.name(), skill.proficiency()))
        .toList();
  }
}