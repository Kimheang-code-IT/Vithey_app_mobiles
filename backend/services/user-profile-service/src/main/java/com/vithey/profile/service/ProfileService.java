package com.vithey.profile.service;

import com.vithey.profile.client.FileServiceClient;
import com.vithey.profile.dto.request.SkillRequest;
import com.vithey.profile.dto.request.UpdateAvatarRequest;
import com.vithey.profile.dto.request.UpdateProfileRequest;
import com.vithey.profile.dto.response.FileMetadataResponse;
import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileResponse;
import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import com.vithey.profile.entity.FieldVisibility;
import com.vithey.profile.entity.Profile;
import com.vithey.profile.entity.ProfileSkillEntry;
import com.vithey.profile.event.payload.ProfileUpdatedEvent;
import com.vithey.profile.event.payload.UserRegisteredEvent;
import com.vithey.profile.event.publisher.ProfileEventPublisher;
import com.vithey.profile.exception.ApiException;
import com.vithey.profile.exception.ErrorCode;
import com.vithey.profile.mapper.ProfileMapper;
import com.vithey.profile.repository.LanguageThemeProjection;
import com.vithey.profile.repository.ProfileRepository;
import com.vithey.profile.repository.UserSettingsRepository;
import com.vithey.profile.util.ApiResponseWrapper;
import feign.FeignException;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.util.StringUtils;

@Service
public class ProfileService {

  private static final int MAX_SKILLS = 12;
  private static final String AVATAR_FILE_TYPE = "AVATAR";

  private final ProfileRepository profileRepository;
  private final UserSettingsRepository userSettingsRepository;
  private final ProfileMapper profileMapper;
  private final ProfileVisibilityService profileVisibilityService;
  private final FileServiceClient fileServiceClient;
  private final SettingsService settingsService;
  private final ProfileEventPublisher profileEventPublisher;
  private final TransactionTemplate transactionTemplate;

  public ProfileService(
      ProfileRepository profileRepository,
      UserSettingsRepository userSettingsRepository,
      ProfileMapper profileMapper,
      ProfileVisibilityService profileVisibilityService,
      FileServiceClient fileServiceClient,
      SettingsService settingsService,
      ProfileEventPublisher profileEventPublisher,
      PlatformTransactionManager transactionManager
  ) {
    this.profileRepository = profileRepository;
    this.userSettingsRepository = userSettingsRepository;
    this.profileMapper = profileMapper;
    this.profileVisibilityService = profileVisibilityService;
    this.fileServiceClient = fileServiceClient;
    this.settingsService = settingsService;
    this.profileEventPublisher = profileEventPublisher;
    this.transactionTemplate = new TransactionTemplate(transactionManager);
  }

  @Transactional(readOnly = true)
  public MeProfileResponse getMyProfile(UUID userId) {
    Profile profile = requireProfile(userId);
    LanguageThemeProjection languageTheme = userSettingsRepository.findLanguageThemeByUserId(userId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Settings not found"));
    return profileMapper.toMeResponse(
        profile,
        languageTheme.getLanguage() != null ? languageTheme.getLanguage() : AppLanguage.en,
        languageTheme.getTheme() != null ? languageTheme.getTheme() : AppTheme.system
    );
  }

  @Transactional(readOnly = true)
  public ProfileResponse getPublicProfile(UUID userId) {
    return profileVisibilityService.toPublicResponse(requireProfile(userId));
  }

  @Transactional
  public ProfileResponse updateProfile(UUID userId, UpdateProfileRequest request) {
    Profile profile = requireProfile(userId);
    applyProfileUpdates(profile, request);
    Profile saved = profileRepository.save(profile);
    publishUpdated(saved);
    return profileVisibilityService.toOwnerResponse(saved);
  }

  /**
   * Resolves avatar metadata outside the DB transaction so a slow file-service call
   * does not hold a Hikari connection.
   */
  public ProfileResponse updateAvatar(UUID userId, UpdateAvatarRequest request) {
    UUID avatarFileId = request.avatarFileId();
    Profile existing = transactionTemplate.execute(status -> requireProfile(userId));
    if (existing != null && avatarFileId.equals(existing.getAvatarFileId())) {
      return profileVisibilityService.toOwnerResponse(existing);
    }

    FileMetadataResponse file = resolveAvatarFile(avatarFileId, userId);
    return transactionTemplate.execute(status -> {
      Profile profile = requireProfile(userId);
      if (file.fileId().equals(profile.getAvatarFileId())
          && Objects.equals(file.url(), profile.getAvatarUrl())) {
        return profileVisibilityService.toOwnerResponse(profile);
      }
      profile.setAvatarFileId(file.fileId());
      profile.setAvatarUrl(file.url());
      Profile saved = profileRepository.save(profile);
      publishUpdated(saved);
      return profileVisibilityService.toOwnerResponse(saved);
    });
  }

  @Transactional
  public void createFromRegistration(UserRegisteredEvent event) {
    if (profileRepository.existsById(event.userId())) {
      return;
    }

    Profile profile = new Profile();
    profile.setUserId(event.userId());
    profile.setFullName(StringUtils.hasText(event.fullName()) ? event.fullName() : "Vithey User");
    profile.setSkills(List.of());
    profile.setEducation(List.of());
    profile.setFieldVisibility(defaultFieldVisibility());
    profileRepository.save(profile);
    settingsService.createDefaultSettings(event.userId());
  }

  private Profile requireProfile(UUID userId) {
    return profileRepository.findById(userId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Profile not found"));
  }

  private FileMetadataResponse resolveAvatarFile(UUID fileId, UUID ownerUserId) {
    try {
      ApiResponseWrapper<FileMetadataResponse> response = fileServiceClient.getFile(fileId);
      if (response == null || response.data() == null) {
        throw new ApiException(ErrorCode.INVALID_FILE);
      }
      FileMetadataResponse metadata = response.data();
      if (metadata.ownerUserId() != null && !metadata.ownerUserId().equals(ownerUserId)) {
        throw new ApiException(ErrorCode.INVALID_FILE, "Avatar file does not belong to user");
      }
      if (metadata.type() != null && !AVATAR_FILE_TYPE.equalsIgnoreCase(metadata.type())) {
        throw new ApiException(ErrorCode.INVALID_FILE, "File must be uploaded as AVATAR");
      }
      return metadata;
    } catch (FeignException.NotFound exception) {
      throw new ApiException(ErrorCode.INVALID_FILE, "Avatar file not found");
    } catch (FeignException exception) {
      throw new ApiException(ErrorCode.INVALID_FILE, "Unable to validate avatar file");
    }
  }

  private void applyProfileUpdates(Profile profile, UpdateProfileRequest request) {
    if (request.fullName() != null && !Objects.equals(request.fullName(), profile.getFullName())) {
      profile.setFullName(request.fullName());
    }
    if (request.bio() != null && !Objects.equals(request.bio(), profile.getBio())) {
      profile.setBio(request.bio());
    }
    if (request.telegramLink() != null && !Objects.equals(request.telegramLink(), profile.getTelegramLink())) {
      profile.setTelegramLink(request.telegramLink());
    }
    if (request.facebookLink() != null && !Objects.equals(request.facebookLink(), profile.getFacebookLink())) {
      profile.setFacebookLink(request.facebookLink());
    }
    if (request.university() != null && !Objects.equals(request.university(), profile.getUniversity())) {
      profile.setUniversity(request.university());
    }
    if (request.major() != null && !Objects.equals(request.major(), profile.getMajor())) {
      profile.setMajor(request.major());
    }
    if (request.graduationYear() != null
        && !Objects.equals(request.graduationYear(), profile.getGraduationYear())) {
      profile.setGraduationYear(request.graduationYear());
    }
    if (request.location() != null && !Objects.equals(request.location(), profile.getLocation())) {
      profile.setLocation(request.location());
    }
    if (request.dateOfBirth() != null && !Objects.equals(request.dateOfBirth(), profile.getDateOfBirth())) {
      profile.setDateOfBirth(request.dateOfBirth());
    }
    if (request.workplace() != null && !Objects.equals(request.workplace(), profile.getWorkplace())) {
      profile.setWorkplace(request.workplace());
    }
    if (request.portfolioUrl() != null && !Objects.equals(request.portfolioUrl(), profile.getPortfolioUrl())) {
      profile.setPortfolioUrl(request.portfolioUrl());
    }
    if (request.phone() != null && !Objects.equals(request.phone(), profile.getPhone())) {
      profile.setPhone(request.phone());
    }
    if (request.email() != null && !Objects.equals(request.email(), profile.getEmail())) {
      profile.setEmail(request.email());
    }
    if (request.skills() != null) {
      profile.setSkills(mapSkills(request.skills()));
    }
    if (request.education() != null) {
      profile.setEducation(request.education());
    }
    if (request.fieldVisibility() != null) {
      Map<String, String> merged = new HashMap<>(defaultFieldVisibility());
      if (profile.getFieldVisibility() != null) {
        merged.putAll(profile.getFieldVisibility());
      }
      merged.putAll(request.fieldVisibility());
      profile.setFieldVisibility(merged);
    }
  }

  private List<ProfileSkillEntry> mapSkills(List<SkillRequest> skills) {
    if (skills.size() > MAX_SKILLS) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "A maximum of " + MAX_SKILLS + " skills is allowed");
    }
    return skills.stream()
        .map(skill -> new ProfileSkillEntry(skill.name().trim(), skill.proficiency()))
        .toList();
  }

  private Map<String, String> defaultFieldVisibility() {
    Map<String, String> defaults = new HashMap<>();
    defaults.put("phone", FieldVisibility.PRIVATE);
    defaults.put("email", FieldVisibility.PRIVATE);
    return defaults;
  }

  private void publishUpdated(Profile profile) {
    profileEventPublisher.publishUpdated(new ProfileUpdatedEvent(
        profile.getUserId(),
        profile.getUpdatedAt() == null ? OffsetDateTime.now(ZoneOffset.UTC) : profile.getUpdatedAt()
    ));
  }
}